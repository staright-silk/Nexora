import 'dart:async';
import 'package:flutter/material.dart';

/// Timer service for focus sessions
class TimerService extends ChangeNotifier {
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;

  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;

  double get progress {
    if (_totalSeconds == 0) return 0.0;
    return (_totalSeconds - _remainingSeconds) / _totalSeconds;
  }

  int get elapsedSeconds => _totalSeconds - _remainingSeconds;

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void startTimer(int durationMinutes, {VoidCallback? onTick, VoidCallback? onComplete}) {
    _totalSeconds = durationMinutes * 60;
    _remainingSeconds = _totalSeconds;
    _isRunning = true;
    _isPaused = false;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
        onTick?.call();

        if (_remainingSeconds == 0) {
          stopTimer();
          onComplete?.call();
        }
      }
    });

    notifyListeners();
  }

  void pauseTimer() {
    _isPaused = true;
    _timer?.cancel();
    notifyListeners();
  }

  void resumeTimer({VoidCallback? onTick, VoidCallback? onComplete}) {
    if (!_isPaused) return;

    _isPaused = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
        onTick?.call();

        if (_remainingSeconds == 0) {
          stopTimer();
          onComplete?.call();
        }
      }
    });

    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _isPaused = false;
    _remainingSeconds = 0;
    _totalSeconds = 0;
    notifyListeners();
  }

  void addTime(int seconds) {
    _remainingSeconds += seconds;
    _totalSeconds += seconds;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

