import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/flashcard.dart';
import '../../viewmodels/study_set_viewmodel.dart';
import '../../viewmodels/study_viewmodel.dart';
import '../../widgets/flashcard_card.dart';

/// T2-P4-02 – Trang học flashcard theo kiểu lật thẻ (v5 layout).
class FlashcardStudyPage extends StatefulWidget {
  final int studySetId;

  const FlashcardStudyPage({super.key, required this.studySetId});

  @override
  State<FlashcardStudyPage> createState() => _FlashcardStudyPageState();
}

class _FlashcardStudyPageState extends State<FlashcardStudyPage> {
  int _currentIndex = 0;
  int _knownCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<StudySetViewModel>();
      if (!vm.isLoading) vm.loadStudySets();
    });
  }

  void _advance(BuildContext context, bool known, List<Flashcard> flashcards) {
    final total = flashcards.length;
    final safeIdx = _currentIndex.clamp(0, total - 1);
    final currentCard = flashcards[safeIdx];
    final newKnown = _knownCount + (known ? 1 : 0);

    // Cập nhật API ngầm thông qua StudyViewModel
    final studyVm = context.read<StudyViewModel>();
    if (known) {
      studyVm.markKnown(widget.studySetId, currentCard.id);
    } else {
      studyVm.markUnknown(widget.studySetId, currentCard.id);
    }

    if (_currentIndex >= total - 1) {
      setState(() => _knownCount = newKnown);
      _showSummaryDialog(context, newKnown, total);
    } else {
      setState(() {
        _knownCount = newKnown;
        _currentIndex++;
      });
    }
  }

  void _showSummaryDialog(BuildContext context, int known, int total) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        title: const Text('Đã học xong!', style: AppTextStyles.h2),
        content: RichText(
          text: TextSpan(
            style: AppTextStyles.body,
            children: [
              TextSpan(
                text: '$known/$total',
                style: AppTextStyles.mono.copyWith(fontSize: 14),
              ),
              const TextSpan(text: ' thẻ biết'),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          OutlinedButton(
            onPressed: () => context.go('/home'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text('Về trang chính'),
          ),
          ElevatedButton(
            onPressed: () =>
                context.go('/study/${widget.studySetId}/quiz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Làm quiz'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudySetViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final studySet = vm.getStudySetById(widget.studySetId);

        if (studySet == null || studySet.flashcards.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () { if (context.canPop()) context.pop(); else context.go('/home'); },
                          color: AppColors.textSecondary,
                          iconSize: 22,
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('Không có thẻ nào trong bộ học này.'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final flashcards = studySet.flashcards;
        final total = flashcards.length;
        // Clamp in case state outlives a data reload
        final safeIndex = _currentIndex.clamp(0, total - 1);
        final current = flashcards[safeIndex];
        final progress = (safeIndex + 1) / total;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // [A] Header row: close + progress bar + known count
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () { if (context.canPop()) context.pop(); else context.go('/home'); },
                        color: AppColors.textSecondary,
                        iconSize: 22,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary),
                          minHeight: 5,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$_knownCount biết',
                        style: AppTextStyles.mono
                            .copyWith(color: AppColors.known),
                      ),
                    ],
                  ),
                ),

                // [B] Spacing
                const SizedBox(height: 12),

                // [C] Card count row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Thẻ ${safeIndex + 1} / $total',
                        style: AppTextStyles.mono
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      Flexible(
                        child: Text(
                          studySet.title,
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // [D] Spacing
                const SizedBox(height: 24),

                // [E] Flashcard
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: FlashcardCard(
                      key: ValueKey(current.id),
                      flashcard: current,
                    ),
                  ),
                ),

                // [F] Spacing
                const SizedBox(height: 32),

                // [G] Action buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _advance(context, false, flashcards),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.unknownLight,
                            foregroundColor: AppColors.unknown,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Chưa biết'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _advance(context, true, flashcards),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.knownLight,
                            foregroundColor: AppColors.known,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Biết rồi'),
                        ),
                      ),
                    ],
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
