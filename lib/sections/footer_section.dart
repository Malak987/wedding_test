import 'package:flutter/material.dart';
import '../services/config_manager.dart';
import '../core/localization.dart';
import '../utils/launch_url.dart';
import '../widgets/social_button.dart';

/// ============================================================
/// FOOTER — "Midnight Emerald" variant
/// ============================================================
/// Matches the thank-you section: the theme's deep emerald green as
/// a rich vertical gradient with soft ambient gold/white glows,
/// antique-gold accents on the brand text and hairline, and the
/// M2F developer credit glowing softly in gold.
/// ============================================================
class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

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

    // Official brand colors so the buttons read instantly as WhatsApp / Facebook
    const whatsappGreen = Color(0xFF25D366);
    const facebookBlue = Color(0xFF1877F2);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [emeraldDeep, emerald, emeraldDeep],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          // Soft ambient glows for depth
          Positioned(
            top: -100,
            right: -110,
            child: _GlowOrb(color: gold.withOpacity(0.15), size: 320),
          ),
          Positioned(
            bottom: -120,
            left: -100,
            child: _GlowOrb(color: Colors.white.withOpacity(0.06), size: 340),
          ),
          // Full-width so the centered Column stretches across the Stack
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                children: [
                  // Prominent developer brand credit — M2F
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: emeraldDeep, // deep emerald — same green as the section
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: gold.withOpacity(0.35),
                          blurRadius: 36,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/dev_logo.png',
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(width: 46, height: 46),
                    ),
                  ),

                  const SizedBox(height: 42),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SocialButton(
                        icon: Icons.chat_bubble_rounded,
                        label: lang == 'ar' ? 'واتساب' : 'WhatsApp',
                        color: whatsappGreen,
                        onTap: () => launchAppUrl('https://wa.me/${manager.whatsappNumber.replaceAll('+', '')}'),
                      ),
                      SocialButton(
                        icon: Icons.facebook_rounded,
                        label: lang == 'ar' ? 'فيسبوك' : 'Facebook',
                        color: facebookBlue,
                        onTap: () => launchAppUrl(manager.facebookUrl),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    Localization.get(lang, 'footer_text'),
                    style: TextStyle(
                      fontFamily: manager.bodyFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: textOnDark.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 36),
                  // Antique-gold hairline
                  Container(height: 1, width: 70, color: gold.withOpacity(0.35)),
                  const SizedBox(height: 32),
                  Text(
                    'M2F',
                    style: TextStyle(
                      fontFamily: manager.headingFont,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: gold,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lang == 'ar' ? 'تصميم وتطوير المواقع الرقمية' : 'Digital Web Design & Development',
                    style: TextStyle(
                      fontFamily: manager.bodyFont,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.55),
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'M2F © 2026 — ${lang == 'ar' ? 'جميع الحقوق محفوظة' : 'All rights reserved'}',
                    style: TextStyle(
                      fontFamily: manager.bodyFont,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.35),
                    ),
                  ),
                ],
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
