import 'package:flutter/material.dart';

/// Breakpoints used across the whole app.
class Responsive {
  Responsive._();

  static const double mobileMax = 600;
  static const double tabletMax = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMax;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= mobileMax && w < tabletMax;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletMax;

  /// Returns one of [mobile]/[tablet]/[desktop] based on screen width.
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet ?? desktop;
    return mobile;
  }

  /// Horizontal content padding that scales with screen size.
  static double horizontalPadding(BuildContext context) => value<double>(
        context,
        mobile: 20,
        tablet: 48,
        desktop: 120,
      );

  /// Max content width to keep large screens readable.
  static double maxContentWidth(BuildContext context) => value<double>(
        context,
        mobile: double.infinity,
        tablet: 900,
        desktop: 1200,
      );
}
