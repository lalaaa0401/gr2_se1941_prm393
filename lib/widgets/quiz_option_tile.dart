import 'package:flutter/material.dart';

class QuizOptionTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  const QuizOptionTile({super.key, required this.text, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(12),
      child: Text(text),
    );
  }
}
