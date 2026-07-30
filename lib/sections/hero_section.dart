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

    final frameWidth = isMobile ? 200.0 : 270.0;
    final frameHeight = frameWidth; // circular medallion — 1:1

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

            // Luxury Emerald-Navy Vignette Overlay — keeps white text crisp
            // while tinting the whole hero with the new deep jewel-tone palette
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF061815).withOpacity(0.85),
                      const Color(0xFF0B2E23).withOpacity(0.55),
                      const Color(0xFF04120F).withOpacity(0.88),
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

            // Art-Deco Corner Brackets (replaces the full rectangle border
            // from the original design — a distinct visual signature for
            // this variant)
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 14 : 26),
                child: Stack(
                  children: [
                    Align(alignment: Alignment.topLeft, child: _CornerBracket(color: primary)),
                    Align(
                      alignment: Alignment.topRight,
                      child: Transform.flip(flipX: true, child: _CornerBracket(color: primary)),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Transform.flip(flipY: true, child: _CornerBracket(color: primary)),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Transform.flip(
                        flipX: true,
                        flipY: true,
                        child: _CornerBracket(color: primary),
                      ),
                    ),
                  ],
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

/// The couple's photo shown inside a circular "medallion" frame with a
/// double gold ring and soft glow — this variant's signature shape,
/// replacing the original's arched cathedral frame for a distinct look.
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
      width: width,
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: frameColor.withOpacity(0.9), width: 2),
        boxShadow: [
          BoxShadow(
            color: frameColor.withOpacity(0.35),
            blurRadius: 30,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: frameColor.withOpacity(0.4), width: 1),
        ),
        child: ClipOval(
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
    );
  }
}

/// A slim L-shaped corner ornament (art-deco style) drawn at each of the
/// hero's four corners — this variant's replacement for the original's
/// full double-rectangle border.
class _CornerBracket extends StatelessWidget {
  final Color color;
  const _CornerBracket({required this.color});

  @override
  Widget build(BuildContext context) {
    const double size = 46;
    return CustomPaint(
      size: const Size(size, size),
      painter: _CornerBracketPainter(color: color),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  final Color color;
  _CornerBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final outerPaint = Paint()
      ..color = color.withOpacity(0.75)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final innerPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.55)
        ..lineTo(0, 0)
        ..lineTo(size.width * 0.55, 0),
      outerPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(8, size.height * 0.4)
        ..lineTo(8, 8)
        ..lineTo(size.width * 0.4, 8),
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) =>
      oldDelegate.color != color;
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