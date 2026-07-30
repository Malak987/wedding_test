import 'package:flutter/material.dart';
import '../services/config_manager.dart';
import '../core/localization.dart';
import '../core/responsive.dart';
import '../core/constants.dart';
import '../widgets/section_title.dart';
import '../widgets/gallery_image.dart';
import '../animations/scale_in.dart';

class GallerySection extends StatefulWidget {
  const GallerySection({super.key});

  @override
  State<GallerySection> createState() => _GallerySectionState();
}

class _GallerySectionState extends State<GallerySection> {
  // The couple's real photos together
  final List<String> _galleryImages = [
    'assets/images/story_now.png',
    'assets/images/gallery_1.png',
    'assets/images/gallery_2.png',
    'assets/images/gallery_3.png',
    'assets/images/gallery_4.png',
    'assets/images/gallery_5.png',
  ];

  void _openLightbox(int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (context, _, __) {
          return GalleryLightbox(
            images: _galleryImages,
            initialIndex: initialIndex,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final lang = manager.selectedLanguage;
    final columns = _galleryImages.length < 3
        ? _galleryImages.length
        : Responsive.value<int>(context, mobile: 2, tablet: 3, desktop: 3);

    return Container(
      color: manager.accentColor,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.horizontalPadding(context),
        vertical: Responsive.value(
          context,
          mobile: AppConstants.sectionSpacingMobile,
          desktop: AppConstants.sectionSpacing,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
          child: Column(
            children: [
              SectionTitle(
                title: Localization.get(lang, 'nav_gallery'),
                subtitle: Localization.get(lang, 'gallery_subtitle'),
              ),
              const SizedBox(height: 48),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _galleryImages.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75, // Tall, elegant fashion-style grid
                ),
                itemBuilder: (context, index) {
                  return ScaleIn(
                    delay: Duration(milliseconds: 100 * (index % 4)),
                    child: GalleryImage(
                      imagePath: _galleryImages[index],
                      onTap: () => _openLightbox(index),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A breathtaking fullscreen Lightbox for browsing wedding gallery pictures
/// with zoom, swipe gestures, desktop buttons, and double gold borders.
class GalleryLightbox extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const GalleryLightbox({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<GalleryLightbox> createState() => _GalleryLightboxState();
}

class _GalleryLightboxState extends State<GalleryLightbox> {
  late int _currentIndex;
  late final PageController _pageController;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < widget.images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final primary = manager.primaryColor;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.92),
      body: Stack(
        children: [
          // Main Swipable Viewport
          Positioned.fill(
            child: GestureDetector(
              onVerticalDragEnd: (_) => Navigator.of(context).pop(),
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                onPageChanged: (idx) {
                  setState(() {
                    _currentIndex = idx;
                    _scale = 1.0;
                  });
                },
                itemBuilder: (context, idx) {
                  return InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 3.0,
                    onInteractionUpdate: (details) {
                      setState(() {
                        _scale = details.scale;
                      });
                    },
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
                        padding: const EdgeInsets.all(16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Hero(
                            tag: widget.images[idx],
                            child: Image.asset(
                              widget.images[idx],
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade900,
                                child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 64),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Close Overlay Button
          Positioned(
            top: 24,
            right: 24,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5),
                    border: Border.all(color: primary.withOpacity(0.6), width: 1.5),
                  ),
                  child: const Icon(Icons.close_sharp, color: Colors.white, size: 22),
                ),
              ),
            ),
          ),

          // Left/Right Navigation controls for desktop users
          if (Responsive.isDesktop(context)) ...[
            if (_currentIndex > 0)
              Positioned(
                left: 32,
                top: 0,
                bottom: 0,
                child: Center(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _prev,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.4),
                          border: Border.all(color: primary.withOpacity(0.3), width: 1.2),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_sharp, color: primary, size: 24),
                      ),
                    ),
                  ),
                ),
              ),
            if (_currentIndex < widget.images.length - 1)
              Positioned(
                right: 32,
                top: 0,
                bottom: 0,
                child: Center(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _next,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.4),
                          border: Border.all(color: primary.withOpacity(0.3), width: 1.2),
                        ),
                        child: Icon(Icons.arrow_forward_ios_sharp, color: primary, size: 24),
                      ),
                    ),
                  ),
                ),
              ),
          ],

          // Footer info badge showing current image index
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.black.withOpacity(0.6),
                  border: Border.all(color: primary.withOpacity(0.4), width: 1),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.images.length}',
                  style: TextStyle(
                    fontFamily: manager.bodyFont,
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
