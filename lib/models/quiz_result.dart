class QuizResult {
  final int? id;
  final int studySetId;
  final int score;
  final int totalQuestions;
  final String? createdAt;

  QuizResult({
    this.id,
    required this.studySetId,
    required this.score,
    required this.totalQuestions,
    this.createdAt,
  });

  double get scorePercentage =>
      totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
    id: json['id'],
    studySetId: json['studySetId'],
    score: json['score'],
    totalQuestions: json['totalQuestions'],
    createdAt: json['createdAt'],
  );

  Map<String, dynamic> toJson() => {
    'studySetId': studySetId,
    'score': score,
    'totalQuestions': totalQuestions,
  };
}

/// Quiz history item từ GET /api/quiz-results/mine
class QuizHistoryItem {
  final int id;
  final String studySetTitle;
  final String? studySetSubject;
  final int score;
  final int totalQuestions;
  final double percentage;
  final String takenAt;

  QuizHistoryItem({
    required this.id,
    required this.studySetTitle,
    this.studySetSubject,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.takenAt,
  });

  factory QuizHistoryItem.fromJson(Map<String, dynamic> json) {
    final set = json['studySet'] as Map<String, dynamic>? ?? {};
    return QuizHistoryItem(
      id: json['id'] ?? 0,
      studySetTitle: set['title'] ?? '',
      studySetSubject: set['subject'],
      score: json['score'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      takenAt: json['takenAt'] ?? '',
    );
  }
}
