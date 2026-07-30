import 'package:flutter/material.dart';
import '../services/config_manager.dart';
import '../services/audio_service.dart';
import 'intro_video_player.dart';
import 'instruction.dart';

class LandingScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const LandingScreen({super.key, required this.onCompleted});

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

    // Genuinely preload the audio source (fetch + decode) while the seal
    // video is on screen, so playback starts immediately on tap instead of
    // only then loading the file for the first time.
    AppAudioService.instance.preload().then((_) {
      if (mounted) {
        setState(() {
          _audioLoaded = true;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache the hero background and story images so they render instantly with 0 delay!
    try {
      precacheImage(const AssetImage('assets/images/1.jpg'), context);
      precacheImage(const AssetImage('assets/images/story_young.png'), context);
      precacheImage(const AssetImage('assets/images/story_now.jpg'), context);
    } catch (e) {
      debugPrint('Pre-caching images failed: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool get _isFullyPreloaded => _videoLoaded && _audioLoaded;

  void _handleOpenInvitation() async {
    if (!_isFullyPreloaded || _openTriggered) return;

    setState(() {
      _openTriggered = true;
      _videoPlaying = true;
    });

    // 1. Synchronously trigger music playback with a smooth fader
    await AppAudioService.instance.play();
  }

  void _onVideoFinished() {
    // Note: we intentionally do NOT reset _videoPlaying back to false here.
    // Doing so used to make the invisible seal hotspot and the "Double Tap...!"
    // instruction text flash back on screen for a split second while the
    // parent's fade-to-white transition was still running, since both were
    // keyed off `_videoPlaying`. The screen is about to be torn down by the
    // parent shortly after this callback anyway, so nothing needs to change
    // here besides notifying the parent.
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Fullscreen Intro Video Player Layer
        // Paused on frame 1 until _videoPlaying is true.
        IntroVideoPlayer(
          videoPath: 'assets/images/video/s&m.mp4',
          playTriggered: _videoPlaying,
          onInitialized: () {
            if (mounted) {
              setState(() {
                _videoLoaded = true;
              });
            }
          },
          onCompleted: _onVideoFinished,
        ),

        // 2. Fully invisible Hot-Spot Overlay on top of the physical wax seal
        // (exactly at center of viewport). No visible ring, glow, or shimmer —
        // the seal graphic itself (baked into the video) is the only visual cue,
        // paired with the instruction phrase below.
        if (!_videoPlaying)
          Positioned.fill(
            child: Center(
              child: MouseRegion(
                cursor: _isFullyPreloaded ? SystemMouseCursors.click : SystemMouseCursors.wait,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onDoubleTap: _handleOpenInvitation,
                  child: const SizedBox(width: 100, height: 100),
                ),
              ),
            ),
          ),

        // 3. Elegant Bottom Instruction Overlay (Cairo font, champagne gold, low opacity)
        if (!_videoPlaying)
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: InstructionWidget(),
            ),
          ),
      ],
    );
  }
}
