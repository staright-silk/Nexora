import 'package:flutter/services.dart';

/// Haptic feedback service
class HapticService {
  /// Light impact
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Selection click
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Vibrate (success)
  static void success() {
    HapticFeedback.mediumImpact();
  }

  /// Vibrate (warning)
  static void warning() {
    HapticFeedback.heavyImpact();
  }

  /// Vibrate (error)
  static void error() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.heavyImpact();
    });
  }

  /// Session milestone
  static void milestone() {
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.mediumImpact();
    });
  }
}

