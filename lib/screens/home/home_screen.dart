import 'package:flutter/material.dart';
import '../../core/models/enums.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/streak_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../mental_state/mental_state_screen.dart';
import '../analytics/analytics_screen.dart';
import '../brain_dump/brain_dump_screen.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storage;
  final StreakService streakService;

  const HomeScreen({
    super.key,
    required this.storage,
    required this.streakService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late MentalState _currentState;
  int _currentStreak = 0;
  int _todayMinutes = 0;
  double _disciplineScore = 0.0;
  bool _isStreakAtRisk = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkProcrastination();
  }

  void _loadData() {
    setState(() {
      _currentState = widget.storage.getCurrentMentalState();
      _currentStreak = widget.streakService.getCurrentStreak();
      _todayMinutes = widget.streakService.getTodayFocusMinutes();
      _disciplineScore = widget.streakService.getDisciplineScore();
      _isStreakAtRisk = widget.streakService.isStreakAtRisk();
    });
  }

  void _checkProcrastination() {
    final procrastinationStart = widget.storage.getProcrastinationStart();
    if (procrastinationStart == null) {
      widget.storage.setProcrastinationStart(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 32),

              // Warning if streak at risk
              if (_isStreakAtRisk) _buildStreakWarning(),

              // Stats overview
              _buildStatsGrid(),
              const SizedBox(height: 32),

              // Main action button
              _buildMainActionButton(),
              const SizedBox(height: 24),

              // Quick actions
              _buildQuickActions(),
              const SizedBox(height: 24),

              // Mental state selector
              _buildMentalStateSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppConstants.tagline,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withOpacity(0.1),
        border: Border.all(color: AppTheme.warningColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppTheme.warningColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your streak is at risk! Study today to maintain it.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.warningColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.local_fire_department,
            label: 'Streak',
            value: '$_currentStreak',
            color: _currentState.primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            icon: Icons.timer,
            label: 'Today',
            value: '${_todayMinutes}m',
            color: AppTheme.accentSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            icon: Icons.military_tech,
            label: 'Score',
            value: '${_disciplineScore.toInt()}',
            color: AppTheme.accentPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMainActionButton() {
    return GlassCard(
      child: InkWell(
        onTap: () => _startSession(),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Text(
                _currentState.emoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),
              Text(
                'ENTER SMASH MODE',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Current state: ${_currentState.displayName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.analytics,
            label: 'Analytics',
            onTap: () => _openAnalytics(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.psychology,
            label: 'Brain Dump',
            onTap: () => _openBrainDump(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 32, color: _currentState.primaryColor),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMentalStateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Change Mental State',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: MentalState.values.map((state) {
            final isSelected = state == _currentState;
            return InkWell(
              onTap: () => _changeMentalState(state),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? state.primaryColor.withOpacity(0.2)
                      : AppTheme.cardDark.withOpacity(0.3),
                  border: Border.all(
                    color: isSelected ? state.primaryColor : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      state.displayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _startSession() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MentalStateScreen(
          storage: widget.storage,
          streakService: widget.streakService,
          initialState: _currentState,
        ),
      ),
    ).then((_) => _loadData());
  }

  void _openAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalyticsScreen(
          storage: widget.storage,
          streakService: widget.streakService,
        ),
      ),
    );
  }

  void _openBrainDump() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrainDumpScreen(
          storage: widget.storage,
        ),
      ),
    );
  }

  void _changeMentalState(MentalState state) {
    setState(() {
      _currentState = state;
    });
    widget.storage.setCurrentMentalState(state);
  }
}

