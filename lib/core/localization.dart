import 'package:flutter/material.dart';

class L10n {
  final String code;
  final String name;
  final TextDirection direction;

  const L10n({
    required this.code,
    required this.name,
    required this.direction,
  });

  static const List<L10n> supported = [
    L10n(code: 'ar', name: 'العربية', direction: TextDirection.rtl),
    L10n(code: 'en', name: 'English', direction: TextDirection.ltr),
  ];
}

class Localization {
  static const Map<String, Map<String, String>> _dict = {
    'ar': {
      'invite_title': 'دعوة خطوبة',
      'invite_desc': 'بكل حب وسعادة، ندعوكم لمشاركتنا فرحة خطوبتنا، ونتشرف بتواجدكم معنا في هذه اللحظة الغالية على قلوبنا.',
      'hero_cta': 'تفاصيل الخطوبة',
      'story_title': 'قصتنا',
      'story_subtitle': 'كيف بدأت حكايتنا',
      'story_hint': 'اسحب الشريط لتشاهد رحلتنا',
      'countdown_title': 'العد التنازلي',
      'countdown_days': 'يوم',
      'countdown_hours': 'ساعة',
      'countdown_minutes': 'دقيقة',
      'countdown_seconds': 'ثانية',
      'countdown_finished': 'حان الوقت السعيد! 🌸',
      'location_title': 'مكان الحفل',
      'location_date_label': 'التاريخ',
      'location_time_label': 'الموعد',
      'btn_directions': 'احصل على الاتجاهات',
      'schedule_title': 'برنامج الخطوبة',
      'schedule_subtitle': 'تفاصيل يوم لا يُنسى، خطوة بخطوة',
      'thank_you_title': 'شكراً لكم',
      'thank_you_desc': 'شكراً من القلب لكل من سيشاركنا فرحة هذا اليوم، تواجدكم معنا هو أجمل هدية نتمناها.',
      'facebook_follow': 'تابعونا على فيسبوك',
      'footer_text': 'صُممت هذه الدعوة بكل حب © 2026',
      'nav_story': 'قصتنا',
      'nav_countdown': 'العد التنازلي',
      'nav_gallery': 'الألبوم',
      'gallery_subtitle': 'لقطات نحتفظ بها لتبقى ذكرى خالدة',
      'nav_location': 'المكان',
      'nav_schedule': 'البرنامج',
    },
    'en': {
      'invite_title': 'Engagement Invitation',
      'invite_desc': 'With deep love and happiness, we invite you to share in the joy of our engagement, and we would be honored by your presence on this most cherished day.',
      'hero_cta': 'Engagement Details',
      'story_title': 'Our Story',
      'story_subtitle': 'How it all began',
      'story_hint': 'Drag the slider to see our journey',
      'countdown_title': 'The Countdown',
      'countdown_days': 'Days',
      'countdown_hours': 'Hours',
      'countdown_minutes': 'Mins',
      'countdown_seconds': 'Secs',
      'countdown_finished': 'The Happy Time Has Come! 🌸',
      'location_title': 'The Venue',
      'location_date_label': 'Date',
      'location_time_label': 'Time',
      'btn_directions': 'Get Directions',
      'schedule_title': 'The Engagement Schedule',
      'schedule_subtitle': 'The details of an unforgettable day',
      'thank_you_title': 'Thank You',
      'thank_you_desc': 'From the bottom of our hearts, thank you to everyone joining us for this special day — your presence is the greatest gift we could ask for.',
      'facebook_follow': 'Follow Us on Facebook',
      'footer_text': 'Designed with love © 2026',
      'nav_story': 'Story',
      'nav_countdown': 'Countdown',
      'nav_gallery': 'Gallery',
      'gallery_subtitle': 'Moments we\'ll treasure forever',
      'nav_location': 'Venue',
      'nav_schedule': 'Schedule',
    }
  };

  static String get(String langCode, String key) {
    return _dict[langCode]?[key] ?? key;
  }
}
