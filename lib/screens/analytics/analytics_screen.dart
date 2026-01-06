import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/streak_service.dart';
import '../../widgets/glass_card.dart';

class AnalyticsScreen extends StatefulWidget {
  final StorageService storage;
  final StreakService streakService;

  const AnalyticsScreen({
    super.key,
    required this.storage,
    required this.streakService,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late List<int> _last7DaysMinutes;
  late Map<String, int> _mentalStateMinutes;
  late double _disciplineScore;
  late int _totalSessions;
  late int _completedSessions;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _loadAnalytics() {
    final sessions = widget.storage.getSessions();
    final stats = widget.storage.getStats();

    // Last 7 days minutes
    _last7DaysMinutes = List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      return sessions
          .where((s) => _isSameDay(s.startTime, date))
          .fold(0, (sum, s) => sum + s.actualDurationMinutes);
    });

    // Mental state breakdown
    _mentalStateMinutes = stats.mentalStateMinutes;

    // Discipline score
    _disciplineScore = widget.streakService.getDisciplineScore();

    // Session stats
    _totalSessions = sessions.length;
    _completedSessions = sessions.where((s) => s.result == 'completed').length;

    setState(() {});
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Discipline score
              _buildDisciplineScore(),
              const SizedBox(height: 24),

              // 7-day chart
              _buildWeeklyChart(),
              const SizedBox(height: 24),

              // Session stats
              _buildSessionStats(),
              const SizedBox(height: 24),

              // Mental state breakdown
              if (_mentalStateMinutes.isNotEmpty)
                _buildMentalStateBreakdown(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisciplineScore() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Discipline Score',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _disciplineScore / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getScoreColor(_disciplineScore),
                    ),
                  ),
                  Text(
                    '${_disciplineScore.toInt()}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: _getScoreColor(_disciplineScore),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getScoreLabel(_disciplineScore),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(double score) {
    if (score >= 80) return 'Excellent Discipline';
    if (score >= 60) return 'Good Progress';
    if (score >= 40) return 'Building Momentum';
    return 'Keep Pushing';
  }

  Widget _buildWeeklyChart() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last 7 Days',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (_last7DaysMinutes.reduce((a, b) => a > b ? a : b) + 20).toDouble(),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          final index = value.toInt();
                          if (index >= 0 && index < 7) {
                            return Text(
                              days[index],
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}m',
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: _last7DaysMinutes[index].toDouble(),
                          color: Theme.of(context).colorScheme.primary,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionStats() {
    final completionRate = _totalSessions > 0
        ? (_completedSessions / _totalSessions * 100).toInt()
        : 0;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Statistics',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            _buildStatRow('Total Sessions', '$_totalSessions'),
            const SizedBox(height: 12),
            _buildStatRow('Completed', '$_completedSessions'),
            const SizedBox(height: 12),
            _buildStatRow('Completion Rate', '$completionRate%'),
            const SizedBox(height: 12),
            _buildStatRow(
              'Total Focus Time',
              '${widget.streakService.getTotalFocusMinutes()} min',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildMentalStateBreakdown() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mental State Distribution',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ..._mentalStateMinutes.entries.map((entry) {
              final percentage = _mentalStateMinutes.values.reduce((a, b) => a + b) > 0
                  ? (entry.value / _mentalStateMinutes.values.reduce((a, b) => a + b) * 100).toInt()
                  : 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${entry.value} min ($percentage%)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

