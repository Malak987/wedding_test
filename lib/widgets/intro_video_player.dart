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

class _IntroVideoPlayerState extends State<IntroVideoPlayer> {
  VideoPlayerController? _controller;

  bool _isInitialized = false;
  bool _hasError = false;
  bool _playbackCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final controller = VideoPlayerController.asset(widget.videoPath);

      await controller.initialize();
      await controller.setLooping(false);
      await controller.setVolume(0);

      controller.addListener(() {
        final value = controller.value;

        if (!value.isInitialized || _playbackCompleted) return;

        if (value.position >= value.duration &&
            value.duration > Duration.zero) {
          _playbackCompleted = true;
          widget.onCompleted();
        }
      });

      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isInitialized = true;
      });

      widget.onInitialized();
    } catch (error) {
      debugPrint('Intro video error: $error');

      if (!mounted) return;

      setState(() {
        _hasError = true;
      });

      // حتى لا تظل شاشة التحميل معلّقة لو حدثت مشكلة بالفيديو.
      widget.onInitialized();
    }
  }

  @override
  void didUpdateWidget(covariant IntroVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.playTriggered && !oldWidget.playTriggered) {
      if (_hasError) {
        // في حالة عدم دعم الفيديو، افتحي الدعوة بدل شاشة بيضاء.
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) widget.onCompleted();
        });
        return;
      }

      _controller?.play();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const SizedBox.expand(
        child: ColoredBox(
          color: Color(0xFF0B2E23),
          child: Center(
            child: Icon(
              Icons.favorite,
              color: Color(0xFFE3C878),
              size: 52,
            ),
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const SizedBox.expand(
        child: ColoredBox(color: Color(0xFF0B2E23)),
      );
    }

    final videoSize = _controller!.value.size;

    // مهم جداً:
    // لا نستخدم Positioned.fill هنا لأن هذا الـ widget موجود داخل Opacity
    // في LandingScreen. استخدام Positioned في هذا المكان قد يمنع ظهور
    // الفيديو على Flutter Web.
    return IgnorePointer(
      child: SizedBox.expand(
        child: ColoredBox(
          color: Colors.black,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: videoSize.width,
              height: videoSize.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
      ),
    );
  }
}