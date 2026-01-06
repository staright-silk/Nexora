import 'package:audioplayers/audioplayers.dart';
import '../models/enums.dart';

/// Music service for offline audio playback
class MusicService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  MusicCategory? _currentCategory;
  bool _isPlaying = false;
  double _volume = 0.7;

  MusicCategory? get currentCategory => _currentCategory;
  bool get isPlaying => _isPlaying;
  double get volume => _volume;

  /// Initialize the audio player
  Future<void> init() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  /// Play music category
  Future<void> play(MusicCategory category) async {
    if (category == MusicCategory.silence) {
      await stop();
      return;
    }

    try {
      _currentCategory = category;

      // For demo purposes, using DeviceFileSource
      // In production, you would use AssetSource with actual audio files
      // await _audioPlayer.play(AssetSource(category.assetPath));

      // For now, we'll simulate playing
      _isPlaying = true;
      await _audioPlayer.setVolume(_volume);
    } catch (e) {
      // Handle error - audio file might not exist yet
      _isPlaying = false;
    }
  }

  /// Stop music
  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    _currentCategory = null;
  }

  /// Pause music
  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
  }

  /// Resume music
  Future<void> resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
  }

  /// Set volume
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(_volume);
  }

  /// Fade in music
  Future<void> fadeIn({int durationSeconds = 3}) async {
    final steps = 10;
    final stepDuration = Duration(milliseconds: (durationSeconds * 1000) ~/ steps);
    final volumeStep = _volume / steps;

    await _audioPlayer.setVolume(0.0);

    for (int i = 1; i <= steps; i++) {
      await Future.delayed(stepDuration);
      await _audioPlayer.setVolume(volumeStep * i);
    }
  }

  /// Fade out music
  Future<void> fadeOut({int durationSeconds = 2}) async {
    final currentVolume = _volume;
    final steps = 10;
    final stepDuration = Duration(milliseconds: (durationSeconds * 1000) ~/ steps);
    final volumeStep = currentVolume / steps;

    for (int i = steps - 1; i >= 0; i--) {
      await Future.delayed(stepDuration);
      await _audioPlayer.setVolume(volumeStep * i);
    }

    await stop();
    await _audioPlayer.setVolume(currentVolume);
  }

  /// Dispose
  void dispose() {
    _audioPlayer.dispose();
  }
}

