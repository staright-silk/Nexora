import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/streak_service.dart';
import '../../core/services/haptic_service.dart';
import '../../widgets/glass_card.dart';

class SessionCompleteScreen extends StatefulWidget {
  final StorageService storage;
  final StreakService streakService;
  final FocusSession session;

  const SessionCompleteScreen({
    super.key,
    required this.storage,
    required this.streakService,
    required this.session,
  });

  @override
  State<SessionCompleteScreen> createState() => _SessionCompleteScreenState();
}

class _SessionCompleteScreenState extends State<SessionCompleteScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _celebrationController;
  bool _wasHonest = true;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _updateStats();
    HapticService.success();
  }

  void _updateStats() async {
    final updatedSession = FocusSession(
      startTime: widget.session.startTime,
      endTime: widget.session.endTime,
      plannedDurationMinutes: widget.session.plannedDurationMinutes,
      actualDurationMinutes: widget.session.actualDurationMinutes,
      mentalState: widget.session.mentalState,
      subject: widget.session.subject,
      topic: widget.session.topic,
      wasHonest: _wasHonest,
      result: widget.session.result,
      musicCategory: widget.session.musicCategory,
      distractionCount: widget.session.distractionCount,
    );

    await widget.streakService.updateStatsAfterSession(updatedSession);
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.session.result == 'completed';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Celebration animation
              ScaleTransition(
                scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _celebrationController,
                    curve: Curves.elasticOut,
                  ),
                ),
                child: Text(
                  isCompleted ? '🎯' : '⚠️',
                  style: const TextStyle(fontSize: 120),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                isCompleted ? 'SESSION COMPLETE!' : 'Session Ended Early',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Stats
              _buildStatsCard(),

              const SizedBox(height: 24),

              // Honesty check
              if (isCompleted) _buildHonestyCheck(),

              const SizedBox(height: 32),

              // Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildStatRow(
              'Duration',
              '${widget.session.actualDurationMinutes} min',
              Icons.timer,
            ),
            const Divider(height: 24),
            _buildStatRow(
              'Planned',
              '${widget.session.plannedDurationMinutes} min',
              Icons.flag,
            ),
            if (widget.session.subject != null) ...[
              const Divider(height: 24),
              _buildStatRow(
                'Subject',
                widget.session.subject!,
                Icons.book,
              ),
            ],
            const Divider(height: 24),
            _buildStatRow(
              'Current Streak',
              '${widget.streakService.getCurrentStreak()} days',
              Icons.local_fire_department,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHonestyCheck() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Honesty Check',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Did you actually focus during this session?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildHonestyButton(
                    'Yes, I focused',
                    true,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHonestyButton(
                    'Not really',
                    false,
                    Icons.cancel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHonestyButton(String label, bool honest, IconData icon) {
    final isSelected = _wasHonest == honest;

    return InkWell(
      onTap: () {
        setState(() {
          _wasHonest = honest;
        });
        _updateStats();
        HapticService.selection();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (honest
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2))
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? (honest ? Colors.green : Colors.orange)
                : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? (honest ? Colors.green : Colors.orange)
                  : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? (honest ? Colors.green : Colors.orange)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('BACK TO HOME'),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            // TODO: View analytics
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: const Text('View Analytics'),
        ),
      ],
    );
  }
}

