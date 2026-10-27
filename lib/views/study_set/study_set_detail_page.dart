import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/flashcard.dart';
import '../../models/study_set.dart';
import '../../viewmodels/study_set_viewmodel.dart';

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
                          onPressed: () => context.pop(),
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
                    onPressed: () => context.pop(),
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

  Widget _buildActionButtons(BuildContext context) {
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
