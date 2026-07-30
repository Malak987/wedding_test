import 'package:flutter/material.dart';

/// Simple fade+slide reveal for a headline string.
/// (A lighter alternative to a full typewriter effect, kept
/// dependency-free and cheap to rebuild.)
class AnimatedText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final Duration duration;
  final Duration delay;

  const AnimatedText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign = TextAlign.center,
    this.duration = const Duration(milliseconds: 900),
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Text(widget.text, style: widget.style, textAlign: widget.textAlign),
      ),
    );
  }
}
