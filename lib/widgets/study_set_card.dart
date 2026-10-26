import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../models/study_set.dart';

class StudySetCard extends StatelessWidget {
  final StudySet studySet;
  final VoidCallback? onTap;

  const StudySetCard({
    super.key,
    required this.studySet,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(studySet.title, style: AppTextStyles.h2),
            if (studySet.subject != null) ...[
              const SizedBox(height: 8),
              _SubjectChip(label: studySet.subject!),
            ],
            const SizedBox(height: 8),
            Text(
              '${studySet.cardCount} thẻ',
              style: AppTextStyles.mono.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  final String label;

  const _SubjectChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: AppColors.primary),
      ),
    );
  }
}
