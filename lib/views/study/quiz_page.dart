import 'package:flutter/material.dart';

class QuizPage extends StatelessWidget {
  final int studySetId;
  const QuizPage({super.key, required this.studySetId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Center(child: Text('QuizPage #$studySetId – coming soon')),
    );
  }
}
