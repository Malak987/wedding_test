import 'package:flutter/material.dart';
import '../services/config_manager.dart';
import 'custom_divider.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// Optional overrides so sections with a dark backdrop (story,
  /// comments) can render the title in a light color while every
  /// other section keeps the default emerald-on-cream look.
  final Color? titleColor;
  final Color? subtitleColor;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.subtitleColor,
  });

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
            color: titleColor ?? secondary,
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
                color: subtitleColor ?? Colors.black54,
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
