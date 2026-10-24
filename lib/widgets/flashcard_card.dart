import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class FlashcardCard extends StatelessWidget {
  final Flashcard flashcard;
  const FlashcardCard({super.key, required this.flashcard});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Text(flashcard.term),
    );
  }
}
