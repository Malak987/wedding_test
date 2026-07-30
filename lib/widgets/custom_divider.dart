import 'package:flutter/material.dart';
import '../services/config_manager.dart';

class CustomDivider extends StatelessWidget {
  final double width;

  const CustomDivider({super.key, this.width = 60});

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final primary = manager.primaryColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 24, height: 1.2, color: primary.withOpacity(0.5)),
        const SizedBox(width: 10),
        Icon(Icons.favorite_sharp, size: 14, color: primary),
        const SizedBox(width: 10),
        Container(width: 24, height: 1.2, color: primary.withOpacity(0.5)),
      ],
    );
  }
}
