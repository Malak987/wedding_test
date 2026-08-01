/// ============================================================
/// LINKS — Local Dashboard
/// ============================================================
/// Note: WhatsApp, Google Maps, and Facebook links are set in
/// `lib/services/config_manager.dart` (_whatsappNumber, _googleMapsUrl,
/// _facebookUrl) — that's the single real source for those.
/// This file only holds the guest photo-sharing form link below.

class AppLinks {
  AppLinks._();

  /// ----------------------------------------------------------
  /// Guest photo/video sharing form.
  /// ----------------------------------------------------------
  /// Since this project has no backend/database, the easiest and most
  /// reliable free way to collect photos & videos from your guests is
  /// a Google Form with a "File upload" question — every file guests
  /// submit is saved automatically into a Google Drive folder that
  /// belongs to YOUR Google account, and you can view/download it any
  /// time from Drive. No coding needed.
  ///
  /// How to set it up (5 minutes):
  /// 1. Go to https://forms.google.com and create a new form.
  /// 2. Add a "File upload" question (allow images + videos).
  /// 3. Add an optional short-answer question for the guest's name.
  /// 4. Click Send > copy the form link.
  /// 5. Paste that link below instead of the placeholder.
  /// 6. (Optional) Open the linked "Responses" tab > the folder icon
  ///    to jump straight to the Google Drive folder collecting everything.
  static const String guestPhotosFormUrl =
      'https://forms.google.com/PASTE_YOUR_FORM_LINK_HERE';

  /// ----------------------------------------------------------
  /// Site identifier for the comments feature.
  /// ----------------------------------------------------------
  /// If you deploy more than one design variant of this invitation
  /// (each with its own domain/link) but share ONE Firebase project
  /// between them, give each variant a unique siteId so you can tell
  /// their comments apart in the Firebase Console. Just change this
  /// one line per variant — nothing else needs to change.
  static const String siteId = 'main';

  /// ----------------------------------------------------------
  /// RSVP / Calendar / Notifications identifiers.
  /// ----------------------------------------------------------
  /// RSVP documents are saved in Firestore collection `guestResponses`.
  /// The document ID is generated from `eventId + guestId`, so every guest
  /// updates the same document if they submit again.
  static const String eventId = 'event_001';

  /// Public invitation URL used inside Google Calendar and ICS files.
  static const String weddingWebsiteUrl = 'https://weddingtest-2000.web.app/';

  /// Firebase Cloud Messaging Web Push certificate key.
  /// Firebase Console → Project settings → Cloud Messaging → Web Push
  /// certificates → Generate key pair, then paste the public key here.
  /// Leaving it empty keeps RSVP working; notifications will show a helpful
  /// setup message until the key is configured.
  static const String fcmWebVapidKey = '';
}