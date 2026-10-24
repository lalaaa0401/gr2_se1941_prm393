import 'package:flutter/material.dart';
import '../models/study_set.dart';

class StudySetCard extends StatelessWidget {
  final StudySet studySet;
  const StudySetCard({super.key, required this.studySet});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(12),
      child: Text(studySet.title),
    );
  }
}
