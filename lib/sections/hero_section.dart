import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/config_manager.dart';
import '../core/localization.dart';
import '../core/responsive.dart';
import '../widgets/animated_text.dart';
import '../widgets/background_particles.dart';
import '../widgets/invite_button.dart';
import '../animations/fade_in.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onScrollToVenue;

  const HeroSection({super.key, required this.onScrollToVenue});

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final lang = manager.selectedLanguage;
    final primary = manager.primaryColor;
    final isMobile = Responsive.isMobile(context);

    // The couple's real photo — used twice: a soft blurred ambience behind
    // everything, and sharp inside the arched frame as the featured image.
    const String bgAsset = 'assets/images/story_now.png';

    final frameWidth = isMobile ? 190.0 : 260.0;
    final frameHeight = frameWidth * 1.32; // close to the photo's own 3:4 ratio

    return SizedBox(
      width: double.infinity,
      child: ConstrainedBox(
        // At least a full screen tall for a proper "hero" feel, but free to
        // grow if the content (photo + names + text) needs more room — this
        // avoids clipping/overflow on shorter phone screens.
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft, heavily blurred backdrop built from the couple's own photo
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                child: Image.asset(
                  bgAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          manager.secondaryColor.withOpacity(0.95),
                          manager.secondaryColor.withOpacity(0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Luxury Dark Vignette Overlay — keeps white text crisp and legible
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.72),
                      Colors.black.withOpacity(0.45),
                      Colors.black.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Glowing light particles
            const Positioned.fill(
              child: BackgroundParticles(particleCount: 30),
            ),

            // Premium Double Gold Border Frame (Luxury Engagement Aesthetic)
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 24),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: primary.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Hero Content Column
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.horizontalPadding(context),
                vertical: 32,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeIn(
                    delay: const Duration(milliseconds: 150),
                    child: Text(
                      Localization.get(lang, 'invite_title').toUpperCase(),
                      style: TextStyle(
                        fontFamily: manager.bodyFont,
                        fontSize: isMobile ? 13 : 17,
                        fontWeight: FontWeight.w400,
                        color: primary,
                        letterSpacing: isMobile ? 4 : 7,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeIn(
                    delay: const Duration(milliseconds: 250),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _OrnamentLine(color: primary),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.favorite, size: 10, color: primary.withOpacity(0.9)),
                        ),
                        _OrnamentLine(color: primary),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 22 : 28),

                  // Featured arched portrait of the couple
                  FadeIn(
                    delay: const Duration(milliseconds: 350),
                    child: _ArchedPortrait(
                      assetPath: bgAsset,
                      width: frameWidth,
                      height: frameHeight,
                      frameColor: primary,
                    ),
                  ),

                  SizedBox(height: isMobile ? 22 : 30),
                  AnimatedText(
                    text: manager.coupleNames,
                    delay: const Duration(milliseconds: 500),
                    style: TextStyle(
                      fontFamily: manager.headingFont,
                      fontSize: isMobile ? 40 : 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.15,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 18,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 18 : 22),
                  FadeIn(
                    delay: const Duration(milliseconds: 750),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Text(
                        Localization.get(lang, 'invite_desc'),
                        style: TextStyle(
                          fontFamily: manager.bodyFont,
                          fontSize: isMobile ? 14 : 17,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.95),
                          height: 1.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 32 : 42),
                  FadeIn(
                    delay: const Duration(milliseconds: 950),
                    child: InviteButton(
                      label: Localization.get(lang, 'hero_cta'),
                      icon: Icons.favorite_border_sharp,
                      onPressed: onScrollToVenue,
                    ),
                  ),
                  SizedBox(height: isMobile ? 24 : 32),
                  FadeIn(
                    delay: const Duration(milliseconds: 1300),
                    child: _ScrollDownHint(color: primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The couple's photo, shown in full (no ugly cropping — the frame's aspect
/// ratio matches the photo's own), inside an elegant arched frame with a
/// double gold border and soft glow — the classic invitation "portrait
/// medallion" look, built entirely from the couple's own picture.
class _ArchedPortrait extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;
  final Color frameColor;

  const _ArchedPortrait({
    required this.assetPath,
    required this.width,
    required this.height,
    required this.frameColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipPath(
        clipper: _ArchClipper(),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(color: frameColor.withOpacity(0.85)),
          child: ClipPath(
            clipper: _ArchClipper(),
            child: Container(
              padding: const EdgeInsets.all(3),
              color: Colors.white.withOpacity(0.9),
              child: ClipPath(
                clipper: _ArchClipper(),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: frameColor.withOpacity(0.2),
                    alignment: Alignment.center,
                    child: Icon(Icons.favorite, color: frameColor, size: 40),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A classic "cathedral arch" clip path — rectangular body with a rounded
/// semicircular top, the timeless shape used for wedding portrait frames.
class _ArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final archRadius = size.width / 2;
    final path = Path()
      ..moveTo(0, archRadius)
      ..arcToPoint(
        Offset(size.width, archRadius),
        radius: Radius.circular(archRadius),
        clockwise: true,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// A thin decorative line used either side of the small heart ornament
/// beneath the hero eyebrow text.
class _OrnamentLine extends StatelessWidget {
  final Color color;
  const _OrnamentLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 1,
      color: color.withOpacity(0.6),
    );
  }
}

/// A gentle pulsing "scroll to explore" hint, giving first-time visitors a
/// clear, professional cue that there is more content below.
class _ScrollDownHint extends StatefulWidget {
  final Color color;
  const _ScrollDownHint({required this.color});

  @override
  State<_ScrollDownHint> createState() => _ScrollDownHintState();
}

class _ScrollDownHintState extends State<_ScrollDownHint> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _offset = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offset.value),
          child: child,
        );
      },
      child: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: widget.color.withOpacity(0.8),
        size: 30,
      ),
    );
  }
}
