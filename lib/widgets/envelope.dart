import 'package:flutter/material.dart';

class EnvelopeWidget extends StatelessWidget {
  final Widget child;

  const EnvelopeWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final goldColor = const Color(0xFFD4AF37);
    final ivory = const Color(0xFFF9F6F1);
    final softBeige = const Color(0xFFEFE7DA);

    return Container(
      width: 440,
      height: 300,
      decoration: BoxDecoration(
        color: ivory,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldColor.withOpacity(0.45), width: 1.5),
        boxShadow: [
          // Soft cascading physical card shadows
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: goldColor.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4), // Gold edge margin inlay
      child: Container(
        decoration: BoxDecoration(
          color: softBeige.withOpacity(0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: goldColor.withOpacity(0.15), width: 1.0),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Elegant Background Watermark/Texture
            Positioned.fill(
              child: Opacity(
                opacity: 0.04,
                child: GridPaper(
                  color: goldColor,
                  divisions: 1,
                  subdivisions: 1,
                  child: const SizedBox.shrink(),
                ),
              ),
            ),

            // Subtle classical golden corner accents
            Positioned(
              top: 12,
              left: 12,
              child: Icon(Icons.star_border, color: goldColor.withOpacity(0.35), size: 16),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Icon(Icons.star_border, color: goldColor.withOpacity(0.35), size: 16),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              child: Icon(Icons.star_border, color: goldColor.withOpacity(0.35), size: 16),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Icon(Icons.star_border, color: goldColor.withOpacity(0.35), size: 16),
            ),

            // Diagonal Paper Folding Lines (Simulated envelope folds)
            Positioned.fill(
              child: CustomPaint(
                painter: _EnvelopeFoldLinesPainter(goldColor.withOpacity(0.15)),
              ),
            ),

            // The Wax Seal child (passed dynamically)
            Center(child: child),
          ],
        ),
      ),
    );
  }
}

class _EnvelopeFoldLinesPainter extends CustomPainter {
  final Color foldColor;

  _EnvelopeFoldLinesPainter(this.foldColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = foldColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Diagonal lines from corners to center region (to simulate a physical folded envelope)
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.35, size.height * 0.45);

    path.moveTo(size.width, 0);
    path.lineTo(size.width * 0.65, size.height * 0.45);

    path.moveTo(0, size.height);
    path.lineTo(size.width * 0.35, size.height * 0.55);

    path.moveTo(size.width, size.height);
    path.lineTo(size.width * 0.65, size.height * 0.55);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
