import 'package:flutter/material.dart';
import '../services/config_manager.dart';
import '../core/localization.dart';
import 'glass_card.dart';
import 'animated_button.dart';

class LocationCard extends StatelessWidget {
  final String venueName;
  final String address;
  final String dateText;
  final String timeText;
  final VoidCallback onGetDirections;

  const LocationCard({
    super.key,
    required this.venueName,
    required this.address,
    required this.dateText,
    required this.timeText,
    required this.onGetDirections,
  });

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final lang = manager.selectedLanguage;
    final primary = manager.primaryColor;
    final secondary = manager.secondaryColor;

    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.location_on_outlined, color: primary, size: 40),
          const SizedBox(height: 16),
          Text(
            venueName,
            style: TextStyle(
              fontFamily: manager.headingFont,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            address,
            style: TextStyle(
              fontFamily: manager.bodyFont,
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primary.withOpacity(0.25), width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    icon: Icons.calendar_month_outlined,
                    label: Localization.get(lang, 'location_date_label'),
                    value: dateText,
                    color: secondary,
                  ),
                ),
                Container(width: 1, height: 44, color: primary.withOpacity(0.25)),
                Expanded(
                  child: _InfoChip(
                    icon: Icons.access_time_rounded,
                    label: Localization.get(lang, 'location_time_label'),
                    value: timeText,
                    color: secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AnimatedButton(
            label: Localization.get(lang, 'btn_directions'),
            icon: Icons.directions_outlined,
            onPressed: onGetDirections,
          ),
        ],
      ),
    );
  }
}

/// A clear, boxed date/time chip — icon on top, small label, then a bold,
/// legible value. Used to make the engagement date and time impossible to
/// miss (previously they were a single small line easy to overlook).
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final lang = manager.selectedLanguage;
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: manager.bodyFont,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black45,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: manager.bodyFont,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
          textDirection: lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        ),
      ],
    );
  }
}
