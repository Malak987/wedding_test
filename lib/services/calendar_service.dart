import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../dashboard/links.dart';
import '../services/config_manager.dart';
import '../utils/web_runtime_stub.dart'
    if (dart.library.html) '../utils/web_runtime.dart';

class CalendarService {
  static final CalendarService instance = CalendarService._internal();
  CalendarService._internal();

  Future<void> addWeddingToCalendar() async {
    final manager = AppConfigManager.instance;
    final start = _eventStart(manager);
    final end = start.add(const Duration(hours: 4));

    if (_isAppleMobileBrowser) {
      _downloadIcs(manager: manager, start: start, end: end);
      return;
    }

    await _openGoogleCalendar(manager: manager, start: start, end: end);
  }

  bool get _isAppleMobileBrowser {
    if (!kIsWeb) return defaultTargetPlatform == TargetPlatform.iOS;
    final ua = WebRuntime.userAgent.toLowerCase();
    final isIphoneOrIpod = ua.contains('iphone') || ua.contains('ipod');
    final isIpad = ua.contains('ipad') ||
        (ua.contains('macintosh') && WebRuntime.maxTouchPoints > 1);
    return isIphoneOrIpod || isIpad;
  }

  Future<void> _openGoogleCalendar({
    required AppConfigManager manager,
    required DateTime start,
    required DateTime end,
  }) async {
    final details = 'Join us to celebrate our special day.\n'
        'Website: ${AppLinks.weddingWebsiteUrl}';

    final params = <String, String>{
      'action': 'TEMPLATE',
      'text': 'Wedding Ceremony',
      'dates': '${_googleDate(start)}/${_googleDate(end)}',
      'details': details,
      'location': '${manager.venueName}, ${manager.venueAddress}',
      if (WebRuntime.localTimeZone.trim().isNotEmpty) 'ctz': WebRuntime.localTimeZone,
    };

    final uri = Uri.https('calendar.google.com', '/calendar/render', params);
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
  }

  void _downloadIcs({
    required AppConfigManager manager,
    required DateTime start,
    required DateTime end,
  }) {
    final nowUtc = DateTime.now().toUtc();
    final timezone = WebRuntime.localTimeZone.trim().isEmpty
        ? DateTime.now().timeZoneName
        : WebRuntime.localTimeZone.trim();

    final morning = DateTime(start.year, start.month, start.day, 9);
    final morningOffset = start.difference(morning);
    final morningTrigger = morningOffset.isNegative
        ? '-PT1H'
        : '-PT${morningOffset.inHours}H${morningOffset.inMinutes.remainder(60)}M';

    final summary = _ics('Wedding Ceremony');
    final description = _ics(
      'Join us to celebrate our special day.\nWebsite: ${AppLinks.weddingWebsiteUrl}',
    );
    final location = _ics('${manager.venueName}, ${manager.venueAddress}');
    final weddingDayReminder = _ics('Wedding day reminder');
    final oneHourReminder = _ics('Wedding ceremony starts in one hour');

    final ics = StringBuffer()
      ..writeln('BEGIN:VCALENDAR')
      ..writeln('VERSION:2.0')
      ..writeln('PRODID:-//Wedding Invitation//RSVP Calendar//EN')
      ..writeln('CALSCALE:GREGORIAN')
      ..writeln('METHOD:PUBLISH')
      ..writeln('X-WR-CALNAME:Wedding Ceremony')
      ..writeln('X-WR-TIMEZONE:${_ics(timezone)}')
      ..writeln('BEGIN:VEVENT')
      ..writeln('UID:${AppLinks.eventId}@weddingtest-2000.web.app')
      ..writeln('DTSTAMP:${_icsUtc(nowUtc)}')
      ..writeln('DTSTART;TZID=${_ics(timezone)}:${_icsLocal(start)}')
      ..writeln('DTEND;TZID=${_ics(timezone)}:${_icsLocal(end)}')
      ..writeln('SUMMARY:$summary')
      ..writeln('DESCRIPTION:$description')
      ..writeln('LOCATION:$location')
      ..writeln('URL:${_ics(AppLinks.weddingWebsiteUrl)}')
      ..writeln('BEGIN:VALARM')
      ..writeln('TRIGGER:$morningTrigger')
      ..writeln('ACTION:DISPLAY')
      ..writeln('DESCRIPTION:$weddingDayReminder')
      ..writeln('END:VALARM')
      ..writeln('BEGIN:VALARM')
      ..writeln('TRIGGER:-PT1H')
      ..writeln('ACTION:DISPLAY')
      ..writeln('DESCRIPTION:$oneHourReminder')
      ..writeln('END:VALARM')
      ..writeln('END:VEVENT')
      ..writeln('END:VCALENDAR');

    WebRuntime.downloadTextFile(
      fileName: 'wedding_ceremony.ics',
      content: ics.toString(),
      mimeType: 'text/calendar;charset=utf-8',
    );
  }

  DateTime _eventStart(AppConfigManager manager) {
    final parsedCountdown = DateTime.tryParse(manager.countdownTarget);
    if (parsedCountdown != null) return parsedCountdown;

    final parsedDate = DateTime.tryParse(manager.eventDate);
    if (parsedDate != null) {
      return DateTime(parsedDate.year, parsedDate.month, parsedDate.day, 19);
    }

    return DateTime.now().add(const Duration(days: 30));
  }

  String _googleDate(DateTime value) =>
      '${_two(value.year, 4)}${_two(value.month)}${_two(value.day)}T${_two(value.hour)}${_two(value.minute)}${_two(value.second)}';

  String _icsLocal(DateTime value) => _googleDate(value);

  String _icsUtc(DateTime value) => '${_googleDate(value)}Z';

  String _two(int value, [int width = 2]) => value.toString().padLeft(width, '0');

  String _ics(String value) => value
      .replaceAll('\\', '\\\\')
      .replaceAll(';', '\\;')
      .replaceAll(',', '\\,')
      .replaceAll('\r\n', '\\n')
      .replaceAll('\n', '\\n');
}
