import 'flashcard.dart';

class StudySet {
  final int id;
  final String title;
  final String? description;
  final String? subject;
  final bool isPublic;
  final int cardCount;
  final String? createdAt;
  final Map<String, dynamic>? owner;
  final List<Flashcard> flashcards;
  // Progress fields — từ BE khi gọi GET /api/study-sets
  final int knownCards;
  final double completionRate;

  StudySet({
    required this.id,
    required this.title,
    this.description,
    this.subject,
    this.isPublic = true,
    this.cardCount = 0,
    this.createdAt,
    this.owner,
    this.flashcards = const [],
    this.knownCards = 0,
    this.completionRate = 0.0,
  });

  factory StudySet.fromJson(Map<String, dynamic> json) => StudySet(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    subject: json['subject'],
    isPublic: json['isPublic'] ?? true,
    cardCount: json['cardCount'] ?? 0,
    createdAt: json['createdAt'],
    owner: json['owner'],
    flashcards: (json['flashcards'] as List? ?? [])
        .map((e) => Flashcard.fromJson(e))
        .toList(),
    knownCards: json['knownCards'] ?? 0,
    completionRate: (json['completionRate'] ?? 0.0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'subject': subject,
    'isPublic': isPublic,
    'cardCount': cardCount,
  };
}
