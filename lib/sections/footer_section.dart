import 'package:flutter/material.dart';
import '../services/config_manager.dart';
import '../core/localization.dart';
import '../utils/launch_url.dart';
import '../widgets/social_button.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final lang = manager.selectedLanguage;
    final textOnDark = Colors.white;

    // Official brand colors so the buttons read instantly as WhatsApp / Facebook
    const whatsappGreen = Color(0xFF25D366);
    const facebookBlue = Color(0xFF1877F2);

    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [


          // Prominent developer brand credit — M2F
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.lightBlue.withOpacity(0.38),
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
          Container(height: 1, width: 70, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 32),
          Text(
            'M2F',
            style: TextStyle(
              fontFamily: manager.headingFont,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
    );
  }
}
