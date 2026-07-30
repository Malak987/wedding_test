import 'package:flutter/material.dart';
import '../services/config_manager.dart';
import '../core/localization.dart';
import '../core/responsive.dart';
import '../core/constants.dart';
import '../utils/countdown_timer.dart';
import '../widgets/countdown_item.dart';
import '../widgets/section_title.dart';
import '../animations/fade_in.dart';

class CountdownSection extends StatefulWidget {
  const CountdownSection({super.key});

  @override
  State<CountdownSection> createState() => _CountdownSectionState();
}

class _CountdownSectionState extends State<CountdownSection> {
  CountdownTimer? _timer;
  String? _currentTargetIso;

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  void _initTimer() {
    final target = AppConfigManager.instance.countdownTarget;
    _currentTargetIso = target;
    _timer?.dispose();

    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(target);
    } catch (e) {
      debugPrint('Error parsing countdown date, using fallback: $e');
      parsedDate = DateTime.now().add(const Duration(days: 90));
    }

    _timer = CountdownTimer(parsedDate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-initialize if target changes via Dashboard live updates
    final target = AppConfigManager.instance.countdownTarget;
    if (_currentTargetIso != target) {
      _initTimer();
    }
  }

  @override
  void dispose() {
    _timer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final lang = manager.selectedLanguage;
    final primary = manager.primaryColor;

    return Container(
      width: double.infinity,
      color: manager.secondaryColor.withOpacity(0.04),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.horizontalPadding(context),
        vertical: Responsive.value(
          context,
          mobile: AppConstants.sectionSpacingMobile,
          desktop: AppConstants.sectionSpacing,
        ),
      ),
      child: Column(
        children: [
          SectionTitle(
            title: Localization.get(lang, 'countdown_title'),
            subtitle: manager.eventDateLine,
          ),
          const SizedBox(height: 40),
          FadeIn(
            delay: const Duration(milliseconds: 200),
            child: _timer == null
                ? const CircularProgressIndicator()
                : ValueListenableBuilder<CountdownValue>(
                    valueListenable: _timer!.value,
                    builder: (context, value, _) {
                      if (value.finished) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.12),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            border: Border.all(color: primary.withOpacity(0.3), width: 1),
                          ),
                          child: Text(
                            Localization.get(lang, 'countdown_finished'),
                            style: TextStyle(
                              fontFamily: manager.headingFont,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return Directionality(
                        textDirection: TextDirection.ltr,
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: [
                            CountdownItemWidget(
                              value: value.days,
                              label: Localization.get(lang, 'countdown_days'),
                            ),
                            CountdownItemWidget(
                              value: value.hours,
                              label: Localization.get(lang, 'countdown_hours'),
                            ),
                            CountdownItemWidget(
                              value: value.minutes,
                              label: Localization.get(lang, 'countdown_minutes'),
                            ),
                            CountdownItemWidget(
                              value: value.seconds,
                              label: Localization.get(lang, 'countdown_seconds'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
