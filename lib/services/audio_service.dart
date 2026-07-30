import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'config_manager.dart';

class AppAudioService extends ChangeNotifier {
  static AppAudioService? _instance;
  static AppAudioService get instance {
    _instance ??= AppAudioService();
    return _instance!;
  }

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isInitialized = false;
  double _currentVolume = 0.0;
  Timer? _fadeTimer;

  bool get isPlaying => _isPlaying;
  double get currentVolume => _currentVolume;
  bool get isMuted => AppConfigManager.instance.musicMuted;

  AppAudioService() {
    _init();
  }

  Future<void> _init() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      _currentVolume = AppConfigManager.instance.musicMuted ? 0.0 : AppConfigManager.instance.musicVolume;
      await _player.setVolume(_currentVolume);

      _player.onPlayerStateChanged.listen((state) {
        _isPlaying = state == PlayerState.playing;
        notifyListeners();
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing AudioPlayer: $e');
    }
  }

  /// Actually fetches and prepares the audio source ahead of time (called
  /// while the intro video is still playing), so that by the time the
  /// person taps to open the invitation, `play()` starts near-instantly
  /// instead of only then fetching/decoding the file for the first time.
  Future<void> preload() async {
    if (!_isInitialized) await _init();
    try {
      await _player.setSource(AssetSource('music/wedding_music.mp3'));
    } catch (e) {
      debugPrint('Audio preload failed (will still play on demand): $e');
    }
  }

  /// Plays the background music with a smooth fade-in (approx 1000ms)
  Future<void> play() async {
    if (!_isInitialized) await _init();

    _fadeTimer?.cancel();

    // The asset path. In audioplayers, asset source assumes 'assets/' is prepended.
    // So the path should be 'music/wedding_music.mp3' because 'assets/' is implicit.
    const path = 'music/wedding_music.mp3';

    try {
      if (AppConfigManager.instance.musicMuted) {
        await _player.setVolume(0.0);
        await _player.play(AssetSource(path));
        _isPlaying = true;
        _currentVolume = 0.0;
        notifyListeners();
        return;
      }

      // Smooth fade-in implementation
      await _player.setVolume(0.0);
      _currentVolume = 0.0;
      await _player.play(AssetSource(path));
      _isPlaying = true;
      notifyListeners();

      final targetVolume = AppConfigManager.instance.musicVolume;
      const steps = 20;
      final stepIncrement = targetVolume / steps;
      int currentStep = 0;

      _fadeTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
        currentStep++;
        _currentVolume = (stepIncrement * currentStep).clamp(0.0, targetVolume);
        await _player.setVolume(_currentVolume);
        notifyListeners();

        if (currentStep >= steps) {
          timer.cancel();
        }
      });
    } catch (e) {
      debugPrint('Graceful Error: Audio playback failed: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  /// Pauses the background music with a smooth fade-out (approx 800ms)
  Future<void> pause() async {
    if (!_isInitialized) return;

    _fadeTimer?.cancel();

    try {
      final startVolume = _currentVolume;
      const steps = 16;
      final stepDecrement = startVolume / steps;
      int currentStep = 0;

      _fadeTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
        currentStep++;
        _currentVolume = (startVolume - (stepDecrement * currentStep)).clamp(0.0, 1.0);
        await _player.setVolume(_currentVolume);
        notifyListeners();

        if (currentStep >= steps || _currentVolume <= 0.05) {
          timer.cancel();
          await _player.pause();
          _isPlaying = false;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Graceful Error: Audio pause failed: $e');
      await _player.pause();
      _isPlaying = false;
      notifyListeners();
    }
  }

  /// Dynamic volume adjustments (e.g. from the slider)
  Future<void> setVolume(double volume) async {
    _fadeTimer?.cancel();
    AppConfigManager.instance.updateConfig(musicVolume: volume);
    if (!AppConfigManager.instance.musicMuted) {
      _currentVolume = volume;
      await _player.setVolume(volume);
      notifyListeners();
    }
  }

  /// Dynamic mute toggles
  Future<void> toggleMute() async {
    final currentlyMuted = AppConfigManager.instance.musicMuted;
    final newMuteState = !currentlyMuted;

    AppConfigManager.instance.updateConfig(musicMuted: newMuteState);

    _fadeTimer?.cancel();

    try {
      if (newMuteState) {
        // Smooth fade-out to 0
        final startVolume = _currentVolume;
        const steps = 10;
        final stepDecrement = startVolume / steps;
        int currentStep = 0;

        _fadeTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) async {
          currentStep++;
          _currentVolume = (startVolume - (stepDecrement * currentStep)).clamp(0.0, 1.0);
          await _player.setVolume(_currentVolume);
          notifyListeners();

          if (currentStep >= steps) {
            timer.cancel();
            _currentVolume = 0.0;
            await _player.setVolume(0.0);
            notifyListeners();
          }
        });
      } else {
        // Smooth fade-in back to stored config volume
        final targetVolume = AppConfigManager.instance.musicVolume;
        const steps = 15;
        final stepIncrement = targetVolume / steps;
        int currentStep = 0;

        _fadeTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) async {
          currentStep++;
          _currentVolume = (stepIncrement * currentStep).clamp(0.0, targetVolume);
          await _player.setVolume(_currentVolume);
          notifyListeners();

          if (currentStep >= steps) {
            timer.cancel();
          }
        });
      }
    } catch (e) {
      debugPrint('Error toggling mute: $e');
    }
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    _player.dispose();
    super.dispose();
  }
}
