import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/flashcard.dart';
import '../../viewmodels/study_set_viewmodel.dart';
import '../../widgets/flashcard_card.dart';

/// T2-P4-02 – Trang học flashcard theo kiểu lật thẻ.
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
    final newKnown = _knownCount + (known ? 1 : 0);

    if (_currentIndex >= total - 1) {
      // Cập nhật trạng thái trước khi hiện dialog
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
          borderRadius: BorderRadius.circular(4),
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
                borderRadius: BorderRadius.circular(4),
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
                borderRadius: BorderRadius.circular(4),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.01,
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
            appBar: AppBar(
              title: const Text('Học flashcard', style: AppTextStyles.h2),
              backgroundColor: AppColors.surface,
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
            ),
            body: const Center(
              child: Text('Không có thẻ nào trong bộ học này.'),
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
          appBar: AppBar(
            title: Text(studySet.title, style: AppTextStyles.h2),
            backgroundColor: AppColors.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tiến độ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Thẻ ${safeIndex + 1} / $total',
                      style: AppTextStyles.mono,
                    ),
                    Text(
                      '$_knownCount biết',
                      style: AppTextStyles.mono
                          .copyWith(color: AppColors.known),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.surfaceDim,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
                const SizedBox(height: 20),

                // Thẻ flashcard
                FlashcardCard(
                  key: ValueKey(current.id),
                  flashcard: current,
                ),

                const Spacer(),

                // Nút hành động
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            _advance(context, false, flashcards),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.unknown,
                          side: const BorderSide(
                            color: AppColors.unknown,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          elevation: 0,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.01,
                          ),
                        ),
                        child: const Text('Chưa biết'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            _advance(context, true, flashcards),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.known,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.01,
                          ),
                        ),
                        child: const Text('Biết'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
