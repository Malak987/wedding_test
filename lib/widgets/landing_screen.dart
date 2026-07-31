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
        //
        // IMPORTANT: kept invisible (opacity 0) until _isFullyPreloaded is
        // true. The widget itself stays mounted the whole time so it keeps
        // initializing in the background — only its paint output is hidden.
        // Previously the paused seal frame appeared as soon as the video
        // alone finished initializing (_videoLoaded), often before the audio
        // was ready. That made the seal look tappable while the hotspot was
        // still disabled (wait cursor, no hit-testing), which is exactly what
        // read as "the site is stuck / slow". Now the seal frame, the click
        // cursor, and the "Double Tap...!" instruction all appear together,
        // in the same frame, only once a tap would actually do something.
        Opacity(
          opacity: _isFullyPreloaded ? 1.0 : 0.0,
          child: IntroVideoPlayer(
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
                  // Only hit-test (and therefore only allow the double tap) once
                  // everything is actually preloaded. Before that, taps pass
                  // straight through instead of silently doing nothing — which
                  // is what made the site feel "stuck" during the first seconds.
                  behavior: _isFullyPreloaded ? HitTestBehavior.opaque : HitTestBehavior.translucent,
                  onDoubleTap: _isFullyPreloaded ? _handleOpenInvitation : null,
                  child: const SizedBox(width: 100, height: 100),
                ),
              ),
            ),
          ),

        // 3. Elegant Bottom Instruction Overlay (Cairo font, champagne gold, low opacity)
        // Shows a "preparing" spinner until the seal video + audio are truly
        // ready, then switches to "Double Tap...!" — so the instruction on
        // screen always matches what will actually happen if the visitor taps.
        if (!_videoPlaying)
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: InstructionWidget(isReady: _isFullyPreloaded),
            ),
          ),
      ],
    );
  }
}