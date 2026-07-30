import 'package:flutter/material.dart';
import '../services/config_manager.dart';
import '../core/localization.dart';
import '../core/responsive.dart';
import '../core/constants.dart';
import '../widgets/section_title.dart';
import '../widgets/schedule_card.dart';
import '../animations/slide_in.dart';
import '../models/schedule_item.dart';

class ScheduleSection extends StatelessWidget {
  const ScheduleSection({super.key});

  List<ScheduleItem> _getLocalizedSchedule(String langCode) {
    if (langCode == 'en') {
      return [
        const ScheduleItem(time: '7:00 PM', title: 'Engagement Begins', icon: Icons.favorite_border),
        const ScheduleItem(time: '12:00 AM', title: 'End of the Celebration', icon: Icons.nightlight_round),
      ];
    }
    // Arabic
    return [
      const ScheduleItem(time: '7:00 م', title: 'بداية حفل الخطوبة', icon: Icons.favorite_border),
      const ScheduleItem(time: '12:00 ص', title: 'ختام السهرة', icon: Icons.nightlight_round),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final lang = manager.selectedLanguage;
    final schedule = _getLocalizedSchedule(lang);

    return Container(
      color: manager.accentColor,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.horizontalPadding(context),
        vertical: Responsive.value(
          context,
          mobile: AppConstants.sectionSpacingMobile,
          desktop: AppConstants.sectionSpacing,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
          child: Column(
            children: [
              SectionTitle(
                title: Localization.get(lang, 'schedule_title'),
                subtitle: Localization.get(lang, 'schedule_subtitle'),
              ),
              const SizedBox(height: 48),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: List.generate(schedule.length, (index) {
                    final isLast = index == schedule.length - 1;
                    return SlideIn(
                      direction: SlideDirection.right,
                      delay: Duration(milliseconds: 100 * index),
                      child: ScheduleCard(item: schedule[index], isLast: isLast),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
