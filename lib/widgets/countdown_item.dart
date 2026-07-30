import 'package:flutter/material.dart';
import '../services/config_manager.dart';
import 'glass_card.dart';

class CountdownItemWidget extends StatelessWidget {
  final int value;
  final String label;

  const CountdownItemWidget({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final primary = manager.primaryColor;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              fontFamily: manager.headingFont,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: primary,
              shadows: [
                Shadow(color: primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: manager.bodyFont,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: manager.secondaryColor.withOpacity(0.8),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
