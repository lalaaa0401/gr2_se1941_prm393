import 'package:flutter/material.dart';

class FlashcardStudyPage extends StatelessWidget {
  final int studySetId;
  const FlashcardStudyPage({super.key, required this.studySetId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Học flashcard')),
      body: Center(child: Text('FlashcardStudyPage #$studySetId – coming soon')),
    );
  }
}
