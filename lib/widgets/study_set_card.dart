import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../models/study_set.dart';

/// Card hiển thị bộ học với màu nền theo môn học
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
          color: AppColors.getSubjectBgColor(studySet.subject),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nhãn môn học (uppercase)
            if (studySet.subject != null) ...[
              Text(
                studySet.subject!.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppColors.getSubjectTextColor(studySet.subject),
                ),
              ),
              const SizedBox(height: 6),
            ],
            // Tiêu đề bộ học
            Text(studySet.title, style: AppTextStyles.h3),
            const SizedBox(height: 10),
            // Số lượng thẻ
            Text(
              '${studySet.cardCount} thẻ',
              style: AppTextStyles.mono.copyWith(
                color: AppColors.getSubjectTextColor(studySet.subject),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
