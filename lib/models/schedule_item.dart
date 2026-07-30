import 'package:flutter/material.dart';

class ScheduleItem {
  final String time;
  final String title;

  /// IMPORTANT: use Material IconData, not emoji text.
  /// Custom fonts (Cairo/Playfair) have no emoji glyphs, so emoji
  /// characters trigger a "missing Noto font" warning/tofu box on
  /// web. Material icons are bundled with Flutter and always render.
  final IconData icon;

  const ScheduleItem({
    required this.time,
    required this.title,
    this.icon = Icons.favorite_border,
  });
}

/// Sample schedule data. Move to dashboard/ if the client needs
/// to edit it without touching models.
const List<ScheduleItem> defaultSchedule = [
  ScheduleItem(time: '6:30 م', title: 'استقبال الضيوف', icon: Icons.local_florist_outlined),
  ScheduleItem(time: '7:00 م', title: 'دخول العروسين', icon: Icons.favorite_border),
  ScheduleItem(time: '8:00 م', title: 'حفل العشاء', icon: Icons.restaurant_outlined),
  ScheduleItem(time: '9:30 م', title: 'قطع الكيكة', icon: Icons.cake_outlined),
];
