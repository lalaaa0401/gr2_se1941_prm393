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

  void _showQuizHistoryList(BuildContext context, StudyViewModel studyVm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: studyVm,
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (_, ctrl) => Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(children: [
              const SizedBox(height: 8),
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Lịch sử quiz', style: AppTextStyles.h2)),
              ),
              const SizedBox(height: 8),
              Expanded(child: Consumer<StudyViewModel>(
                builder: (ctx, vm, _) => ListView.separated(
                  controller: ctrl,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: vm.quizHistory.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _QuizHistoryTile(
                    item: vm.quizHistory[i],
                    studySetId: studySetId,
                  ),
                ),
              )),
            ]),
          ),
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
            const SizedBox(height: 10),
            // Lịch sử quiz — button, chỉ hiện khi đã làm quiz
            if (studyVm.quizHistory.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () => _showQuizHistoryList(context, studyVm),
                icon: const Icon(Icons.history_rounded, size: 18),
                label: Text(
                    'Lịch sử quiz (${studyVm.quizHistory.length})'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(
                      color: AppColors.primaryMuted, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
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
class _QuizHistoryTile extends StatelessWidget {
  final QuizResult item;
  final int studySetId;

  const _QuizHistoryTile({required this.item, required this.studySetId});

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = item.scorePercentage.round();
    final Color pctColor;
    if (pct >= 60) {
      pctColor = AppColors.known;
    } else if (pct >= 30) {
      pctColor = AppColors.warning;
    } else {
      pctColor = AppColors.error;
    }

    return InkWell(
      onTap: () => _showDetail(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceDim,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            // Date + score (left column)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(item.takenAt),
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.score}/${item.totalQuestions} câu đúng',
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            // Percentage badge (right)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: pctColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$pct%',
                style: AppTextStyles.mono.copyWith(
                  color: pctColor,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 6),
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
    final vm = context.read<StudyViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuizDetailSheet(
        quiz: item,
        vm: vm,
        studySetId: studySetId,
      ),
    );
  }
}

// ─── Quiz Detail Sheet ────────────────────────────────────────────────────────

class _QuizDetailSheet extends StatefulWidget {
  final QuizResult quiz;
  final StudyViewModel vm;
  final int studySetId;

  const _QuizDetailSheet({
    required this.quiz,
    required this.vm,
    required this.studySetId,
  });

  @override
  State<_QuizDetailSheet> createState() => _QuizDetailSheetState();
}

class _QuizDetailSheetState extends State<_QuizDetailSheet> {
  Future<QuizResultDetail?>? _detailsFuture;

  @override
  void initState() {
    super.initState();
    if (widget.quiz.wrongCardIds.isNotEmpty && widget.quiz.id != null) {
      _detailsFuture = widget.vm.loadQuizDetails(widget.quiz.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quiz = widget.quiz;
    final pct = quiz.scorePercentage.round();
    final Color pctColor;
    if (pct >= 60) {
      pctColor = AppColors.known;
    } else if (pct >= 30) {
      pctColor = AppColors.warning;
    } else {
      pctColor = AppColors.error;
    }

    final dateStr = () {
      final raw = quiz.takenAt ?? quiz.createdAt ?? '';
      if (raw.isEmpty) return '';
      try {
        return DateFormat('dd/MM/yyyy HH:mm')
            .format(DateTime.parse(raw).toLocal());
      } catch (_) {
        return raw;
      }
    }();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
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

            // Header row
            Row(
              children: [
                const Expanded(
                  child: Text('Chi tiết quiz', style: AppTextStyles.h2),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Score row
            Row(
              children: [
                Text(
                  '${quiz.score}/${quiz.totalQuestions}',
                  style: AppTextStyles.monoLarge.copyWith(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: pctColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$pct%',
                    style: AppTextStyles.mono
                        .copyWith(color: pctColor, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Date
            if (dateStr.isNotEmpty)
              Text(
                dateStr,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 16),

            // Wrong cards section
            if (quiz.wrongCardIds.isEmpty)
              const Text('🎉 Làm đúng tất cả!', style: AppTextStyles.body)
            else
              FutureBuilder<QuizResultDetail?>(
                future: _detailsFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final detail = snap.data;
                  if (detail == null || detail.wrongCards.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Câu sai (${detail.wrongCards.length})',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 8),
                      ...detail.wrongCards.map(
                        (card) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(top: 5),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      card.term,
                                      style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      card.definition,
                                      style: AppTextStyles.body.copyWith(
                                          color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Ôn lại thẻ sai
                      ElevatedButton(
                        onPressed: () async {
                          final d = await widget.vm
                              .loadQuizDetails(quiz.id!);
                          if (d == null || !context.mounted) return;
                          widget.vm.setReviewCards(d.wrongCards);
                          Navigator.of(context).pop();
                          if (context.mounted) {
                            context.go('/review/wrong');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Ôn lại thẻ sai (${quiz.wrongCardIds.length})',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 12),

            // Làm lại câu sai — chỉ quiz những thẻ sai
            OutlinedButton(
              onPressed: widget.quiz.wrongCardIds.isEmpty
                  ? null
                  : () async {
                      final detail = await widget.vm
                          .loadQuizDetails(widget.quiz.id ?? 0);
                      if (!context.mounted) return;
                      if (detail == null || detail.wrongCards.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Không có câu sai để làm lại!')));
                        return;
                      }
                      Navigator.pop(context);
                      widget.vm.setQuizCards(detail.wrongCards);
                      context.go('/study/${widget.studySetId}/quiz');
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.quiz.wrongCardIds.isEmpty
                    ? 'Làm lại quiz (đúng tất cả!)'
                    : 'Làm lại câu sai (${widget.quiz.wrongCardIds.length})',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

