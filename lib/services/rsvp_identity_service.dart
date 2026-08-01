import 'dart:math';

import '../utils/web_runtime_stub.dart'
if (dart.library.html) '../utils/web_runtime.dart';

class GuestIdentity {
  final String guestId;
  final String guestName;
  final String deviceId;

  const GuestIdentity({
    required this.guestId,
    required this.guestName,
    required this.deviceId,
  });
}

/// Resolves RSVP identity without authentication/backend.
///
/// Recommended invitation URL format:
/// `https://weddingtest-2000.web.app/?guestId=guest_120&guestName=Ahmed`
///
/// If the link does not include a guest id, the app creates a stable browser
/// guest id and device id in localStorage. This still guarantees one Firestore
/// document per browser/device; for strict one-response-per-invited-guest,
/// send personalized links with a `guestId` parameter.
class RsvpIdentityService {
  static final RsvpIdentityService instance = RsvpIdentityService._internal();
  RsvpIdentityService._internal();

  static const _deviceStorageKey = 'wedding_rsvp_device_id';
  static const _guestStorageKey = 'wedding_rsvp_guest_id';
  static const _guestNameStorageKey = 'wedding_rsvp_guest_name';

  final Random _random = Random.secure();

  void saveGuestName(String guestName) {
    final cleanName = guestName.trim();
    if (cleanName.isNotEmpty) {
      WebRuntime.writeStorage(_guestNameStorageKey, cleanName);
    }
  }

  GuestIdentity resolve() {
    final query = Uri.base.queryParameters;

    final queryGuestId = _firstNonEmpty([
      query['guestId'],
      query['guest_id'],
      query['gid'],
      query['id'],
    ]);

    final queryGuestName = _firstNonEmpty([
      query['guestName'],
      query['guest_name'],
      query['name'],
    ]);

    final deviceId = _getOrCreateStoredValue(_deviceStorageKey, _newDeviceId);

    final guestId = queryGuestId?.trim().isNotEmpty == true
        ? queryGuestId!.trim()
        : _getOrCreateStoredValue(_guestStorageKey, _newGuestId);

    if (queryGuestId != null && queryGuestId.trim().isNotEmpty) {
      WebRuntime.writeStorage(_guestStorageKey, queryGuestId.trim());
    }

    final guestName = queryGuestName?.trim().isNotEmpty == true
        ? queryGuestName!.trim()
        : (WebRuntime.readStorage(_guestNameStorageKey)?.trim().isNotEmpty == true
        ? WebRuntime.readStorage(_guestNameStorageKey)!.trim()
        : 'Guest');

    if (queryGuestName != null && queryGuestName.trim().isNotEmpty) {
      WebRuntime.writeStorage(_guestNameStorageKey, queryGuestName.trim());
    }

    return GuestIdentity(
      guestId: _cleanForField(guestId),
      guestName: guestName,
      deviceId: deviceId,
    );
  }

  String _getOrCreateStoredValue(String key, String Function() generator) {
    final stored = WebRuntime.readStorage(key);
    if (stored != null && stored.trim().isNotEmpty) return stored.trim();

    final value = generator();
    WebRuntime.writeStorage(key, value);
    return value;
  }

  String _newGuestId() => 'guest_${_randomToken(14)}';

  String _newDeviceId() => 'device_${_randomToken(24)}';

  String _randomToken(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(chars[_random.nextInt(chars.length)]);
    }
    return '${DateTime.now().millisecondsSinceEpoch}_${buffer.toString()}';
  }

  String _cleanForField(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');
    return cleaned.isEmpty ? _newGuestId() : cleaned;
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) return value;
    }
    return null;
  }
}
