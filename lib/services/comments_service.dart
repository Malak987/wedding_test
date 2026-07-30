import 'package:cloud_firestore/cloud_firestore.dart';

/// ============================================================
/// GUEST COMMENTS
/// ============================================================
/// Saves each guest comment to Firestore, collection `comments`.
///
/// `siteId` lets you reuse ONE Firebase project for several
/// invitation variants (e.g. different designs/links you deploy)
/// while still knowing which site each comment came from. Set it
/// once per variant in `lib/dashboard/links.dart` (see `siteId`
/// there) — no other code needs to change between variants.
///
/// Comments are write-only from the app: guests can submit but
/// can never read, edit, or delete comments (see firestore.rules).
/// You review them from the Firebase Console:
/// Firestore Database → Data → comments
/// ============================================================
class CommentsService {
  static final CommentsService instance = CommentsService._internal();
  CommentsService._internal();

  final CollectionReference<Map<String, dynamic>> _collection =
  FirebaseFirestore.instance.collection('comments');

  /// Sends one guest comment to Firestore.
  /// Throws on failure so the UI can show an error message.
  Future<void> addComment({
    required String name,
    required String message,
    required String siteId,
  }) async {
    final cleanName = name.trim();
    final cleanMessage = message.trim();

    if (cleanName.isEmpty || cleanMessage.isEmpty) {
      throw ArgumentError('name and message are required');
    }

    await _collection.add({
      'name': cleanName,
      'message': cleanMessage,
      'siteId': siteId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}