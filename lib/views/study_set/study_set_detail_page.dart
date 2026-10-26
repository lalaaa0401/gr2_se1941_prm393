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
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final studySet = vm.getStudySetById(widget.studySetId);

        if (studySet == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme:
                  const IconThemeData(color: AppColors.textPrimary),
            ),
            body: const Center(
              child: Text('Không tìm thấy bộ học'),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(studySet.title, style: AppTextStyles.h2),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme:
            const IconThemeData(color: AppColors.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildActionButtons(context),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border),
          const SizedBox(height: 8),
          const Text('Danh sách thẻ', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          ...studySet.flashcards.expand(
            (card) => [
              _FlashcardItem(flashcard: card),
              const Divider(color: AppColors.border, height: 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(studySet.title, style: AppTextStyles.h1),
        if (studySet.subject != null) ...[
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              studySet.subject!,
              style:
                  AppTextStyles.label.copyWith(color: AppColors.primary),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          '${studySet.cardCount} thẻ',
          style: AppTextStyles.mono
              .copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.01,
            ),
          ),
          child: const Text('Bắt đầu học'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => context.go('/study/$studySetId/quiz'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 0,
          ),
          child: const Text('Làm quiz'),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            flashcard.term,
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 4),
          Text(
            flashcard.definition,
            style: AppTextStyles.body
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
