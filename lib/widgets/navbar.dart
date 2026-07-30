import 'package:flutter/material.dart';
import '../services/config_manager.dart';
import '../core/localization.dart';

/// A minimal, centered floating navigation pill. No logo/monogram and no
/// language switcher — just the section links, centered, wrapping onto a
/// second line gracefully on narrow screens instead of being hidden.
class FloatingNavbar extends StatelessWidget {
  final VoidCallback onScrollToStory;
  final VoidCallback onScrollToCountdown;
  final VoidCallback onScrollToGallery;
  final VoidCallback onScrollToVenue;
  final VoidCallback onScrollToSchedule;

  const FloatingNavbar({
    super.key,
    required this.onScrollToStory,
    required this.onScrollToCountdown,
    required this.onScrollToGallery,
    required this.onScrollToVenue,
    required this.onScrollToSchedule,
  });

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final lang = manager.selectedLanguage;
    final primary = manager.primaryColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: primary.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 4,
          children: [
            if (manager.showStory)
              _buildNavLink(Localization.get(lang, 'nav_story'), onScrollToStory, manager),
            if (manager.showCountdown)
              _buildNavLink(Localization.get(lang, 'nav_countdown'), onScrollToCountdown, manager),
            if (manager.showGallery)
              _buildNavLink(Localization.get(lang, 'nav_gallery'), onScrollToGallery, manager),
            if (manager.showLocation)
              _buildNavLink(Localization.get(lang, 'nav_location'), onScrollToVenue, manager),
            if (manager.showSchedule)
              _buildNavLink(Localization.get(lang, 'nav_schedule'), onScrollToSchedule, manager),
          ],
        ),
      ),
    );
  }

  Widget _buildNavLink(String label, VoidCallback onTap, AppConfigManager manager) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: manager.bodyFont,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
