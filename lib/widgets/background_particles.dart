import 'dart:math';
import 'package:flutter/material.dart';
import '../services/config_manager.dart';

enum ParticleType {
  goldenDust,
  rosePetal,
  sparkle,
  softHeart,
}

class PremiumParticle {
  double x; // percentage 0.0 -> 1.0
  double y; // percentage 0.0 -> 1.0
  double size;
  double speed;
  double swaySpeed;
  double swayWidth;
  double rotation;
  double rotationSpeed;
  double opacity;
  ParticleType type;

  PremiumParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.swaySpeed,
    required this.swayWidth,
    required this.rotation,
    required this.rotationSpeed,
    required this.opacity,
    required this.type,
  });
}

class BackgroundParticles extends StatefulWidget {
  final int particleCount;
  final bool animateOnlyDownward;

  const BackgroundParticles({
    super.key,
    this.particleCount = 45,
    this.animateOnlyDownward = false,
  });

  @override
  State<BackgroundParticles> createState() => _BackgroundParticlesState();
}

class _BackgroundParticlesState extends State<BackgroundParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<PremiumParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Create a variety of particles
    for (int i = 0; i < widget.particleCount; i++) {
      final randType = _random.nextDouble();
      ParticleType type = ParticleType.goldenDust;
      if (randType < 0.3) {
        type = ParticleType.rosePetal;
      } else if (randType < 0.5) {
        type = ParticleType.sparkle;
      } else if (randType < 0.65) {
        type = ParticleType.softHeart;
      }

      _particles.add(PremiumParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 6 + 4,
        speed: _random.nextDouble() * 0.08 + 0.03,
        swaySpeed: _random.nextDouble() * 2 + 0.5,
        swayWidth: _random.nextDouble() * 0.04 + 0.01,
        rotation: _random.nextDouble() * pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 2,
        opacity: _random.nextDouble() * 0.5 + 0.2,
        type: type,
      ));
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final manager = AppConfigManager.instance;
          return CustomPaint(
            painter: _PremiumParticlePainter(
              _particles,
              _controller.value,
              manager.primaryColor,
              widget.animateOnlyDownward,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _PremiumParticlePainter extends CustomPainter {
  final List<PremiumParticle> particles;
  final double progress;
  final Color primaryColor;
  final bool animateOnlyDownward;

  _PremiumParticlePainter(
    this.particles,
    this.progress,
    this.primaryColor,
    this.animateOnlyDownward,
  );

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Calculate continuous anim offsets
      double dy;
      if (p.type == ParticleType.rosePetal || animateOnlyDownward) {
        // Drift downward
        dy = (p.y + progress * p.speed) % 1.0;
      } else {
        // Drift upward
        dy = (p.y - progress * p.speed) % 1.0;
      }

      // Horizontal sway (sine wave)
      final sway = sin(progress * pi * 2 * p.swaySpeed) * p.swayWidth;
      final dx = (p.x + sway) % 1.0;

      final posX = dx * size.width;
      final posY = dy * size.height;
      final rot = p.rotation + (progress * p.rotationSpeed * pi * 2);

      canvas.save();
      canvas.translate(posX, posY);
      canvas.rotate(rot);

      _drawParticle(canvas, p, primaryColor);

      canvas.restore();
    }
  }

  void _drawParticle(Canvas canvas, PremiumParticle p, Color mainColor) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    switch (p.type) {
      case ParticleType.goldenDust:
        // Soft glowing golden circle
        paint.color = mainColor.withOpacity(p.opacity * 0.4);
        canvas.drawCircle(Offset.zero, p.size * 0.5, paint);
        // Inner core
        paint.color = Colors.white.withOpacity(p.opacity * 0.8);
        canvas.drawCircle(Offset.zero, p.size * 0.2, paint);
        break;

      case ParticleType.rosePetal:
        // Elegant curved pink/ivory rose petal
        paint.color = const Color(0xFFFFB7B2).withOpacity(p.opacity * 0.6);
        final path = Path();
        path.moveTo(0, -p.size * 0.6);
        path.quadraticBezierTo(p.size * 0.5, -p.size * 0.3, p.size * 0.3, p.size * 0.5);
        path.quadraticBezierTo(0, p.size * 0.8, -p.size * 0.3, p.size * 0.5);
        path.quadraticBezierTo(-p.size * 0.5, -p.size * 0.3, 0, -p.size * 0.6);
        canvas.drawPath(path, paint);
        break;

      case ParticleType.sparkle:
        // 4-point golden star
        paint.color = const Color(0xFFFFDF7A).withOpacity(p.opacity * 0.8);
        final path = Path();
        final s = p.size * 0.7;
        path.moveTo(0, -s);
        path.quadraticBezierTo(0, 0, s, 0);
        path.quadraticBezierTo(0, 0, 0, s);
        path.quadraticBezierTo(0, 0, -s, 0);
        path.quadraticBezierTo(0, 0, 0, -s);
        canvas.drawPath(path, paint);
        break;

      case ParticleType.softHeart:
        // Delicate romance heart
        paint.color = const Color(0xFFFFCAD4).withOpacity(p.opacity * 0.5);
        final s = p.size * 0.5;
        final path = Path();
        path.moveTo(0, s * 0.35);
        path.cubicTo(-s * 0.4, -s * 0.4, -s * 1.1, -s * 0.15, -s * 1.1, s * 0.3);
        path.cubicTo(-s * 1.1, s * 0.75, -s * 0.3, s * 1.1, 0, s * 1.5);
        path.cubicTo(s * 0.3, s * 1.1, s * 1.1, s * 0.75, s * 1.1, s * 0.3);
        path.cubicTo(s * 1.1, -s * 0.15, s * 0.4, -s * 0.4, 0, s * 0.35);
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumParticlePainter oldDelegate) => true;
}
