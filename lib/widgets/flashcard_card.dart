import 'dart:math';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../models/flashcard.dart';

/// T2-P4-01 – Thẻ flashcard có hiệu ứng lật (flip animation).
/// v5: Container + purple BoxShadow, radius 28, height 280.
class FlashcardCard extends StatefulWidget {
  final Flashcard flashcard;

  const FlashcardCard({super.key, required this.flashcard});

  @override
  State<FlashcardCard> createState() => _FlashcardCardState();
}

class _FlashcardCardState extends State<FlashcardCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(FlashcardCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset về mặt trước khi chuyển sang thẻ mới
    if (oldWidget.flashcard.id != widget.flashcard.id) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isAnimating) return;
    if (_controller.isDismissed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final angle = _animation.value * pi;
          final isFront = _animation.value < 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(isFront ? angle : angle + pi),
            child: Container(
              width: double.infinity,
              height: 280,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              decoration: BoxDecoration(
                color: isFront ? AppColors.surface : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x266A5AE0),
                    blurRadius: 40,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: isFront ? _buildFront() : _buildBack(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              widget.flashcard.term,
              style: AppTextStyles.h1,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.fade,
            ),
          ),
          Positioned(
            bottom: 0,
            child: Text(
              'Nhấn để lật ↕',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Text(
          widget.flashcard.definition,
          style: AppTextStyles.body,
          textAlign: TextAlign.center,
          maxLines: 6,
          overflow: TextOverflow.fade,
        ),
      ),
    );
  }
}
