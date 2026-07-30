import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/config_manager.dart';

/// The site's shared "premium card" — used by the comments form, location
/// card, countdown tiles, and guest-gallery card. Redesigned for the
/// emerald/gold variant as a diagonally cut-corner "ticket" shape instead
/// of the original soft rounded rectangle, echoing the art-deco corner
/// brackets on the hero photo. Because every one of those sections shares
/// this single widget, changing it here reshapes the whole site at once.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius; // repurposed as the corner-cut size
  final double blur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.blur = 16,
  });

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final primary = manager.primaryColor;
    final cut = borderRadius;

    return ClipPath(
      clipper: _CutCornerClipper(cut),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          // Thin gold "frame" ring around the cut-corner shape
          padding: const EdgeInsets.all(1.4),
          color: primary.withOpacity(0.55),
          child: ClipPath(
            clipper: _CutCornerClipper(cut - 1.4),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  manager.accentColor.withOpacity(0.55),
                  Colors.white.withOpacity(0.55),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// An octagon-like "cut corner" shape — all four corners sliced diagonally
/// instead of rounded, giving the classic art-deco ticket/plaque silhouette.
class _CutCornerClipper extends CustomClipper<Path> {
  final double cut;
  const _CutCornerClipper(this.cut);

  @override
  Path getClip(Size size) {
    final c = cut.clamp(0, size.shortestSide / 2).toDouble();
    return Path()
      ..moveTo(c, 0)
      ..lineTo(size.width - c, 0)
      ..lineTo(size.width, c)
      ..lineTo(size.width, size.height - c)
      ..lineTo(size.width - c, size.height)
      ..lineTo(c, size.height)
      ..lineTo(0, size.height - c)
      ..lineTo(0, c)
      ..close();
  }

  @override
  bool shouldReclip(covariant _CutCornerClipper oldClipper) => oldClipper.cut != cut;
}