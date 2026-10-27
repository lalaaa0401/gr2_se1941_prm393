import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_router.dart';
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
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // [A] Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kết quả quiz',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        passed ? '🎉 Xuất sắc!' : 'Cố gắng hơn nào!',
                        style: AppTextStyles.h1,
                      ),
                    ],
                  ),
                ),

                // [B] White sheet
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Khung điểm số
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 32, horizontal: 24),
                            decoration: BoxDecoration(
                              color: passed
                                  ? AppColors.knownLight
                                  : AppColors.unknownLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '$score/$total',
                                  style: AppTextStyles.monoLarge.copyWith(
                                    fontSize: 48,
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
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.01,
                              ),
                            ),
                            child: const Text('Học lại flashcard'),
                          ),
                          const SizedBox(height: 10),

                          // Ôn lại thẻ sai — chỉ hiện khi có thẻ sai
                          if (vm.wrongCards.isNotEmpty) ...[
                            ElevatedButton(
                              onPressed: () =>
                                  context.go(AppRoutes.reviewWrong),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.unknownLight,
                                foregroundColor: AppColors.unknown,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.01,
                                ),
                              ),
                              child: Text(
                                  'Ôn lại thẻ sai (${vm.wrongCards.length})'),
                            ),
                            const SizedBox(height: 10),
                          ],

                          // Làm quiz lại
                          OutlinedButton(
                            onPressed: () =>
                                context.go('/study/$studySetId/quiz'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(
                                  color: AppColors.border, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Làm quiz lại'),
                          ),
                          const SizedBox(height: 10),

                          // Về trang chính
                          TextButton(
                            onPressed: () => context.go('/home'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Về trang chính'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
