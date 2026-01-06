import 'package:flutter/material.dart';

/// Mental states that determine app behavior
enum MentalState {
  distracted,
  overthinking,
  lazy,
  anxious,
  burnedOut,
  lockedIn,
  examPanic,
}

extension MentalStateExtension on MentalState {
  String get displayName {
    switch (this) {
      case MentalState.distracted:
        return 'Distracted';
      case MentalState.overthinking:
        return 'Overthinking';
      case MentalState.lazy:
        return 'Lazy';
      case MentalState.anxious:
        return 'Anxious';
      case MentalState.burnedOut:
        return 'Burned Out';
      case MentalState.lockedIn:
        return 'Locked In';
      case MentalState.examPanic:
        return 'Exam Panic';
    }
  }

  String get emoji {
    switch (this) {
      case MentalState.distracted:
        return '😵‍💫';
      case MentalState.overthinking:
        return '🤯';
      case MentalState.lazy:
        return '😴';
      case MentalState.anxious:
        return '😰';
      case MentalState.burnedOut:
        return '🔥';
      case MentalState.lockedIn:
        return '🎯';
      case MentalState.examPanic:
        return '🚨';
    }
  }

  Color get primaryColor {
    switch (this) {
      case MentalState.distracted:
        return const Color(0xFFFF6B6B);
      case MentalState.overthinking:
        return const Color(0xFFAA78F0);
      case MentalState.lazy:
        return const Color(0xFF4ECDC4);
      case MentalState.anxious:
        return const Color(0xFFFFA07A);
      case MentalState.burnedOut:
        return const Color(0xFFFF8C42);
      case MentalState.lockedIn:
        return const Color(0xFF51CF66);
      case MentalState.examPanic:
        return const Color(0xFFE63946);
    }
  }

  int get defaultSessionMinutes {
    switch (this) {
      case MentalState.distracted:
        return 15; // Shorter for rebuilding focus
      case MentalState.overthinking:
        return 20;
      case MentalState.lazy:
        return 25;
      case MentalState.anxious:
        return 15;
      case MentalState.burnedOut:
        return 10; // Very short to avoid overwhelm
      case MentalState.lockedIn:
        return 45; // Longer for flow state
      case MentalState.examPanic:
        return 30;
    }
  }

  double get animationSpeed {
    switch (this) {
      case MentalState.distracted:
        return 0.8;
      case MentalState.overthinking:
        return 0.6;
      case MentalState.lazy:
        return 1.2;
      case MentalState.anxious:
        return 0.5;
      case MentalState.burnedOut:
        return 0.3;
      case MentalState.lockedIn:
        return 1.5;
      case MentalState.examPanic:
        return 0.7;
    }
  }

  int get strictnessLevel {
    switch (this) {
      case MentalState.distracted:
        return 4;
      case MentalState.overthinking:
        return 3;
      case MentalState.lazy:
        return 5;
      case MentalState.anxious:
        return 2;
      case MentalState.burnedOut:
        return 1;
      case MentalState.lockedIn:
        return 3;
      case MentalState.examPanic:
        return 5;
    }
  }

  bool get allowMusicChange {
    switch (this) {
      case MentalState.lockedIn:
        return false;
      case MentalState.examPanic:
        return false;
      default:
        return true;
    }
  }

  MusicCategory get defaultMusicCategory {
    switch (this) {
      case MentalState.distracted:
        return MusicCategory.whiteNoise;
      case MentalState.overthinking:
        return MusicCategory.rain;
      case MentalState.lazy:
        return MusicCategory.lofi;
      case MentalState.anxious:
        return MusicCategory.brownNoise;
      case MentalState.burnedOut:
        return MusicCategory.silence;
      case MentalState.lockedIn:
        return MusicCategory.deepFocus;
      case MentalState.examPanic:
        return MusicCategory.whiteNoise;
    }
  }
}

/// Music categories
enum MusicCategory {
  deepFocus,
  lofi,
  whiteNoise,
  rain,
  fanNoise,
  brownNoise,
  silence,
}

extension MusicCategoryExtension on MusicCategory {
  String get displayName {
    switch (this) {
      case MusicCategory.deepFocus:
        return 'Deep Focus';
      case MusicCategory.lofi:
        return 'Lo-Fi';
      case MusicCategory.whiteNoise:
        return 'White Noise';
      case MusicCategory.rain:
        return 'Rain';
      case MusicCategory.fanNoise:
        return 'Fan Noise';
      case MusicCategory.brownNoise:
        return 'Brown Noise';
      case MusicCategory.silence:
        return 'Absolute Silence';
    }
  }

  String get assetPath {
    // These would be actual audio files in assets/audio/
    switch (this) {
      case MusicCategory.deepFocus:
        return 'assets/audio/deep_focus.mp3';
      case MusicCategory.lofi:
        return 'assets/audio/lofi.mp3';
      case MusicCategory.whiteNoise:
        return 'assets/audio/white_noise.mp3';
      case MusicCategory.rain:
        return 'assets/audio/rain.mp3';
      case MusicCategory.fanNoise:
        return 'assets/audio/fan_noise.mp3';
      case MusicCategory.brownNoise:
        return 'assets/audio/brown_noise.mp3';
      case MusicCategory.silence:
        return '';
    }
  }

  int get bpm {
    switch (this) {
      case MusicCategory.deepFocus:
        return 60;
      case MusicCategory.lofi:
        return 80;
      default:
        return 0;
    }
  }
}

/// Session types
enum SessionType {
  focus,
  microBreak,
  cooldown,
  forcedRest,
}

/// Focus session result
enum SessionResult {
  completed,
  abandoned,
  forced,
}

