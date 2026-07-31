import 'package:flutter/material.dart';
import '../services/config_manager.dart';
import '../core/localization.dart';
import '../core/responsive.dart';
import '../core/constants.dart';
import '../utils/launch_url.dart';
import '../widgets/custom_divider.dart';
import '../animations/fade_in.dart';

/// ============================================================
/// THANK YOU — "Midnight Emerald" variant
/// ============================================================
/// The closing section of the page, dressed in the theme's deep
/// emerald green (the dominant color) with soft ambient glows,
/// an antique-gold title, and a gold-ringed follow button.
/// ============================================================
class ThankYouSection extends StatelessWidget {
  const ThankYouSection({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final lang = manager.selectedLanguage;
    final textOnDark = Colors.white;

    // Palette — derived from the dashboard colors so the section
    // follows whatever is configured in the Admin Dashboard.
    final emerald = manager.secondaryColor; // deep emerald — the background
    final gold = manager.primaryColor; // antique gold — accents
    final emeraldDeep = Color.lerp(emerald, Colors.black, 0.4)!;
    final emeraldSoft = Color.lerp(emerald, Colors.white, 0.08)!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [emeraldSoft, emerald, emeraldDeep],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          // Soft ambient glows for depth
          Positioned(
            top: -110,
            left: -110,
            child: _GlowOrb(color: gold.withOpacity(0.16), size: 320),
          ),
          Positioned(
            bottom: -130,
            right: -100,
            child: _GlowOrb(color: Colors.white.withOpacity(0.07), size: 360),
          ),
          // Full-width so the centered Column stretches across the Stack
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.horizontalPadding(context),
                vertical: Responsive.value(
                  context,
                  mobile: AppConstants.sectionSpacingMobile,
                  desktop: AppConstants.sectionSpacing,
                ),
              ),
              child: FadeIn(
                child: Column(
                  children: [
                    Text(
                      Localization.get(lang, 'thank_you_title'),
                      style: TextStyle(
                        fontFamily: manager.headingFont,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: gold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const CustomDivider(),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Text(
                        Localization.get(lang, 'thank_you_desc'),
                        style: TextStyle(
                          fontFamily: manager.bodyFont,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: textOnDark.withOpacity(0.9),
                          height: 1.7,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => launchAppUrl(manager.facebookUrl),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            color: gold.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: gold, width: 1.4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.facebook_outlined, color: gold, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                Localization.get(lang, 'facebook_follow'),
                                style: TextStyle(
                                  fontFamily: manager.bodyFont,
                                  color: textOnDark,
                                  fontSize: 14,
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
            ),
          ),
        ],
      ),
    );
  }
}

/// A soft blurred circle used as ambient background decoration.
class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withOpacity(0.0)],
          ),
        ),
      ),
    );
  }
}
