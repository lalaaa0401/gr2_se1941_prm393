class Flashcard {
  final int id;
  final String term;
  final String definition;
  final String? imageUrl;
  final int position;

  Flashcard({
    required this.id,
    required this.term,
    required this.definition,
    this.imageUrl,
    this.position = 0,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    id: json['id'],
    term: json['term'],
    definition: json['definition'],
    imageUrl: json['imageUrl'],
    position: json['position'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'term': term,
    'definition': definition,
    'imageUrl': imageUrl,
    'position': position,
  };
}
