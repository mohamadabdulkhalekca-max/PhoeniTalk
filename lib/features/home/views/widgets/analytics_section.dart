import 'package:flutter/material.dart';
import 'package:uniapp/global_services.dart/quiz_analytics_service.dart';

class AnalyticsSection extends StatefulWidget {
  const AnalyticsSection({super.key});

  @override
  State<AnalyticsSection> createState() => _AnalyticsSectionState();
}

class _AnalyticsSectionState extends State<AnalyticsSection> {
  List<Map<String, dynamic>> quizData = [];

  Color getStatusColor(double score) {
    return score >= 50 ? Colors.green : Colors.redAccent;
  }

  String getStatusLabel(double score) {
    return score >= 50 ? "Success" : "Failed";
  }

  IconData getStatusIcon(double score) {
    return score >= 50 ? Icons.check_circle_outline : Icons.cancel_outlined;
  }

  @override
  void initState() {
    getQuizAnalyticsInView();
    super.initState();
  }

  getQuizAnalyticsInView() async {
    final QuizAnalyticsService quizAnalyticsService =
        QuizAnalyticsService.instance;

    quizData = await quizAnalyticsService.getQuizAnalytics();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2, vertical: 20),
          child: Text(
            "Quiz Analytics",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        quizData.isEmpty
            ? SizedBox(
              height: 200,

              child: Center(child: Text("No quiz data available.")),
            )
            : ListView.separated(
              itemCount: quizData.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 1),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final quiz = quizData[index];
                final statusColor = getStatusColor(quiz['score']);

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: statusColor.withValues(alpha: 0.1),
                      child: Icon(
                        getStatusIcon(quiz['score']),
                        color: statusColor,
                      ),
                    ),
                    title: Text(
                      quiz['quiz_name'] ?? "",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            quiz['quiz_time'] ?? "",
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.error_outline,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${quiz['errors']} error${quiz['errors'] == 1 ? '' : 's'}",
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        getStatusLabel(quiz['score']),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        const SizedBox(height: 16),
      ],
    );
  }
}
