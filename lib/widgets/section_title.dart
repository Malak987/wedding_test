import 'package:flutter/material.dart';
import '../services/config_manager.dart';
import 'custom_divider.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionTitle({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final secondary = manager.secondaryColor;

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: manager.headingFont,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: secondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const CustomDivider(),
        if (subtitle != null) ...[
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Text(
              subtitle!,
              style: TextStyle(
                fontFamily: manager.bodyFont,
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: Colors.black54,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}
