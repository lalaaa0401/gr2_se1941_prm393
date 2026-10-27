import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

/// Trạng thái hiển thị của một lựa chọn trong quiz.
/// Dùng màu border/background để chỉ trạng thái — KHÔNG dùng icon ✓ / ✗.
enum QuizOptionState {
  /// Chưa chọn, chờ tương tác
  idle,

  /// Đang được chọn (trước khi reveal)
  selected,

  /// Đáp án đúng (sau khi reveal)
  correct,

  /// Đáp án sai (sau khi reveal)
  incorrect,

  /// Bị vô hiệu hoá (các option không được chọn sau khi đã reveal)
  disabled,
}

/// T3-P4-02 – Tile lựa chọn cho QuizPage.
class QuizOptionTile extends StatelessWidget {
  final String text;
  final QuizOptionState state;
  final VoidCallback? onTap;

  const QuizOptionTile({
    super.key,
    required this.text,
    this.state = QuizOptionState.idle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = _backgroundColor();
    final border = _borderSide();
    final textColor = state == QuizOptionState.disabled
        ? AppColors.textDisabled
        : AppColors.textPrimary;

    return GestureDetector(
      onTap: state == QuizOptionState.idle ? onTap : null,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: border.color,
            width: border.width,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          style: AppTextStyles.body.copyWith(color: textColor),
        ),
      ),
    );
  }

  Color _backgroundColor() => switch (state) {
        QuizOptionState.idle => AppColors.surface,
        QuizOptionState.selected => AppColors.primaryLight,
        QuizOptionState.correct => AppColors.knownLight,
        QuizOptionState.incorrect => AppColors.unknownLight,
        QuizOptionState.disabled => AppColors.surfaceDim,
      };

  BorderSide _borderSide() => switch (state) {
        QuizOptionState.idle =>
          const BorderSide(color: AppColors.border, width: 1),
        QuizOptionState.selected =>
          const BorderSide(color: AppColors.primary, width: 2),
        QuizOptionState.correct =>
          const BorderSide(color: AppColors.known, width: 2),
        QuizOptionState.incorrect =>
          const BorderSide(color: AppColors.error, width: 2),
        QuizOptionState.disabled =>
          const BorderSide(color: AppColors.border, width: 1),
      };
}
