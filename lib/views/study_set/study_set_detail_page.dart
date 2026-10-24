import 'package:flutter/material.dart';

class StudySetDetailPage extends StatelessWidget {
  final int studySetId;
  const StudySetDetailPage({super.key, required this.studySetId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết bộ học')),
      body: Center(child: Text('StudySetDetailPage #$studySetId – coming soon')),
    );
  }
}
