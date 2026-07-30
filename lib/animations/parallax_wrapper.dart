import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Moves [child] at a fraction ([speed]) of the given [scrollOffset]
/// to create a parallax feel. Pass the ScrollController's offset
/// notifier from the parent so only this widget rebuilds on scroll.
class ParallaxWrapper extends StatelessWidget {
  final Widget child;
  final ValueListenable<double> scrollOffset;
  final double speed;

  const ParallaxWrapper({
    super.key,
    required this.child,
    required this.scrollOffset,
    this.speed = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: scrollOffset,
      builder: (context, offset, cachedChild) {
        return Transform.translate(
          offset: Offset(0, offset * speed * -1),
          child: cachedChild,
        );
      },
      child: child,
    );
  }
}
