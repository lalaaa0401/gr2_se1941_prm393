import 'package:flutter/material.dart';

class QuizResultPage extends StatelessWidget {
  final int studySetId;
  const QuizResultPage({super.key, required this.studySetId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả quiz')),
      body: Center(child: Text('QuizResultPage #$studySetId – coming soon')),
    );
  }
}
