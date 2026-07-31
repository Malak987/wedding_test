import 'package:flutter/material.dart';
import '../services/config_manager.dart';
import '../core/localization.dart';
import '../core/responsive.dart';
import '../core/constants.dart';
import '../widgets/section_title.dart';
import '../animations/fade_in.dart';

/// ============================================================
/// OUR STORY
/// ============================================================
/// Same light-emerald backdrop (`accentColor`) as the Gallery and
/// Memories sections for a consistent rhythm through the page.
/// The deep emerald ("الأخضر القرمزي") stays clearly visible in the
/// iconography: the quote emblem, the drag-handle icon, the hairline,
/// and the couple's sign-off — while antique gold frames the photo.
/// ============================================================
class StorySection extends StatelessWidget {
  const StorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final lang = manager.selectedLanguage;
    final isDesktop = Responsive.isDesktop(context);

    // Palette — derived from the dashboard colors, so everything here
    // still follows whatever is configured in the Admin Dashboard.
    final emerald = manager.secondaryColor; // deep emerald — visible accents
    final gold = manager.primaryColor; // antique gold — photo frame + handle

    // The couple's own photos: as kids, and as they are today.
    const String youngImg = 'assets/images/story_young.png';
    const String nowImg = 'assets/images/story_now.png';

    final textColumn = FadeIn(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: emerald.withOpacity(0.16), width: 1),
          boxShadow: [
            BoxShadow(
              color: emerald.withOpacity(0.10),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Deep-emerald quote emblem — the green "stamp" of the section
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: emerald.withOpacity(0.10),
                border: Border.all(color: emerald.withOpacity(0.4), width: 1.2),
              ),
              child: Icon(
                Icons.format_quote_rounded,
                color: emerald,
                size: 26,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              manager.storyText,
              style: TextStyle(
                fontFamily: manager.bodyFont,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                height: 1.9,
              ),
              textAlign: isDesktop ? TextAlign.start : TextAlign.center,
            ),
            const SizedBox(height: 22),
            // Thin emerald hairline above the sign-off
            Container(width: 44, height: 1.4, color: emerald.withOpacity(0.55)),
            const SizedBox(height: 14),
            Text(
              "— ${manager.groomName} & ${manager.brideName}",
              style: TextStyle(
                fontFamily: manager.headingFont,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: emerald, // deep emerald sign-off
                fontStyle: FontStyle.italic,
              ),
              textAlign: isDesktop ? TextAlign.start : TextAlign.center,
            ),
          ],
        ),
      ),
    );

    final sliderColumn = FadeIn(
      child: Column(
        children: [
          _BeforeAfterSlider(
            youngImage: youngImg,
            nowImage: nowImg,
            accentColor: gold,
            iconColor: emerald,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swipe_outlined, size: 16, color: emerald),
              const SizedBox(width: 6),
              Text(
                Localization.get(lang, 'story_hint'),
                style: TextStyle(
                  fontFamily: manager.bodyFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Container(
      // Same light-green background as Gallery + Memories sections
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
                title: Localization.get(lang, 'story_title'),
                subtitle: Localization.get(lang, 'story_subtitle'),
              ),
              const SizedBox(height: 48),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: sliderColumn),
                    const SizedBox(width: 64),
                    Expanded(child: textColumn),
                  ],
                )
              else
                Column(
                  children: [
                    sliderColumn,
                    const SizedBox(height: 36),
                    textColumn,
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// An interactive "then & now" reveal: drag (or tap) the handle in the
/// middle — dragging right reveals more of the couple's childhood photo,
/// dragging left reveals more of them today. Framed with a gold hairline
/// and a gold drag handle carrying the deep-emerald arrows.
class _BeforeAfterSlider extends StatefulWidget {
  final String youngImage;
  final String nowImage;
  final Color accentColor; // gold — frame + handle gradient + badge outlines
  final Color iconColor; // deep emerald — drag-handle arrows + shadow tint

  const _BeforeAfterSlider({
    required this.youngImage,
    required this.nowImage,
    required this.accentColor,
    required this.iconColor,
  });

  @override
  State<_BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<_BeforeAfterSlider> {
  double _ratio = 0.5;

  void _updateRatio(double dx, double width) {
    setState(() {
      _ratio = (dx / width).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              // Gold hairline frame, fading diagonally for a premium feel
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.accentColor.withOpacity(0.95),
                  widget.accentColor.withOpacity(0.25),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.iconColor.withOpacity(0.22),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (details) => _updateRatio(details.localPosition.dx, width),
                onTapDown: (details) => _updateRatio(details.localPosition.dx, width),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Bottom layer: the couple today — always fully visible
                    Image.asset(
                      widget.nowImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade300),
                    ),

                    // Top layer: childhood photo, clipped from the left up to the handle
                    ClipRect(
                      clipper: _LeftClipper(_ratio),
                      child: Image.asset(
                        widget.youngImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade400),
                      ),
                    ),

                    // Divider line
                    Positioned(
                      left: (_ratio * width) - 1,
                      top: 0,
                      bottom: 0,
                      child: Container(width: 2, color: Colors.white.withOpacity(0.95)),
                    ),

                    // Drag handle — gold gradient circle with emerald arrows
                    Positioned(
                      left: (_ratio * width) - 23,
                      top: (height / 2) - 23,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.lerp(widget.accentColor, Colors.white, 0.35)!,
                              widget.accentColor,
                            ],
                          ),
                          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(Icons.compare_arrows_rounded, color: widget.iconColor, size: 22),
                      ),
                    ),

                    // "Then" badge
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: _Badge(text: 'زمان', color: widget.accentColor),
                    ),

                    // "Now" badge
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: _Badge(text: 'دلوقتي', color: widget.accentColor),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.7), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Clips its child to only the left portion of the available width, up to
/// [ratio] (0..1) of the total width.
class _LeftClipper extends CustomClipper<Rect> {
  final double ratio;
  _LeftClipper(this.ratio);

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * ratio, size.height);

  @override
  bool shouldReclip(covariant _LeftClipper oldClipper) => oldClipper.ratio != ratio;
}
