import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/enums.dart';
import '../../core/models/models.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/streak_service.dart';
import '../../core/services/timer_service.dart';
import '../../core/services/music_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/pressure_ring.dart';
import '../session_complete/session_complete_screen.dart';

class FocusSessionScreen extends StatefulWidget {
  final StorageService storage;
  final StreakService streakService;
  final MentalState mentalState;
  final int durationMinutes;
  final String? subject;
  final String? topic;

  const FocusSessionScreen({
    super.key,
    required this.storage,
    required this.streakService,
    required this.mentalState,
    required this.durationMinutes,
    this.subject,
    this.topic,
  });

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen>
    with SingleTickerProviderStateMixin {

  late TimerService _timerService;
  late MusicService _musicService;
  late DateTime _sessionStartTime;
  late AnimationController _pulseController;

  bool _isLongPressing = false;
  int _longPressProgress = 0;
  Timer? _longPressTimer;

  MusicCategory _currentMusic = MusicCategory.silence;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  void _initializeSession() {
    _sessionStartTime = DateTime.now();
    _timerService = TimerService();
    _musicService = MusicService();

    // Initialize music
    _currentMusic = widget.mentalState.defaultMusicCategory;
    _musicService.init().then((_) {
      _musicService.play(_currentMusic);
      _musicService.fadeIn(durationSeconds: AppConstants.musicFadeInDuration);
    });

    // Start timer
    _timerService.startTimer(
      widget.durationMinutes,
      onTick: _onTimerTick,
      onComplete: _onSessionComplete,
    );

    // Pulse animation for pressure effect
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (2000 / widget.mentalState.animationSpeed).toInt(),
      ),
    )..repeat(reverse: true);

    // Set immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    HapticService.success();
  }

  void _onTimerTick() {
    final elapsed = _timerService.elapsedSeconds;

    // Check for milestones
    if (AppConstants.hapticMilestones.contains(elapsed)) {
      HapticService.milestone();
    }
  }

  void _onSessionComplete() {
    _completeSession(forced: false);
  }

  void _completeSession({required bool forced}) async {
    // Fade out music
    await _musicService.fadeOut(durationSeconds: AppConstants.musicFadeOutDuration);

    // Calculate actual duration
    final actualMinutes = _timerService.elapsedSeconds ~/ 60;

    // Create session record
    final session = FocusSession(
      startTime: _sessionStartTime,
      endTime: DateTime.now(),
      plannedDurationMinutes: widget.durationMinutes,
      actualDurationMinutes: actualMinutes,
      mentalState: widget.mentalState.name,
      subject: widget.subject,
      topic: widget.topic,
      wasHonest: true, // Will be updated in completion screen
      result: forced ? 'forced' : 'completed',
      musicCategory: _currentMusic.name,
      distractionCount: 0,
    );

    // Save session
    await widget.storage.addSession(session);

    // Update burnout tracking
    await widget.storage.addBurnoutMinutes(actualMinutes);

    // Reset procrastination timer
    await widget.storage.setProcrastinationStart(null);

    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    HapticService.success();

    // Navigate to completion screen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SessionCompleteScreen(
            storage: widget.storage,
            streakService: widget.streakService,
            session: session,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timerService.dispose();
    _musicService.dispose();
    _pulseController.dispose();
    _longPressTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Disable back button
      child: Scaffold(
        backgroundColor: widget.mentalState.primaryColor.withOpacity(0.05),
        body: Stack(
          children: [
            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // State emoji
                    Text(
                      widget.mentalState.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 16),

                    // Subject/Topic
                    if (widget.subject != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          widget.subject!,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (widget.topic != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          widget.topic!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 48),

                    // Pressure ring with timer
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Animated pressure ring
                          AnimatedBuilder(
                            animation: _timerService,
                            builder: (context, child) {
                              return PressureRing(
                                progress: _timerService.progress,
                                color: widget.mentalState.primaryColor,
                                pulseAnimation: _pulseController,
                              );
                            },
                          ),

                          // Timer display
                          AnimatedBuilder(
                            animation: _timerService,
                            builder: (context, child) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _timerService.formattedTime,
                                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      fontSize: 64,
                                      fontWeight: FontWeight.w900,
                                      color: widget.mentalState.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Stay locked in',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Music indicator
                    _buildMusicIndicator(),
                  ],
                ),
              ),
            ),

            // Exit button (bottom)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: _buildExitButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: widget.mentalState.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.music_note,
            size: 20,
            color: widget.mentalState.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            _currentMusic.displayName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: widget.mentalState.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExitButton() {
    return Center(
      child: GestureDetector(
        onLongPressStart: (_) => _startLongPress(),
        onLongPressEnd: (_) => _cancelLongPress(),
        child: Container(
          width: 200,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.red.withOpacity(_isLongPressing ? 0.8 : 0.3),
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              // Progress bar
              if (_isLongPressing)
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    width: 200 * (_longPressProgress / 100),
                  ),
                ),

              // Text
              Center(
                child: Text(
                  _isLongPressing ? 'Hold to Exit...' : 'HOLD TO EXIT',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startLongPress() {
    setState(() {
      _isLongPressing = true;
      _longPressProgress = 0;
    });

    HapticService.warning();

    _longPressTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        _longPressProgress += 1;
      });

      if (_longPressProgress >= 100) {
        _cancelLongPress();
        _exitSession();
      }
    });
  }

  void _cancelLongPress() {
    setState(() {
      _isLongPressing = false;
      _longPressProgress = 0;
    });
    _longPressTimer?.cancel();
  }

  void _exitSession() async {
    // Show exit confirmation
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exit Session?'),
        content: const Text(
          'Leaving early will log this as an incomplete session. '
          'This affects your discipline score.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue Session'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Exit Anyway'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      await widget.storage.incrementDailyFailures();
      _completeSession(forced: true);
    }
  }
}

