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

/// Summary từ GET /api/progress/summary — dùng cho fl_chart
class ProgressSummary {
  final int totalKnownCards;
  final int totalQuizzesTaken;
  final double avgScorePercentage;
  final int totalStudySets;

  ProgressSummary({
    required this.totalKnownCards,
    required this.totalQuizzesTaken,
    required this.avgScorePercentage,
    required this.totalStudySets,
  });

  factory ProgressSummary.fromJson(Map<String, dynamic> json) => ProgressSummary(
    totalKnownCards: json['totalKnownCards'] ?? 0,
    totalQuizzesTaken: json['totalQuizzesTaken'] ?? 0,
    avgScorePercentage: (json['avgScorePercentage'] ?? 0).toDouble(),
    totalStudySets: json['totalStudySets'] ?? 0,
  );
}
