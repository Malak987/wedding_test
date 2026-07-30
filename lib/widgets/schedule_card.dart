import 'package:flutter/material.dart';
import '../services/config_manager.dart';
import '../models/schedule_item.dart';

class ScheduleCard extends StatelessWidget {
  final ScheduleItem item;
  final bool isLast;

  const ScheduleCard({super.key, required this.item, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final primary = manager.primaryColor;
    final secondary = manager.secondaryColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: primary, width: 1),
                ),
                alignment: Alignment.center,
                child: Icon(item.icon, size: 20, color: secondary),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: primary.withOpacity(0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.time,
                    style: TextStyle(
                      fontFamily: manager.bodyFont,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontFamily: manager.bodyFont,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
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
