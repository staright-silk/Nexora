/// Focus session model
class FocusSession {
  final DateTime startTime;
  final DateTime? endTime;
  final int plannedDurationMinutes;
  final int actualDurationMinutes;
  final String mentalState;
  final String? subject;
  final String? topic;
  final bool wasHonest;
  final String result; // completed, abandoned, forced
  final String? musicCategory;
  final int distractionCount;

  FocusSession({
    required this.startTime,
    this.endTime,
    required this.plannedDurationMinutes,
    required this.actualDurationMinutes,
    required this.mentalState,
    this.subject,
    this.topic,
    this.wasHonest = true,
    required this.result,
    this.musicCategory,
    this.distractionCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'plannedDurationMinutes': plannedDurationMinutes,
      'actualDurationMinutes': actualDurationMinutes,
      'mentalState': mentalState,
      'subject': subject,
      'topic': topic,
      'wasHonest': wasHonest,
      'result': result,
      'musicCategory': musicCategory,
      'distractionCount': distractionCount,
    };
  }

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      plannedDurationMinutes: json['plannedDurationMinutes'],
      actualDurationMinutes: json['actualDurationMinutes'],
      mentalState: json['mentalState'],
      subject: json['subject'],
      topic: json['topic'],
      wasHonest: json['wasHonest'] ?? true,
      result: json['result'],
      musicCategory: json['musicCategory'],
      distractionCount: json['distractionCount'] ?? 0,
    );
  }
}

/// Task model
class StudyTask {
  final String id;
  final String subject;
  final String topic;
  final int estimatedMinutes;
  final List<String> subTasks;
  final bool isCompleted;
  final DateTime createdAt;

  StudyTask({
    required this.id,
    required this.subject,
    required this.topic,
    required this.estimatedMinutes,
    required this.subTasks,
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'topic': topic,
      'estimatedMinutes': estimatedMinutes,
      'subTasks': subTasks,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StudyTask.fromJson(Map<String, dynamic> json) {
    return StudyTask(
      id: json['id'],
      subject: json['subject'],
      topic: json['topic'],
      estimatedMinutes: json['estimatedMinutes'],
      subTasks: List<String>.from(json['subTasks']),
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  StudyTask copyWith({
    String? id,
    String? subject,
    String? topic,
    int? estimatedMinutes,
    List<String>? subTasks,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return StudyTask(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      subTasks: subTasks ?? this.subTasks,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// User statistics
class UserStats {
  final int currentStreak;
  final int longestStreak;
  final int totalFocusMinutes;
  final int totalSessions;
  final DateTime? lastSessionDate;
  final Map<String, int> mentalStateMinutes;
  final double averageHonestyScore;
  final int totalDistractedCount;

  UserStats({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalFocusMinutes = 0,
    this.totalSessions = 0,
    this.lastSessionDate,
    Map<String, int>? mentalStateMinutes,
    this.averageHonestyScore = 100.0,
    this.totalDistractedCount = 0,
  }) : mentalStateMinutes = mentalStateMinutes ?? {};

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalFocusMinutes': totalFocusMinutes,
      'totalSessions': totalSessions,
      'lastSessionDate': lastSessionDate?.toIso8601String(),
      'mentalStateMinutes': mentalStateMinutes,
      'averageHonestyScore': averageHonestyScore,
      'totalDistractedCount': totalDistractedCount,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      totalFocusMinutes: json['totalFocusMinutes'] ?? 0,
      totalSessions: json['totalSessions'] ?? 0,
      lastSessionDate: json['lastSessionDate'] != null
          ? DateTime.parse(json['lastSessionDate'])
          : null,
      mentalStateMinutes: json['mentalStateMinutes'] != null
          ? Map<String, int>.from(json['mentalStateMinutes'])
          : {},
      averageHonestyScore: json['averageHonestyScore'] ?? 100.0,
      totalDistractedCount: json['totalDistractedCount'] ?? 0,
    );
  }
}

/// Thought dump entry
class ThoughtEntry {
  final String id;
  final String thought;
  final DateTime timestamp;
  final bool isLocked;

  ThoughtEntry({
    required this.id,
    required this.thought,
    required this.timestamp,
    this.isLocked = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'thought': thought,
      'timestamp': timestamp.toIso8601String(),
      'isLocked': isLocked,
    };
  }

  factory ThoughtEntry.fromJson(Map<String, dynamic> json) {
    return ThoughtEntry(
      id: json['id'],
      thought: json['thought'],
      timestamp: DateTime.parse(json['timestamp']),
      isLocked: json['isLocked'] ?? false,
    );
  }
}

