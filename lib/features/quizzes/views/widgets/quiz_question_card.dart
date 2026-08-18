import 'package:flutter/material.dart';

class QuizQuestionCard extends StatelessWidget {
  final String question;
  final bool isAnswering;

  const QuizQuestionCard({
    super.key,
    required this.question,
    required this.isAnswering,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: Column(
        key: ValueKey(question),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFDEAEA),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primaryRed.withValues(alpha: 0.3)),
              ),
              child: Text(
                question,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

const Color primaryRed = Color(0xFFE53935);
