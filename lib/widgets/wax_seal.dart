import 'dart:math' as math;
import 'package:flutter/material.dart';

class WaxSealWidget extends StatefulWidget {
  final bool enabled;
  final VoidCallback onTap;

  const WaxSealWidget({
    super.key,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<WaxSealWidget> createState() => _WaxSealWidgetState();
}

class _WaxSealWidgetState extends State<WaxSealWidget> with TickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final AnimationController _compressController;
  late final AnimationController _particleController;

  bool _isHovered = false;
  bool _isPressed = false;
  bool _isCracked = false;

  final List<_WaxFragment> _fragments = [];

  @override
  void initState() {
    super.initState();

    // Shimmer sweep loop
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _shimmerController.repeat(period: const Duration(seconds: 4));

    // Compression click feedback
    _compressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Particle blast controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _compressController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (!widget.enabled || _isCracked) return;

    setState(() {
      _isCracked = true;
      _isPressed = true;
    });

    // 1. Generate wax fragment particles
    final rand = math.Random();
    _fragments.clear();
    for (int i = 0; i < 15; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = rand.nextDouble() * 120 + 60;
      _fragments.add(_WaxFragment(
        dx: math.cos(angle) * speed,
        dy: math.sin(angle) * speed,
        size: rand.nextDouble() * 4 + 2,
        rotation: rand.nextDouble() * math.pi * 2,
      ));
    }

    // 2. Play compression & fragment blast animations in parallel
    _compressController.forward().then((_) => _compressController.reverse());
    _particleController.forward();

    // 3. Short delay (200ms) to let user feel they broke the seal, then call parent
    await Future.delayed(const Duration(milliseconds: 200));
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final goldColor = const Color(0xFFD4AF37);
    final darkRed = const Color(0xFF6B1110); // Luxurious wax red
    final midRed = const Color(0xFF8A1412);
    final lightRed = const Color(0xFFA51B18);

    final hoverScale = _isCracked ? 0.92 : (_isHovered && widget.enabled ? 1.03 : 1.0);
    final compressScale = _isPressed ? 0.92 : 1.0;

    return MouseRegion(
      cursor: widget.enabled && !_isCracked ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onEnter: (_) {
        if (widget.enabled && !_isCracked) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        if (widget.enabled && !_isCracked) {
          setState(() => _isHovered = false);
        }
      },
      child: GestureDetector(
        onTap: _handleTap,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 1. Core Rotating/Shimmering Wax Seal Card
            AnimatedScale(
              scale: hoverScale * compressScale,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [lightRed, midRed, darkRed],
                    center: const Alignment(-0.15, -0.15),
                    radius: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                    if (_isHovered && widget.enabled && !_isCracked)
                      BoxShadow(
                        color: goldColor.withOpacity(0.35),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                child: ClipOval(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Organic Wax Outer Melted Border Ring
                      Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: darkRed.withOpacity(0.6), width: 3.5),
                        ),
                      ),

                      // EMBOSSED GOLD MONOGRAM FRAME (SM initials)
                      Container(
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: goldColor.withOpacity(0.45), width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "SM",
                          style: TextStyle(
                            fontFamily: 'Playfair',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: goldColor.withOpacity(0.9),
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.6),
                                offset: const Offset(1, 1),
                                blurRadius: 2.0,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Jagged gold cracks painted over monogram if cracked
                      if (_isCracked)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _WaxCracksPainter(goldColor),
                          ),
                        ),

                      // Linear golden Shimmer sweep animation
                      AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, child) {
                          final val = _shimmerController.value;
                          return Positioned.fill(
                            child: FractionalTranslation(
                              translation: Offset(val * 2.5 - 1.2, 0.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.0),
                                      Colors.white.withOpacity(0.18),
                                      goldColor.withOpacity(0.24),
                                      Colors.white.withOpacity(0.18),
                                      Colors.white.withOpacity(0.0),
                                    ],
                                    stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Outward Wax Fragment Blast Particles (Rendered only during tap)
            if (_isCracked)
              AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  final progress = _particleController.value;
                  if (progress >= 1.0) return const SizedBox.shrink();

                  return Stack(
                    alignment: Alignment.center,
                    children: List.generate(_fragments.length, (index) {
                      final f = _fragments[index];
                      final dx = f.dx * progress;
                      final dy = f.dy * progress;
                      final opacity = (1.0 - progress).clamp(0.0, 1.0);

                      return Transform.translate(
                        offset: Offset(dx, dy),
                        child: Transform.rotate(
                          angle: f.rotation + (progress * math.pi),
                          child: Opacity(
                            opacity: opacity,
                            child: Container(
                              width: f.size,
                              height: f.size,
                              decoration: BoxDecoration(
                                color: index % 3 == 0 ? goldColor : midRed,
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _WaxFragment {
  final double dx;
  final double dy;
  final double size;
  final double rotation;

  _WaxFragment({
    required this.dx,
    required this.dy,
    required this.size,
    required this.rotation,
  });
}

class _WaxCracksPainter extends CustomPainter {
  final Color crackColor;

  _WaxCracksPainter(this.crackColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = crackColor.withOpacity(0.85)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Jagged crack paths originating from the center
    path.moveTo(cx, cy);
    path.lineTo(cx + 12, cy - 8);
    path.lineTo(cx + 8, cy - 22);
    path.lineTo(cx + 22, cy - 28);

    path.moveTo(cx, cy);
    path.lineTo(cx - 14, cy + 6);
    path.lineTo(cx - 22, cy + 2);
    path.lineTo(cx - 30, cy + 18);

    path.moveTo(cx, cy);
    path.lineTo(cx + 10, cy + 12);
    path.lineTo(cx + 5, cy + 24);
    path.lineTo(cx + 20, cy + 32);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
