import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../dashboard/links.dart';
import '../models/rsvp_response.dart';
import 'config_manager.dart';
import 'rsvp_service.dart';

class NotificationEnableResult {
  final bool enabled;
  final String message;

  const NotificationEnableResult({
    required this.enabled,
    required this.message,
  });
}

/// Requests Firebase Cloud Messaging permission only after RSVP success.
///
/// Important: FCM clients can obtain/store tokens, but they cannot send future
/// scheduled push messages by themselves. The reminder schedule is saved in the
/// same `guestResponses` document so an admin dashboard, Firebase Notifications
/// Composer, or a future sender can use it without adding another collection.
class RsvpNotificationService {
  static final RsvpNotificationService instance = RsvpNotificationService._internal();
  RsvpNotificationService._internal();

  Future<NotificationEnableResult> enableForResponse(RsvpSaveResult result) async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final allowed = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      if (!allowed) {
        await RsvpService.instance.saveNotificationPreferences(
          documentId: result.documentId,
          fcmToken: null,
          reminderSchedule: _buildReminderSchedule(),
        );
        return const NotificationEnableResult(
          enabled: false,
          message: 'Notification permission was not granted.',
        );
      }

      final vapidKey = AppLinks.fcmWebVapidKey.trim();
      final token = await FirebaseMessaging.instance.getToken(
        vapidKey: vapidKey.isEmpty ? null : vapidKey,
      );

      await RsvpService.instance.saveNotificationPreferences(
        documentId: result.documentId,
        fcmToken: token,
        reminderSchedule: _buildReminderSchedule(),
      );

      if (token == null || token.isEmpty) {
        return const NotificationEnableResult(
          enabled: false,
          message: 'Permission granted, but no FCM token was returned. Check the Web Push VAPID key.',
        );
      }

      return const NotificationEnableResult(
        enabled: true,
        message: 'Notifications are enabled for this device.',
      );
    } catch (e) {
      return NotificationEnableResult(
        enabled: false,
        message: 'Could not enable notifications: $e',
      );
    }
  }

  List<Map<String, dynamic>> _buildReminderSchedule() {
    final start = _eventStart(AppConfigManager.instance);
    final weddingMorning = DateTime(start.year, start.month, start.day, 9);

    return [
      {
        'type': 'one_day_before',
        'scheduledFor': Timestamp.fromDate(start.subtract(const Duration(days: 1))),
        'title': 'Wedding Reminder',
        'body': 'The wedding is tomorrow. We look forward to seeing you!',
      },
      {
        'type': 'wedding_day_9am',
        'scheduledFor': Timestamp.fromDate(weddingMorning),
        'title': 'Wedding Day',
        'body': 'Today is the wedding day. See you soon!',
      },
      {
        'type': 'one_hour_before',
        'scheduledFor': Timestamp.fromDate(start.subtract(const Duration(hours: 1))),
        'title': 'Wedding Ceremony',
        'body': 'The ceremony starts in one hour.',
      },
    ];
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
}
