import 'package:flutter/material.dart';
import '../services/config_manager.dart';
import '../core/localization.dart';
import '../core/responsive.dart';
import '../core/constants.dart';
import '../widgets/section_title.dart';
import '../animations/fade_in.dart';

class StorySection extends StatelessWidget {
  const StorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final lang = manager.selectedLanguage;
    final isDesktop = Responsive.isDesktop(context);

    // The couple's own photos: as kids, and as they are today.
    const String youngImg = 'assets/images/story_young.png';
    const String nowImg = 'assets/images/story_now.png';

    final textColumn = FadeIn(
      child: Column(
        crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.spa_outlined,
            color: manager.primaryColor,
            size: 32,
          ),
          const SizedBox(height: 16),
          Text(
            manager.storyText,
            style: TextStyle(
              fontFamily: manager.bodyFont,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
              height: 1.8,
            ),
            textAlign: isDesktop ? TextAlign.start : TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Subtle romantic sign-off
          Text(
            "— ${manager.groomName} & ${manager.brideName}",
            style: TextStyle(
              fontFamily: manager.headingFont,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: manager.primaryColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );

    final sliderColumn = FadeIn(
      child: Column(
        children: [
          _BeforeAfterSlider(
            youngImage: youngImg,
            nowImage: nowImg,
            accentColor: manager.primaryColor,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swipe_outlined, size: 16, color: manager.primaryColor.withOpacity(0.8)),
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
/// dragging left reveals more of them today.
class _BeforeAfterSlider extends StatefulWidget {
  final String youngImage;
  final String nowImage;
  final Color accentColor;

  const _BeforeAfterSlider({
    required this.youngImage,
    required this.nowImage,
    required this.accentColor,
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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
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

                    // Drag handle
                    Positioned(
                      left: (_ratio * width) - 22,
                      top: (height / 2) - 22,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 3)),
                          ],
                        ),
                        child: Icon(Icons.compare_arrows_rounded, color: widget.accentColor, size: 22),
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
