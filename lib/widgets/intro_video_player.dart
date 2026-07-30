import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class IntroVideoPlayer extends StatefulWidget {
  final String videoPath;
  final VoidCallback onInitialized;
  final VoidCallback onCompleted;
  final bool playTriggered;

  const IntroVideoPlayer({
    super.key,
    required this.videoPath,
    required this.onInitialized,
    required this.onCompleted,
    required this.playTriggered,
  });

  @override
  State<IntroVideoPlayer> createState() => _IntroVideoPlayerState();
}

class _IntroVideoPlayerState extends State<IntroVideoPlayer> with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _playbackCompleted = false;

  // Fallback animation controller (runs if video asset is missing or error happens)
  AnimationController? _fallbackController;
  Animation<double>? _envelopeFold;
  Animation<double>? _envelopeSlide;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
    try {
      _controller = VideoPlayerController.asset(widget.videoPath);
      await _controller!.initialize();
      _controller!.setLooping(false);
      _controller!.setVolume(0.0); // Music is synchronized via AppAudioService!

      _controller!.addListener(() {
        if (_controller == null) return;
        final pos = _controller!.value.position;
        final dur = _controller!.value.duration;

        if (pos >= dur && dur > Duration.zero && !_playbackCompleted) {
          _playbackCompleted = true;
          widget.onCompleted();
        }
      });

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        widget.onInitialized();
      }
    } catch (e) {
      debugPrint('Video Player error, activating luxury programmatic fallback: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
        _initProgrammaticFallback();
      }
    }
  }

  void _initProgrammaticFallback() {
    _fallbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _envelopeFold = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fallbackController!,
        curve: const Interval(0.0, 0.45, curve: Curves.easeInCubic),
      ),
    );

    _envelopeSlide = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fallbackController!,
        curve: const Interval(0.4, 0.9, curve: Curves.easeInOutCubic),
      ),
    );

    _fallbackController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted();
      }
    });

    // Notify landing page that fallback is ready to bypass loading freeze!
    widget.onInitialized();
  }

  @override
  void didUpdateWidget(covariant IntroVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playTriggered && !oldWidget.playTriggered) {
      if (_isInitialized && !_hasError && _controller != null) {
        _controller!.play();
      } else if (_hasError && _fallbackController != null) {
        _fallbackController!.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _fallbackController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildProgrammaticFallbackEnvelope();
    }

    if (!_isInitialized || _controller == null) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
      ),
    );
  }

  /// A luxurious fallback animation simulating an envelope flap folding back
  /// and an elegant golden wedding invitation sliding up, blending into white.
  Widget _buildProgrammaticFallbackEnvelope() {
    final goldColor = const Color(0xFFD4AF37);
    final ivory = const Color(0xFFF9F6F1);
    final deepBrown = const Color(0xFF4A3B2E);

    return AnimatedBuilder(
      animation: _fallbackController!,
      builder: (context, child) {
        final foldVal = _envelopeFold!.value;
        final slideVal = _envelopeSlide!.value;

        return Positioned.fill(
          child: Container(
            color: ivory,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Envelope Body
                Center(
                  child: Container(
                    width: 380,
                    height: 260,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFE7DA),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Sliding Invitation Card (slides out of envelope)
                        Positioned(
                          bottom: 20 + (slideVal * 150),
                          left: 15,
                          right: 15,
                          child: Opacity(
                            opacity: (1.0 - (slideVal * 0.4)).clamp(0.0, 1.0),
                            child: Container(
                              height: 220,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: goldColor.withOpacity(0.4), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: goldColor.withOpacity(0.15),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.favorite_sharp, color: goldColor, size: 28),
                                  const SizedBox(height: 12),
                                  Text(
                                    "دعوة خطوبة",
                                    style: TextStyle(
                                      fontFamily: 'Playfair',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: deepBrown,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(width: 40, height: 1, color: goldColor),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Lower Envelope Pocket (drawn over the card)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: CustomPaint(
                            size: const Size(380, 130),
                            painter: _EnvelopePocketPainter(goldColor.withOpacity(0.35)),
                          ),
                        ),

                        // Top Flap (rotates open)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Transform(
                            alignment: Alignment.topCenter,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateX(foldVal * 3.1415), // 180 degree flip
                            child: CustomPaint(
                              size: const Size(380, 130),
                              painter: _EnvelopeFlapPainter(foldVal > 0.5),
                            ),
                          ),
                        ),

                        // Gold Wax Seal (fades out as flap opens)
                        if (foldVal < 0.8)
                          Center(
                            child: Opacity(
                              opacity: (1.0 - (foldVal * 1.5)).clamp(0.0, 1.0),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: goldColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.favorite, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Intense growing white light cover that engulfs the screen at the very end
                if (slideVal > 0.55)
                  Positioned.fill(
                    child: Opacity(
                      opacity: ((slideVal - 0.55) / 0.35).clamp(0.0, 1.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.white,
                              Color(0xFFFFFDF9),
                            ],
                            radius: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EnvelopePocketPainter extends CustomPainter {
  final Color borderColor;
  _EnvelopePocketPainter(this.borderColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE9DEC9)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width * 0.5, size.height * 0.3);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Decorative borders
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EnvelopeFlapPainter extends CustomPainter {
  final bool isOpened;
  _EnvelopeFlapPainter(this.isOpened);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isOpened ? const Color(0xFFE0D5C3) : const Color(0xFFE3D2BF)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.5, size.height * 0.85);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
