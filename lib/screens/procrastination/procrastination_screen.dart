import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/streak_service.dart';
import '../../widgets/glass_card.dart';
import '../mental_state/mental_state_screen.dart';

/// Procrastination destroyer - shows when user delays starting
class ProcrastinationScreen extends StatefulWidget {
  final StorageService storage;
  final StreakService streakService;

  const ProcrastinationScreen({
    super.key,
    required this.storage,
    required this.streakService,
  });

  @override
  State<ProcrastinationScreen> createState() => _ProcrastinationScreenState();
}

class _ProcrastinationScreenState extends State<ProcrastinationScreen> {
  int _wastedMinutes = 0;

  @override
  void initState() {
    super.initState();
    _calculateWastedTime();
  }

  void _calculateWastedTime() {
    final procrastinationStart = widget.storage.getProcrastinationStart();
    if (procrastinationStart != null) {
      final now = DateTime.now();
      final difference = now.difference(procrastinationStart);
      setState(() {
        _wastedMinutes = difference.inMinutes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Warning icon
              const Icon(
                Icons.warning_amber_rounded,
                size: 120,
                color: Colors.orange,
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'PROCRASTINATION ALERT',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Time wasted
              GlassCard(
                color: Colors.orange.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'You already wasted',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$_wastedMinutes',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'minutes today',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Urgency message
              Text(
                'Every minute you delay is a minute you won\'t get back.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Force start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _forceStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: Text(
                    'FORCE START NOW',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Maybe later (bad choice)'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _forceStart() {
    final currentState = widget.storage.getCurrentMentalState();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MentalStateScreen(
          storage: widget.storage,
          streakService: widget.streakService,
          initialState: currentState,
        ),
      ),
    );
  }
}

