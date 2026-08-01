import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore values used by the admin dashboard later.
enum AttendanceStatus {
  attending,
  declined;

  String get firestoreValue => switch (this) {
        AttendanceStatus.attending => 'attending',
        AttendanceStatus.declined => 'declined',
      };
}

class RsvpResponse {
  final String eventId;
  final String guestId;
  final String guestName;
  final AttendanceStatus attendanceStatus;
  final int guestCount;
  final String message;
  final String language;
  final String deviceId;

  const RsvpResponse({
    required this.eventId,
    required this.guestId,
    required this.guestName,
    required this.attendanceStatus,
    required this.guestCount,
    required this.message,
    required this.language,
    required this.deviceId,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'guestId': guestId,
      'guestName': guestName,
      'attendanceStatus': attendanceStatus.firestoreValue,
      'guestCount': attendanceStatus == AttendanceStatus.attending ? guestCount : 0,
      'message': message.trim(),
      'language': language,
      'deviceId': deviceId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class RsvpSaveResult {
  final String documentId;
  final RsvpResponse response;

  const RsvpSaveResult({
    required this.documentId,
    required this.response,
  });
}
