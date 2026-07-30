/// ============================================================
/// GUEST GALLERY CONFIGURATION — Local Dashboard
/// ============================================================
/// Control whether and when guests can share their wedding day
/// photos and videos with you. Photos are collected through a
/// Google Form (see lib/dashboard/links.dart -> guestPhotosFormUrl)
/// which saves every upload directly into your Google Drive — no
/// backend or database needed.
/// ============================================================

class GalleryConfig {
  GalleryConfig._();

  /// Globally enable or disable this feature
  static const bool enableGuestGallery = true;

  /// The exact date and time the Guest Gallery button becomes available.
  /// Format: DateTime(yyyy, MM, dd, HH, mm)
  static final DateTime galleryOpenDate = DateTime(2026, 8, 24, 0, 0);
}
