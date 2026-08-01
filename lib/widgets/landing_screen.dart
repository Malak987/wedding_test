import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import 'intro_video_player.dart';
import 'instruction.dart';

class LandingScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const LandingScreen({
    super.key,
    required this.onCompleted,
  });

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _videoLoaded = false;
  bool _audioLoaded = false;
  bool _openTriggered = false;
  bool _videoPlaying = false;

  @override
  void initState() {
    super.initState();

    AppAudioService.instance.preload().then((_) {
      if (!mounted) return;

      setState(() {
        _audioLoaded = true;
      });
    }).catchError((error) {
      debugPrint('Audio preload error: $error');

      if (!mounted) return;

      // لا نمنع المستخدم من فتح الدعوة لو الموسيقى بها مشكلة.
      setState(() {
        _audioLoaded = true;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(
      const AssetImage('assets/images/story_young.png'),
      context,
    );

    precacheImage(
      const AssetImage('assets/images/story_now.png'),
      context,
    );
  }

  bool get _isFullyPreloaded => _videoLoaded && _audioLoaded;

  Future<void> _handleOpenInvitation() async {
    if (!_isFullyPreloaded || _openTriggered) return;

    setState(() {
      _openTriggered = true;
      _videoPlaying = true;
    });

    try {
      await AppAudioService.instance.play();
    } catch (error) {
      debugPrint('Music play error: $error');
    }
  }

  void _onVideoFinished() {
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: _isFullyPreloaded ? 1 : 0,
          child: IntroVideoPlayer(
            videoPath: 'assets/images/video/intro.mp4',
            playTriggered: _videoPlaying,
            onInitialized: () {
              if (!mounted) return;

              setState(() {
                _videoLoaded = true;
              });
            },
            onCompleted: _onVideoFinished,
          ),
        ),

        if (!_videoPlaying)
          Positioned.fill(
            child: Center(
              child: MouseRegion(
                cursor: _isFullyPreloaded
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.wait,
                child: GestureDetector(
                  behavior: _isFullyPreloaded
                      ? HitTestBehavior.opaque
                      : HitTestBehavior.translucent,
                  onDoubleTap:
                  _isFullyPreloaded ? _handleOpenInvitation : null,
                  child: const SizedBox(
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
            ),
          ),

        if (!_videoPlaying)
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: InstructionWidget(
                isReady: _isFullyPreloaded,
              ),
            ),
          ),
      ],
    );
  }
}