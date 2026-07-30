import 'dart:async';
import 'package:flutter/material.dart';
import '../services/config_manager.dart';
import '../dashboard/gallery_config.dart';
import '../dashboard/links.dart';
import '../utils/launch_url.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_title.dart';
import '../animations/fade_in.dart';
import '../animations/scale_in.dart';

/// ============================================================
/// GUEST PHOTO SHARING
/// ============================================================
/// This project has no backend/database, so guest photos & videos
/// are collected through a Google Form with a "File upload" question.
/// Every file a guest submits is saved automatically into a Google
/// Drive folder in your own Google account — free, reliable, and
/// nothing to maintain.
///
/// Setup (5 minutes): see the instructions in lib/dashboard/links.dart
/// next to `guestPhotosFormUrl`, then paste your real form link there.
/// ============================================================

class GuestGallerySection extends StatefulWidget {
  const GuestGallerySection({super.key});

  @override
  State<GuestGallerySection> createState() => _GuestGallerySectionState();
}

class _GuestGallerySectionState extends State<GuestGallerySection> {
  late bool _isOpen;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _isOpen = false;
    _checkStatus();
    // Periodically re-check so the button appears automatically once the
    // configured opening date/time is reached, without needing a refresh.
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _checkStatus());
  }

  void _checkStatus() {
    if (!GalleryConfig.enableGuestGallery) {
      if (mounted) setState(() => _isOpen = false);
      return;
    }
    final now = DateTime.now();
    final isOpen = now.isAfter(GalleryConfig.galleryOpenDate);
    if (mounted) {
      setState(() {
        _isOpen = isOpen;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!GalleryConfig.enableGuestGallery) return const SizedBox.shrink();

    final manager = AppConfigManager.instance;

    return Container(
      color: manager.accentColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 64),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Column(
            children: [
              SectionTitle(
                title: manager.selectedLanguage == 'ar' ? 'ذكريات اليوم' : 'Share Your Moments',
                subtitle: manager.selectedLanguage == 'ar'
                    ? 'شاركنا لحظاتك الجميلة والصور التي التقطتها معنا في هذا اليوم السعيد'
                    : 'Share the beautiful pictures and memories you captured with us on our happy day',
              ),
              const SizedBox(height: 36),
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
                child: _isOpen
                    ? const GuestPhotoShareCard()
                    : const GalleryClosedCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders a luxurious card showing that photo sharing is locked until
/// the configured date/time in GalleryConfig.galleryOpenDate.
class GalleryClosedCard extends StatelessWidget {
  const GalleryClosedCard({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final primary = manager.primaryColor;

    return ScaleIn(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.12),
              ),
              child: Icon(Icons.lock_clock_outlined, color: primary, size: 36),
            ),
            const SizedBox(height: 24),
            Text(
              manager.selectedLanguage == 'ar'
                  ? "سيتم فتح معرض الذكريات بعد انتهاء الحفل ❤️"
                  : "The memory gallery will open once the celebration ends ❤️",
              style: TextStyle(
                fontFamily: manager.bodyFont,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: manager.secondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              manager.selectedLanguage == 'ar'
                  ? 'انتظرونا لمشاركة أفضل الصور ومقاطع الفيديو التذكارية فور فتح الصندوق.'
                  : 'Stay tuned to share your best pictures and videos as soon as the gallery opens.',
              style: TextStyle(
                fontFamily: manager.bodyFont,
                fontSize: 12,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// The real, working call-to-action shown once sharing is open.
/// Tapping the button opens the configured Google Form in a new tab —
/// every photo/video a guest submits there lands directly in the
/// couple's own Google Drive folder. No fake uploads, no local state.
class GuestPhotoShareCard extends StatelessWidget {
  const GuestPhotoShareCard({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final isAr = manager.selectedLanguage == 'ar';
    final primary = manager.primaryColor;
    final secondary = manager.secondaryColor;

    return FadeIn(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.12),
              ),
              child: Icon(Icons.add_photo_alternate_outlined, color: primary, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              isAr ? "شاركنا أجمل لحظات هذا اليوم ❤️" : "Share your favorite moments with us ❤️",
              style: TextStyle(
                fontFamily: manager.headingFont,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              isAr
                  ? "اضغط على الزر لفتح نموذج رفع الصور والفيديوهات، وسيصلنا كل ما ترفعه مباشرة."
                  : "Tap the button to open the photo & video sharing form — everything you upload reaches us directly.",
              style: TextStyle(
                fontFamily: manager.bodyFont,
                fontSize: 13,
                color: Colors.black54,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => launchAppUrl(AppLinks.guestPhotosFormUrl),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.open_in_new, color: Colors.white, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        isAr ? "شارك صورك وفيديوهاتك" : "Share Your Photos & Videos",
                        style: TextStyle(
                          fontFamily: manager.bodyFont,
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
