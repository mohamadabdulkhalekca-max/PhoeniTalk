import 'package:flutter/material.dart';

class QuizAppBar extends StatelessWidget {
  final int currentPage;
  final int totalQuestions;
  final VoidCallback onExitPressed;

  const QuizAppBar({
    super.key,
    required this.currentPage,
    required this.totalQuestions,
    required this.onExitPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: onExitPressed,
          ),
          const Spacer(),
          Text(
            'Question ${currentPage + 1}/$totalQuestions',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
