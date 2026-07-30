/// Non-editable layout/animation constants.
/// (Colors/text/images live in lib/dashboard/, not here.)
class AppConstants {
  AppConstants._();

  static const double sectionSpacing = 96;
  static const double sectionSpacingMobile = 56;

  static const double borderRadiusSmall = 12;
  static const double borderRadiusMedium = 20;
  static const double borderRadiusLarge = 32;

  static const Duration animFast = Duration(milliseconds: 300);
  static const Duration animMedium = Duration(milliseconds: 600);
  static const Duration animSlow = Duration(milliseconds: 1000);

  static const double blurSigma = 12;
}
