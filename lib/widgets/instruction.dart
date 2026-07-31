import 'package:flutter/material.dart';

class InstructionWidget extends StatefulWidget {
  final bool isReady;

  const InstructionWidget({super.key, this.isReady = true});

  @override
  State<InstructionWidget> createState() => _InstructionWidgetState();
}

class _InstructionWidgetState extends State<InstructionWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _arrowController;
  late final Animation<double> _arrowTranslation;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _arrowTranslation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );

    _arrowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goldColor = const Color(0xFFD4AF37);

    // While the seal video / audio are still preloading, show a clear
    // "preparing" state instead of an instruction that won't actually work
    // yet if the visitor taps it — this is what was causing the "stuck /
    // unresponsive" complaints during the first few seconds on the site.
    if (!widget.isReady) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Column(
          key: const ValueKey('preparing'),
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(goldColor.withOpacity(0.85)),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "جاري التحضير...",
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: goldColor.withOpacity(0.7),
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Column(
        key: const ValueKey('ready'),
        mainAxisSize: MainAxisSize.min,
        children: [
          // Luxury Instruction text
          Text(
            "Double Tap...!",
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: goldColor.withOpacity(0.85),
              letterSpacing: 2.0,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Elegant floating arrow
          AnimatedBuilder(
            animation: _arrowTranslation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0.0, _arrowTranslation.value),
                child: Icon(
                  Icons.keyboard_arrow_down_sharp,
                  color: goldColor.withOpacity(0.7),
                  size: 18,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}