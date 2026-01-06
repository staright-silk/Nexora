import 'package:flutter/material.dart';
import '../../core/models/enums.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/streak_service.dart';
import '../focus/focus_session_screen.dart';
import '../../widgets/glass_card.dart';

class MentalStateScreen extends StatefulWidget {
  final StorageService storage;
  final StreakService streakService;
  final MentalState initialState;

  const MentalStateScreen({
    super.key,
    required this.storage,
    required this.streakService,
    required this.initialState,
  });

  @override
  State<MentalStateScreen> createState() => _MentalStateScreenState();
}

class _MentalStateScreenState extends State<MentalStateScreen> {
  late MentalState _selectedState;
  int _customDuration = 0;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedState = widget.initialState;
    _customDuration = _selectedState.defaultSessionMinutes;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Session'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mental state display
              _buildStateDisplay(),
              const SizedBox(height: 32),

              // Duration selector
              _buildDurationSelector(),
              const SizedBox(height: 24),

              // Subject and topic
              _buildTaskInput(),
              const SizedBox(height: 32),

              // Distraction contract
              _buildDistractionContract(),
              const SizedBox(height: 32),

              // Start button
              _buildStartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateDisplay() {
    return GlassCard(
      color: _selectedState.primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              _selectedState.emoji,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedState.displayName,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              _getStateDescription(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getStateDescription() {
    switch (_selectedState) {
      case MentalState.distracted:
        return 'Short, focused bursts to rebuild concentration';
      case MentalState.overthinking:
        return 'Structured tasks to clear mental clutter';
      case MentalState.lazy:
        return 'Momentum-building sessions with strict accountability';
      case MentalState.anxious:
        return 'Calm, manageable blocks with gentle pressure';
      case MentalState.burnedOut:
        return 'Recovery-focused, minimal strain sessions';
      case MentalState.lockedIn:
        return 'Extended deep work with maximum efficiency';
      case MentalState.examPanic:
        return 'High-intensity, exam-focused sprint sessions';
    }
  }

  Widget _buildDurationSelector() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Duration',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Slider(
              value: _customDuration.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              label: '$_customDuration min',
              activeColor: _selectedState.primaryColor,
              onChanged: (value) {
                setState(() {
                  _customDuration = value.toInt();
                });
              },
            ),
            Center(
              child: Text(
                '$_customDuration minutes',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: _selectedState.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInput() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What will you study?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Subject',
                hintText: 'e.g., Mathematics',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                labelText: 'Topic (Optional)',
                hintText: 'e.g., Calculus - Derivatives',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistractionContract() {
    return GlassCard(
      color: _selectedState.primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.lock,
              size: 48,
              color: _selectedState.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'LOCKDOWN CONTRACT',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '• No back button\n'
              '• No app switching\n'
              '• Exit requires long-press\n'
              '• Early exit = logged failure\n'
              '• Your focus, your rules',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return ElevatedButton(
      onPressed: _startFocusSession,
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedState.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        'LOCK IN & START',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  void _startFocusSession() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FocusSessionScreen(
          storage: widget.storage,
          streakService: widget.streakService,
          mentalState: _selectedState,
          durationMinutes: _customDuration,
          subject: _subjectController.text.trim().isEmpty
              ? null
              : _subjectController.text.trim(),
          topic: _topicController.text.trim().isEmpty
              ? null
              : _topicController.text.trim(),
        ),
      ),
    );
  }
}

