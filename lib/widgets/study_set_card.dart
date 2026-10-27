import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../models/study_set.dart';

/// Card hiển thị bộ học với màu nền theo môn học + progress bar
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
    final bgColor = AppColors.getSubjectBgColor(studySet.subject);
    final accentColor = AppColors.getSubjectTextColor(studySet.subject);
    final pct = (studySet.completionRate * 100).round();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject label uppercase
            if (studySet.subject != null) ...[
              Text(
                studySet.subject!.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 4),
            ],
            // Tiêu đề
            Text(studySet.title, style: AppTextStyles.h3),
            const SizedBox(height: 10),
            // Bottom row: cardCount + progress bar + %
            Row(
              children: [
                Text(
                  '${studySet.cardCount} thẻ',
                  style: AppTextStyles.mono.copyWith(color: accentColor.withValues(alpha: 0.8)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: studySet.completionRate,
                      minHeight: 4,
                      backgroundColor: Colors.black.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation(accentColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
