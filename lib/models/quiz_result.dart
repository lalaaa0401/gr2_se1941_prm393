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
