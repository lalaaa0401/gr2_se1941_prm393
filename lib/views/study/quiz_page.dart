import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/flashcard.dart';
import '../../viewmodels/study_set_viewmodel.dart';
import '../../viewmodels/study_viewmodel.dart';
import '../../widgets/quiz_option_tile.dart';

/// Dữ liệu một câu hỏi trắc nghiệm.
class _QuizQuestion {
  final String term;
  final List<String> options; // Đã shuffle
  final int correctIndex;

  const _QuizQuestion({
    required this.term,
    required this.options,
    required this.correctIndex,
  });
}

/// T3-P4-02 – Trang quiz trắc nghiệm 4 lựa chọn.
///
/// Sinh câu hỏi từ flashcards của study set: term = câu hỏi,
/// đáp án đúng = definition của thẻ, 3 distractors từ các thẻ còn lại.
class QuizPage extends StatefulWidget {
  final int studySetId;

  const QuizPage({super.key, required this.studySetId});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<_QuizQuestion> _questions = [];
  List<Flashcard> _flashcards = []; // thẻ gốc để tra cứu khi ghi nhận sai
  int _currentIdx = 0;
  int? _selectedIdx;
  bool _answered = false;
  int _score = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Xóa danh sách thẻ sai của phiên quiz trước
      context.read<StudyViewModel>().clearWrongCards();
      final vm = context.read<StudySetViewModel>();
      if (!vm.isLoading) vm.loadStudySets();
    });
  }

  /// Sinh danh sách câu hỏi MCQ từ flashcards — chỉ gọi một lần.
  void _initQuestions(List<Flashcard> flashcards) {
    if (_initialized || flashcards.isEmpty) return;
    _initialized = true;
    _flashcards = flashcards; // lưu lại để tra cứu khi trả lời sai
    _questions = _generateQuestions(flashcards);
  }

  List<_QuizQuestion> _generateQuestions(List<Flashcard> flashcards) {
    final rng = Random();
    return flashcards.map((card) {
      final otherDefs = flashcards
          .where((f) => f.id != card.id)
          .map((f) => f.definition)
          .toList()
        ..shuffle(rng);

      // Tối đa 3 distractors
      final distractors = otherDefs.take(3).toList();

      final allOptions = [card.definition, ...distractors]..shuffle(rng);
      final correctIndex = allOptions.indexOf(card.definition);

      return _QuizQuestion(
        term: card.term,
        options: allOptions,
        correctIndex: correctIndex,
      );
    }).toList();
  }

  void _selectOption(int idx) {
    if (_answered) return;
    final isCorrect = idx == _questions[_currentIdx].correctIndex;
    // Ghi nhận thẻ sai TRƯỚC setState để tránh notifyListeners trong setState
    if (!isCorrect && _flashcards.isNotEmpty) {
      context.read<StudyViewModel>().addWrongCard(_flashcards[_currentIdx]);
    }
    setState(() {
      _selectedIdx = idx;
      _answered = true;
      if (isCorrect) _score++;
    });
  }

  Future<void> _nextQuestion() async {
    if (_currentIdx >= _questions.length - 1) {
      // Submit kết quả rồi chuyển trang
      await context
          .read<StudyViewModel>()
          .submitQuizResult(widget.studySetId, _score, _questions.length);
      if (mounted) {
        context.go('/study/${widget.studySetId}/quiz/result');
      }
    } else {
      setState(() {
        _currentIdx++;
        _selectedIdx = null;
        _answered = false;
      });
    }
  }

  QuizOptionState _optionState(int optIdx) {
    if (!_answered) {
      return _selectedIdx == optIdx
          ? QuizOptionState.selected
          : QuizOptionState.idle;
    }
    final q = _questions[_currentIdx];
    if (optIdx == q.correctIndex) return QuizOptionState.correct;
    if (optIdx == _selectedIdx) return QuizOptionState.incorrect;
    return QuizOptionState.disabled;
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
            body: const Center(
              child: Text('Không có thẻ nào để tạo câu hỏi.'),
            ),
          );
        }

        _initQuestions(studySet.flashcards);

        if (_questions.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: const Center(
                child: Text('Không thể tạo câu hỏi từ bộ học này.')),
          );
        }

        final q = _questions[_currentIdx];
        final total = _questions.length;
        final progress = (_currentIdx + 1) / total;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // [A] Header row: back, counter, score
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                        onPressed: () => context.pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Câu ${_currentIdx + 1} / $total',
                            style: AppTextStyles.mono,
                          ),
                        ),
                      ),
                      if (_answered)
                        Text(
                          '$_score đúng',
                          style: AppTextStyles.mono
                              .copyWith(color: AppColors.known),
                        )
                      else
                        const SizedBox(width: 44),
                    ],
                  ),
                ),

                // [B] Progress bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.surfaceDim,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary),
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),

                // [C] White sheet
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
                          // Câu hỏi
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              q.term,
                              style: AppTextStyles.h2,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Lựa chọn
                          ...List.generate(
                            q.options.length,
                            (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: QuizOptionTile(
                                text: q.options[i],
                                state: _optionState(i),
                                onTap: () => _selectOption(i),
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Nút tiếp theo (chỉ hiện sau khi chọn đáp án)
                          if (_answered) ...[
                            ElevatedButton(
                              onPressed: _nextQuestion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.01,
                                ),
                              ),
                              child: Text(
                                _currentIdx >= _questions.length - 1
                                    ? 'Xem kết quả'
                                    : 'Tiếp theo',
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
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
