/// Trạng thái của một flashcard trong progress
enum CardStatus { unknown, learning, known }

CardStatus cardStatusFromString(String s) {
  switch (s.toUpperCase()) {
    case 'KNOWN': return CardStatus.known;
    case 'LEARNING': return CardStatus.learning;
    default: return CardStatus.unknown;
  }
}

String cardStatusToString(CardStatus s) {
  switch (s) {
    case CardStatus.known: return 'KNOWN';
    case CardStatus.learning: return 'LEARNING';
    case CardStatus.unknown: return 'UNKNOWN';
  }
}

/// Điểm dữ liệu học theo ngày — dùng cho bar chart
class DailyStudy {
  final String day;   // 'T2', 'T3', ..., 'CN'
  final int cardsStudied;

  const DailyStudy({required this.day, required this.cardsStudied});

  factory DailyStudy.fromJson(Map<String, dynamic> json) => DailyStudy(
    day: json['day'] ?? '',
    cardsStudied: json['cardsStudied'] ?? 0,
  );
}

/// Summary từ GET /api/progress/summary
class ProgressSummary {
  final int totalKnownCards;
  final int totalQuizzesTaken;
  final double avgScorePercentage;
  final int totalStudySets;
  final int currentStreak;
  final List<DailyStudy> weeklyActivity;

  ProgressSummary({
    required this.totalKnownCards,
    required this.totalQuizzesTaken,
    required this.avgScorePercentage,
    required this.totalStudySets,
    this.currentStreak = 0,
    this.weeklyActivity = const [],
  });

  factory ProgressSummary.fromJson(Map<String, dynamic> json) => ProgressSummary(
    totalKnownCards: json['totalKnownCards'] ?? 0,
    totalQuizzesTaken: json['totalQuizzesTaken'] ?? 0,
    avgScorePercentage: (json['avgScorePercentage'] ?? 0).toDouble(),
    totalStudySets: json['totalStudySets'] ?? 0,
    currentStreak: json['currentStreak'] ?? 0,
    weeklyActivity: (json['weeklyActivity'] as List? ?? [])
        .map((e) => DailyStudy.fromJson(e))
        .toList(),
  );
}

/// Progress của một bộ học — từ GET /api/progress/sets
class StudySetProgress {
  final int studySetId;
  final String studySetTitle;
  final String? subject;
  final int knownCards;
  final int totalCards;

  StudySetProgress({
    required this.studySetId,
    required this.studySetTitle,
    this.subject,
    required this.knownCards,
    required this.totalCards,
  });

  /// Tỷ lệ hoàn thành 0.0 → 1.0
  double get completionRate =>
      totalCards > 0 ? knownCards / totalCards : 0.0;

  factory StudySetProgress.fromJson(Map<String, dynamic> json) =>
      StudySetProgress(
        studySetId: json['studySetId'] ?? 0,
        studySetTitle: json['studySetTitle'] ?? '',
        subject: json['subject'],
        knownCards: json['knownCards'] ?? 0,
        totalCards: json['totalCards'] ?? 0,
      );
}
