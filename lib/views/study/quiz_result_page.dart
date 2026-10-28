import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../viewmodels/study_viewmodel.dart';

/// T3-P4-03 – Trang kết quả sau khi hoàn thành quiz.
///
/// Đọc điểm từ [StudyViewModel.lastScore] / [StudyViewModel.lastTotal]
/// (đã được QuizPage ghi trước khi navigate đến đây).
class QuizResultPage extends StatelessWidget {
  final int studySetId;

  const QuizResultPage({super.key, required this.studySetId});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudyViewModel>(
      builder: (context, vm, _) {
        final score = vm.lastScore ?? 0;
        final total = vm.lastTotal ?? 0;
        final percent =
            total > 0 ? ((score / total) * 100).round() : 0;
        final passed = score > total / 2;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Kết quả quiz', style: AppTextStyles.h2),
            backgroundColor: AppColors.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Khung điểm số
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$score / $total',
                        style: AppTextStyles.monoLarge.copyWith(
                          fontSize: 36,
                          color: passed
                              ? AppColors.known
                              : AppColors.unknown,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Đúng $percent%',
                        style: AppTextStyles.mono
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      if (total > 0)
                        Text(
                          '$score câu đúng · ${total - score} câu sai',
                          style: AppTextStyles.caption,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Học lại flashcard
                ElevatedButton(
                  onPressed: () =>
                      context.go('/study/$studySetId/flashcard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.01,
                    ),
                  ),
                  child: const Text('Học lại flashcard'),
                ),
                const SizedBox(height: 10),

                // Làm quiz lại
                OutlinedButton(
                  onPressed: () => context.go('/study/$studySetId/quiz'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Làm quiz lại'),
                ),
                const SizedBox(height: 10),

                // Về trang chính
                TextButton(
                  onPressed: () => context.go('/home'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Về trang chính'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
