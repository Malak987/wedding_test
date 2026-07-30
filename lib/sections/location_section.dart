import 'package:flutter/material.dart';
import '../services/config_manager.dart';
import '../core/localization.dart';
import '../core/responsive.dart';
import '../core/constants.dart';
import '../utils/launch_url.dart';
import '../widgets/section_title.dart';
import '../widgets/location_card.dart';
import '../animations/fade_in.dart';

class LocationSection extends StatelessWidget {
  const LocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = AppConfigManager.instance;
    final lang = manager.selectedLanguage;
    final isDesktop = Responsive.isDesktop(context);

    final detailsCard = FadeIn(
      child: LocationCard(
        venueName: manager.venueName,
        address: manager.venueAddress,
        dateText: manager.eventDateReadable,
        timeText: manager.eventTimeLine,
        onGetDirections: () => launchAppUrl(manager.googleMapsUrl),
      ),
    );

    // Simulated vector luxury map frame
    final simulatedMapFrame = FadeIn(
      delay: const Duration(milliseconds: 200),
      child: Container(
        height: isDesktop ? 350 : 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: manager.primaryColor.withOpacity(0.3), width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.5),
          child: Stack(
            children: [
              // Beautiful ivory map design background
              Positioned.fill(
                child: Container(
                  color: const Color(0xFFF6F3EC),
                  child: GridPaper(
                    color: manager.primaryColor.withOpacity(0.04),
                    divisions: 1,
                    subdivisions: 1,
                    child: Center(
                      child: Opacity(
                        opacity: 0.08,
                        child: Icon(Icons.map_sharp, size: 200, color: manager.secondaryColor),
                      ),
                    ),
                  ),
                ),
              ),

              // Roads and route markings
              Positioned.fill(
                child: CustomPaint(
                  painter: _LuxuryMapPainter(manager.primaryColor, manager.secondaryColor),
                ),
              ),

              // Interactive pulsing pin
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PulsingLocationPin(color: manager.primaryColor),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: manager.secondaryColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: manager.primaryColor, width: 1),
                      ),
                      child: Text(
                        manager.venueName,
                        style: TextStyle(
                          fontFamily: manager.bodyFont,
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Container(
      color: manager.accentColor,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.horizontalPadding(context),
        vertical: Responsive.value(
          context,
          mobile: AppConstants.sectionSpacingMobile,
          desktop: AppConstants.sectionSpacing,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
          child: Column(
            children: [
              SectionTitle(
                title: Localization.get(lang, 'location_title'),
                subtitle: manager.eventDateLine,
              ),
              const SizedBox(height: 48),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: detailsCard),
                    const SizedBox(width: 48),
                    Expanded(child: simulatedMapFrame),
                  ],
                )
              else
                Column(
                  children: [
                    detailsCard,
                    const SizedBox(height: 28),
                    simulatedMapFrame,
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LuxuryMapPainter extends CustomPainter {
  final Color primary;
  final Color secondary;

  _LuxuryMapPainter(this.primary, this.secondary);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Roads lines
    paint.color = primary.withOpacity(0.12);
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.5), paint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.5, size.height), paint);
    canvas.drawLine(Offset(0, size.height * 0.8), Offset(size.width, size.height * 0.7), paint);

    // Decorative route curve
    paint.color = primary.withOpacity(0.35);
    paint.strokeWidth = 4;
    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.9);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.4, size.width * 0.5, size.height * 0.5);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PulsingLocationPin extends StatefulWidget {
  final Color color;

  const _PulsingLocationPin({required this.color});

  @override
  State<_PulsingLocationPin> createState() => _PulsingLocationPinState();
}

class _PulsingLocationPinState extends State<_PulsingLocationPin> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _scale = Tween<double>(begin: 0.8, end: 2.2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacity = Tween<double>(begin: 0.6, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulse ring
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Transform.scale(
              scale: _scale.value,
              child: Opacity(
                opacity: _opacity.value,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color,
                  ),
                ),
              ),
            );
          },
        ),

        // Pin core
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
