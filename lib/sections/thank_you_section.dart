import 'package:flutter/material.dart';
import '../services/config_manager.dart';
import '../core/localization.dart';
import '../core/responsive.dart';
import '../core/constants.dart';
import '../utils/launch_url.dart';
import '../widgets/custom_divider.dart';
import '../animations/fade_in.dart';

class ThankYouSection extends StatelessWidget {
  const ThankYouSection({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final lang = manager.selectedLanguage;
    final textOnDark = Colors.white;

    return Container(
      width: double.infinity,
      color: Colors.black,
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
                color: manager.primaryColor,
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
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: manager.primaryColor, width: 1.4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.facebook_outlined, color: manager.primaryColor, size: 20),
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
    );
  }
}
