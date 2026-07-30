import 'package:flutter/material.dart';

enum SlideDirection { left, right, top, bottom }

class SlideIn extends StatefulWidget {
  final Widget child;
  final SlideDirection direction;
  final Duration duration;
  final Duration delay;

  const SlideIn({
    super.key,
    required this.child,
    this.direction = SlideDirection.bottom,
    this.duration = const Duration(milliseconds: 700),
    this.delay = Duration.zero,
  });

  @override
  State<SlideIn> createState() => _SlideInState();
}

class _SlideInState extends State<SlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;

  Offset get _begin {
    switch (widget.direction) {
      case SlideDirection.left:
        return const Offset(-0.3, 0);
      case SlideDirection.right:
        return const Offset(0.3, 0);
      case SlideDirection.top:
        return const Offset(0, -0.3);
      case SlideDirection.bottom:
        return const Offset(0, 0.3);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _offset = Tween<Offset>(begin: _begin, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
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
      opacity: _controller,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
