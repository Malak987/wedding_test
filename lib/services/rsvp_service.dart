import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/rsvp_response.dart';

/// RSVP persistence layer.
///
/// No backend is used: the client writes directly to Firestore. A deterministic
/// document ID (`eventId_guestId`) guarantees one document per guest. Re-submit
/// = update/merge the same document, never create duplicates.
class RsvpService {
  static final RsvpService instance = RsvpService._internal();
  RsvpService._internal();

  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('guestResponses');

  Future<RsvpSaveResult> saveResponse(RsvpResponse response) async {
    final documentId = documentIdFor(
      eventId: response.eventId,
      guestId: response.guestId,
    );

    await _collection.doc(documentId).set(
      response.toFirestore(),
      SetOptions(merge: true),
    );

    return RsvpSaveResult(documentId: documentId, response: response);
  }

  Future<void> saveNotificationPreferences({
    required String documentId,
    required String? fcmToken,
    required List<Map<String, dynamic>> reminderSchedule,
  }) async {
    await _collection.doc(documentId).set({
      'notificationsEnabled': fcmToken != null && fcmToken.isNotEmpty,
      'fcmToken': fcmToken,
      'reminderSchedule': reminderSchedule,
      'notificationsUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String documentIdFor({required String eventId, required String guestId}) {
    String clean(String value) => value
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_')
        .replaceAll(RegExp('_+'), '_');

    return '${clean(eventId)}_${clean(guestId)}';
  }
}
