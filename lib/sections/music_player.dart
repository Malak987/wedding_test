import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/config_manager.dart';

class MusicController extends StatefulWidget {
  const MusicController({super.key});

  @override
  State<MusicController> createState() => _MusicControllerState();
}

class _MusicControllerState extends State<MusicController> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final audio = AppAudioService.instance;
    final manager = AppConfigManager.instance;
    final primary = manager.primaryColor;
    final goldColor = const Color(0xFFD4AF37); // Champagne Gold

    return ListenableBuilder(
      listenable: audio,
      builder: (context, _) {
        final muted = audio.isMuted;
        final playing = audio.isPlaying;

        return Positioned(
          bottom: 24,
          right: 24, // Fixed near bottom-right corner
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            child: GestureDetector(
              onTap: () {
                audio.toggleMute();
              },
              child: AnimatedScale(
                scale: _hovering ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(_hovering ? 0.35 : 0.15),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: goldColor.withOpacity(_hovering ? 0.9 : 0.45),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                          if (_hovering)
                            BoxShadow(
                              color: goldColor.withOpacity(0.2),
                              blurRadius: 12,
                            ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        muted ? "♪" : "♫",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: muted ? Colors.white54 : goldColor,
                          shadows: [
                            if (!muted)
                              Shadow(
                                color: goldColor.withOpacity(0.4),
                                blurRadius: 8,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
