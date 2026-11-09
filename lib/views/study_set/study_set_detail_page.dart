import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_router.dart';
import '../../core/app_text_styles.dart';
import '../../models/flashcard.dart';
import '../../models/quiz_result.dart';
import '../../models/study_set.dart';
import '../../viewmodels/study_set_viewmodel.dart';
import '../../viewmodels/study_viewmodel.dart';

class StudySetDetailPage extends StatefulWidget {
  final int studySetId;

  const StudySetDetailPage({super.key, required this.studySetId});

  @override
  State<StudySetDetailPage> createState() => _StudySetDetailPageState();
}

class _StudySetDetailPageState extends State<StudySetDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<StudySetViewModel>();
      if (!vm.isLoading) vm.loadStudySets();
      // Tải lịch sử quiz khi vào màn
      context.read<StudyViewModel>().loadQuizHistory(widget.studySetId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudySetViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final studySet = vm.getStudySetById(widget.studySetId);

        if (studySet == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  // Cream header khi không tìm thấy bộ học
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 24, 16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutes.home);
                            }
                          },
                          iconSize: 20,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Center(child: Text('Không tìm thấy bộ học')),
                  ),
                ],
              ),
            ),
          );
        }

        return _StudySetDetailView(
          studySet: studySet,
          studySetId: widget.studySetId,
        );
      },
    );
  }
}

class _StudySetDetailView extends StatelessWidget {
  final StudySet studySet;
  final int studySetId;

  const _StudySetDetailView({
    required this.studySet,
    required this.studySetId,
  });

  @override
  Widget build(BuildContext context) {
    final subject = studySet.subject;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // [A] Cream header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 24, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.home);
                      }
                    },
                    iconSize: 20,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (subject != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.getSubjectBgColor(subject),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              subject.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: AppColors.getSubjectTextColor(subject),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(studySet.title, style: AppTextStyles.h2),
                        Text(
                          '${studySet.cardCount} thẻ',
                          style: AppTextStyles.mono
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // [B] White sheet
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildActionButtons(context),
                    const SizedBox(height: 20),
                    _QuizHistorySection(studySetId: studySetId),
                    const SizedBox(height: 8),
                    const Divider(color: AppColors.border, height: 1),
                    const SizedBox(height: 12),
                    const Text('Danh sách thẻ', style: AppTextStyles.h2),
                    const SizedBox(height: 12),
                    ...studySet.flashcards.expand(
                      (card) => [
                        _FlashcardItem(flashcard: card),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Consumer<StudyViewModel>(
      builder: (context, studyVm, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bắt đầu học — primary background
            ElevatedButton(
              onPressed: () => context.go('/study/$studySetId/flashcard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Bắt đầu học'),
            ),
            const SizedBox(height: 10),

            // Làm quiz — primaryLight background
            ElevatedButton(
              onPressed: () => context.go('/study/$studySetId/quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Làm quiz'),
            ),
            const SizedBox(height: 10),

            // Ôn thẻ yếu — warning outlined, badge count khi đã tải
            OutlinedButton(
              onPressed: studyVm.isLoading
                  ? null
                  : () async {
                      await studyVm.loadWeakCards(studySetId);
                      if (!context.mounted) return;
                      if (studyVm.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(studyVm.errorMessage!),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                        ));
                        return;
                      }
                      if (studyVm.weakCards.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bạn đã biết tất cả thẻ trong bộ học này!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      context.go('/review/weak/$studySetId');
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: const BorderSide(color: AppColors.warning, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: studyVm.isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.warning,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Ôn thẻ yếu'),
                        if (studyVm.weakCards.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${studyVm.weakCards.length}',
                              style: AppTextStyles.mono
                                  .copyWith(color: AppColors.warning),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: 10),

            // Bình luận — outlined
            OutlinedButton(
              onPressed: () => context.go('/study/$studySetId/chat'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Bình luận'),
            ),
          ],
        );
      },
    );
  }
}

class _FlashcardItem extends StatelessWidget {
  final Flashcard flashcard;

  const _FlashcardItem({required this.flashcard});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDim,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(flashcard.term, style: AppTextStyles.h3),
          const SizedBox(height: 6),
          Text(
            flashcard.definition,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── Quiz History Section ─────────────────────────────────────────────────────

/// Widget hiển thị lịch sử các lần làm quiz của bộ học.
/// Nếu chưa có lần làm nào thì không render gì.
class _QuizHistorySection extends StatelessWidget {
  final int studySetId;

  const _QuizHistorySection({required this.studySetId});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudyViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoadingHistory) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (vm.quizHistory.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lịch sử quiz', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            ...vm.quizHistory.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _QuizHistoryTile(
                  item: item,
                  studySetId: studySetId,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}

class _QuizHistoryTile extends StatelessWidget {
  final QuizHistoryItem item;
  final int studySetId;

  const _QuizHistoryTile({required this.item, required this.studySetId});

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final passed = item.percentage >= 50;
    final pct = item.percentage.round();

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceDim,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            // Score circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: passed ? AppColors.knownLight : AppColors.unknownLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$pct%',
                  style: AppTextStyles.mono.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: passed ? AppColors.known : AppColors.unknown,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Score text + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.score}/${item.totalQuestions} câu đúng',
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(item.takenAt),
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuizHistoryDetailSheet(
        item: item,
        studySetId: studySetId,
      ),
    );
  }
}

/// Bottom sheet chi tiết một lần làm quiz.
class _QuizHistoryDetailSheet extends StatelessWidget {
  final QuizHistoryItem item;
  final int studySetId;

  const _QuizHistoryDetailSheet({
    required this.item,
    required this.studySetId,
  });

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('EEEE, dd/MM/yyyy – HH:mm', 'vi').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final passed = item.percentage >= 50;
    final pct = item.percentage.round();
    final wrong = item.totalQuestions - item.score;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Tiêu đề
          Text(
            passed ? '🎉 Kết quả tốt!' : 'Cố gắng hơn nhé!',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(item.takenAt),
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Khung điểm
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: passed ? AppColors.knownLight : AppColors.unknownLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatCell(
                  label: 'Điểm',
                  value: '${item.score}/${item.totalQuestions}',
                  color: passed ? AppColors.known : AppColors.unknown,
                ),
                Container(width: 1, height: 40, color: AppColors.border),
                _StatCell(
                  label: 'Chính xác',
                  value: '$pct%',
                  color: passed ? AppColors.known : AppColors.unknown,
                ),
                Container(width: 1, height: 40, color: AppColors.border),
                _StatCell(
                  label: 'Câu sai',
                  value: '$wrong',
                  color: wrong > 0 ? AppColors.unknown : AppColors.known,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Nút làm lại quiz
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/study/$studySetId/quiz');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Làm quiz lại',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),

          // Nút ôn thẻ yếu (làm lại câu sai qua weak cards)
          if (wrong > 0)
            OutlinedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final vm = context.read<StudyViewModel>();
                await vm.loadWeakCards(studySetId);
                if (!context.mounted) return;
                if (vm.weakCards.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Không có thẻ nào cần ôn lại!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                context.go('/review/weak/$studySetId');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.unknown,
                side: const BorderSide(color: AppColors.unknown, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Ôn lại thẻ sai ($wrong)',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCell({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.monoLarge.copyWith(color: color, fontSize: 22),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
