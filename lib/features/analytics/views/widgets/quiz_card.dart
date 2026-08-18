import 'package:flutter/material.dart';
import 'package:uniapp/features/analytics/views/widgets/quiz_detail.dart';
import 'package:uniapp/features/analytics/views/widgets/quiz_stat.dart';

class QuizCard extends StatelessWidget {
  final Map<String, dynamic> quiz;
  final bool isExpanded;
  final VoidCallback onTap;

  const QuizCard({
    super.key,
    required this.quiz,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    quiz['quiz_name'] ?? "",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey[600],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 20,
              children: [
                QuizStat(
                  value: '${quiz['attempts']}',
                  label: 'Attempts',
                  icon: Icons.list_alt_outlined,
                  color: Colors.blue,
                ),
                QuizStat(
                  value: '${quiz['score'].roundToDouble()}%',
                  label: 'Score',
                  icon: Icons.star,
                  color: Colors.amber,
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 16),
              Divider(color: Colors.grey.withValues(alpha: 0.2)),
              const SizedBox(height: 8),
              Row(
                children: [
                  QuizDetail(
                    icon: Icons.list_alt_outlined,
                    label: '${quiz['questions']} Questions',
                  ),
                  const SizedBox(width: 16),
                  QuizDetail(
                    icon: Icons.timer,
                    label: quiz['quiz_time'].toString(),
                  ),
                  const SizedBox(width: 16),
                  QuizDetail(
                    icon: Icons.close,
                    label: '${quiz['errors']} mistakes',
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
