import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/flashcard.dart';
import '../../viewmodels/study_viewmodel.dart';
import '../../widgets/flashcard_card.dart';

/// Nguồn thẻ cần ôn tập
enum ReviewSource {
  /// Thẻ trả lời sai trong phiên quiz vừa xong
  wrong,
  /// Thẻ yếu (UNKNOWN/LEARNING) từ API progress
  weak,
}

/// T3-P4-05 – Ôn tập lại thẻ sai / thẻ yếu.
///
/// - [ReviewSource.wrong]: đọc từ [StudyViewModel.wrongCards]
/// - [ReviewSource.weak]:  đọc từ [StudyViewModel.weakCards]
///   (cần gọi [StudyViewModel.loadWeakCards] trước khi navigate đến đây).
class ReviewFlashcardPage extends StatefulWidget {
  final ReviewSource source;

  /// Chỉ cần cho [ReviewSource.weak] — ID của bộ học.
  final int? studySetId;

  const ReviewFlashcardPage({
    super.key,
    required this.source,
    this.studySetId,
  });

  @override
  State<ReviewFlashcardPage> createState() => _ReviewFlashcardPageState();
}

class _ReviewFlashcardPageState extends State<ReviewFlashcardPage> {
  int _currentIndex = 0;
  int _knownCount = 0;
  late List<Flashcard> _cards;

  @override
  void initState() {
    super.initState();
    // Snapshot danh sách thẻ lúc bắt đầu ôn — không theo dõi thay đổi từ VM
    final vm = context.read<StudyViewModel>();
    _cards = List<Flashcard>.from(
      widget.source == ReviewSource.wrong ? vm.wrongCards : vm.weakCards,
    );
  }

  /// Tiến đến thẻ tiếp theo hoặc hiện dialog kết quả khi xong.
  void _advance(bool known) {
    final total = _cards.length;
    final newKnown = _knownCount + (known ? 1 : 0);

    if (_currentIndex >= total - 1) {
      setState(() => _knownCount = newKnown);
      _showSummaryDialog(newKnown, total);
    } else {
      setState(() {
        _knownCount = newKnown;
        _currentIndex++;
      });
    }
  }

  void _showSummaryDialog(int known, int total) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        title: const Text('Hoàn thành ôn tập!', style: AppTextStyles.h2),
        content: RichText(
          text: TextSpan(
            style: AppTextStyles.body,
            children: [
              TextSpan(
                text: '$known/$total',
                style: AppTextStyles.mono.copyWith(fontSize: 14),
              ),
              const TextSpan(text: ' thẻ đã biết'),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context); // đóng dialog
              // Bắt đầu lại từ đầu
              setState(() {
                _currentIndex = 0;
                _knownCount = 0;
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text('Ôn lại'),
          ),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Về trang chính'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Trường hợp không có thẻ nào cần ôn
    if (_cards.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    color: AppColors.textSecondary,
                    iconSize: 22,
                  ),
                ]),
              ),
              const Expanded(
                child: Center(
                  child: Text('Không có thẻ nào cần ôn tập.'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final total = _cards.length;
    final safeIndex = _currentIndex.clamp(0, total - 1);
    final current = _cards[safeIndex];
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
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
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
                          AppColors.unknown),
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$_knownCount biết',
                    style: AppTextStyles.mono.copyWith(color: AppColors.known),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // [B] Card count + title row
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
                  const Text('Ôn tập lại', style: AppTextStyles.caption),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // [C] Flashcard — reset animation khi đổi thẻ
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FlashcardCard(
                  key: ValueKey(current.id),
                  flashcard: current,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // [D] Chưa biết / Biết rồi buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _advance(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.unknownLight,
                        foregroundColor: AppColors.unknown,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                      onPressed: () => _advance(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.knownLight,
                        foregroundColor: AppColors.known,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
  }
}
