import '../models/models.dart';
import 'storage_service.dart';
import '../constants/app_constants.dart';

/// Streak and statistics service
class StreakService {
  final StorageService _storage;

  StreakService(this._storage);

  /// Update stats after a session
  Future<void> updateStatsAfterSession(FocusSession session) async {
    final stats = _storage.getStats();

    // Update total minutes and sessions
    final totalFocusMinutes = stats.totalFocusMinutes + session.actualDurationMinutes;
    final totalSessions = stats.totalSessions + 1;

    // Update mental state minutes
    final mentalStateMinutes = Map<String, int>.from(stats.mentalStateMinutes);
    mentalStateMinutes[session.mentalState] =
        (mentalStateMinutes[session.mentalState] ?? 0) + session.actualDurationMinutes;

    // Update streak
    final now = DateTime.now();
    final lastSessionDate = stats.lastSessionDate;

    int currentStreak = stats.currentStreak;
    int longestStreak = stats.longestStreak;

    if (lastSessionDate == null) {
      // First session
      currentStreak = 1;
    } else {
      final daysSinceLastSession = now.difference(lastSessionDate).inHours ~/ 24;

      if (daysSinceLastSession == 0) {
        // Same day - streak continues
        // Don't increment
      } else if (daysSinceLastSession == 1) {
        // Next day - streak continues
        currentStreak++;
      } else if (daysSinceLastSession <= (AppConstants.streakGracePeriodHours ~/ 24)) {
        // Within grace period - streak continues
        currentStreak++;
      } else {
        // Streak broken
        currentStreak = 1;
      }
    }

    // Update longest streak
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    // Update honesty score
    final totalDistractedCount = stats.totalDistractedCount + session.distractionCount;
    final averageHonestyScore = session.wasHonest
        ? stats.averageHonestyScore
        : (stats.averageHonestyScore * 0.95); // Decrease by 5% if dishonest

    // Save updated stats
    final updatedStats = UserStats(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalFocusMinutes: totalFocusMinutes,
      totalSessions: totalSessions,
      lastSessionDate: now,
      mentalStateMinutes: mentalStateMinutes,
      averageHonestyScore: averageHonestyScore,
      totalDistractedCount: totalDistractedCount,
    );

    await _storage.saveStats(updatedStats);
  }

  /// Get current streak
  int getCurrentStreak() {
    return _storage.getStats().currentStreak;
  }

  /// Get longest streak
  int getLongestStreak() {
    return _storage.getStats().longestStreak;
  }

  /// Get total focus time
  int getTotalFocusMinutes() {
    return _storage.getStats().totalFocusMinutes;
  }

  /// Get today's focus time
  int getTodayFocusMinutes() {
    final sessions = _storage.getSessions();
    final today = DateTime.now();

    return sessions
        .where((s) => _isSameDay(s.startTime, today))
        .fold(0, (sum, session) => sum + session.actualDurationMinutes);
  }

  /// Get this week's focus time
  int getWeekFocusMinutes() {
    final sessions = _storage.getSessions();
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return sessions
        .where((s) => s.startTime.isAfter(weekAgo))
        .fold(0, (sum, session) => sum + session.actualDurationMinutes);
  }

  /// Calculate discipline score (0-100)
  double getDisciplineScore() {
    final stats = _storage.getStats();
    final sessions = _storage.getSessions();

    if (sessions.isEmpty) return 0.0;

    // Recent sessions (last 7 days)
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final recentSessions = sessions.where((s) => s.startTime.isAfter(weekAgo)).toList();

    if (recentSessions.isEmpty) return 0.0;

    // Completion rate
    final completedSessions = recentSessions.where((s) => s.result == 'completed').length;
    final completionRate = completedSessions / recentSessions.length;

    // Honesty score
    final honestyScore = stats.averageHonestyScore / 100;

    // Streak bonus
    final streakBonus = (stats.currentStreak / 30).clamp(0.0, 0.2);

    // Calculate final score
    final score = ((completionRate * 0.5) + (honestyScore * 0.3) + (streakBonus)) * 100;

    return score.clamp(0.0, 100.0);
  }

  /// Check if streak is at risk
  bool isStreakAtRisk() {
    final stats = _storage.getStats();
    final lastSessionDate = stats.lastSessionDate;

    if (lastSessionDate == null) return false;

    final hoursSinceLastSession = DateTime.now().difference(lastSessionDate).inHours;
    return hoursSinceLastSession > 24 && hoursSinceLastSession < AppConstants.streakGracePeriodHours;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

