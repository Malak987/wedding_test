import 'package:flutter/material.dart';

class OpenInvitationButton extends StatefulWidget {
  final bool isLoaded;
  final VoidCallback onTap;

  const OpenInvitationButton({
    super.key,
    required this.isLoaded,
    required this.onTap,
  });

  @override
  State<OpenInvitationButton> createState() => _OpenInvitationButtonState();
}

class _OpenInvitationButtonState extends State<OpenInvitationButton> with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _glowAnimation = Tween<double>(begin: 4.0, end: 18.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Repeat breathing glow animation when button is loaded/enabled
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goldColor = const Color(0xFFD4AF37); // Champagne Gold
    final deepBrown = const Color(0xFF4A3B2E); // Deep Brown

    final enabled = widget.isLoaded;
    final scale = _isPressed ? 0.94 : (_isHovered && enabled ? 1.06 : 1.0);

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) {
          if (enabled) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (enabled) {
            setState(() => _isPressed = false);
            widget.onTap();
          }
        },
        onTapCancel: () {
          if (enabled) setState(() => _isPressed = false);
        },
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              final glowRadius = enabled ? (_isHovered ? 24.0 : _glowAnimation.value) : 0.0;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                decoration: BoxDecoration(
                  // Glassmorphic translucent center
                  color: enabled
                      ? Colors.white.withOpacity(_isHovered ? 0.25 : 0.12)
                      : Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: enabled
                        ? goldColor.withOpacity(_isHovered ? 0.95 : 0.6)
                        : Colors.white24,
                    width: 1.5,
                  ),
                  boxShadow: [
                    // Dynamic soft glowing gold shadow
                    if (enabled)
                      BoxShadow(
                        color: goldColor.withOpacity(_isHovered ? 0.45 : 0.22),
                        blurRadius: glowRadius,
                        spreadRadius: _isHovered ? 3 : 1,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      enabled ? "Open Invitation" : "Preloading...",
                      style: TextStyle(
                        fontFamily: 'Playfair',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: enabled ? goldColor : Colors.white38,
                        letterSpacing: 2.0,
                        shadows: enabled
                            ? [
                          Shadow(
                            color: goldColor.withOpacity(0.4),
                            blurRadius: 10,
                          )
                        ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Micro-interaction spinner or card icon
                    if (!enabled)
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: goldColor.withOpacity(0.4),
                        ),
                      )
                    else
                      Icon(
                        Icons.mark_email_unread_outlined,
                        color: goldColor,
                        size: 18,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
