import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uniapp/features/analytics/views/widgets/performance_chart.dart';
import 'package:uniapp/features/analytics/views/widgets/quiz_card.dart';
import 'package:uniapp/features/analytics/views/widgets/summary_card.dart';

class AnalyticsViewBody extends StatefulWidget {
  const AnalyticsViewBody({super.key});

  @override
  State<AnalyticsViewBody> createState() => _AnalyticsViewBodyState();
}

class _AnalyticsViewBodyState extends State<AnalyticsViewBody> {
  int _expandedQuizIndex = -1;
  List<Map<String, dynamic>> quizzes = [];
  bool isLoading = true;
  int totalAttempts = 0;
  double avgScore = 0;
  double avgCompletion = 0;

  final supabase = Supabase.instance.client;
  String quizAvgTime = '';

  @override
  void initState() {
    super.initState();
    _fetchAnalyticsData();
  }

  String _calculateAvgTime(List<Map<String, dynamic>> quizzes) {
    if (quizzes.isEmpty) return "00:00";

    int totalSeconds = 0;
    int validCount = 0;

    for (var quiz in quizzes) {
      if (quiz['quiz_time'] != null &&
          quiz['quiz_time'].toString().contains(":")) {
        final parts = quiz['quiz_time'].split(':');
        if (parts.length == 2) {
          final minutes = int.tryParse(parts[0]) ?? 0;
          final seconds = int.tryParse(parts[1]) ?? 0;
          totalSeconds += (minutes * 60) + seconds;
          validCount++;
        }
      }
    }

    if (validCount == 0) return "00:00";

    final avgSeconds = totalSeconds ~/ validCount;
    final avgMinutes = avgSeconds ~/ 60;
    final remainingSeconds = avgSeconds % 60;

    return "${avgMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  Future<void> _fetchAnalyticsData() async {
    try {
      final response = await supabase
          .from('quiz_analytics')
          .select()
          .eq('user_id', supabase.auth.currentUser!.id);
      quizzes = List<Map<String, dynamic>>.from(response);

      if (quizzes.isNotEmpty) {
        totalAttempts = quizzes.fold(
          0,
          (sum, q) => sum + (q['attempts'] as int? ?? 0),
        );

        double totalScores = 0;
        int validQuizCount = 0;

        for (var quiz in quizzes) {
          if (quiz['score'] != null) {
            totalScores += quiz['score'];
            validQuizCount++;
            quizAvgTime = quiz['quiz_time'];
          }
        }

        avgScore = validQuizCount == 0 ? 0 : totalScores / validQuizCount;

        double totalCompletion = 0;

        for (var quiz in quizzes) {
          final totalQuestions = quiz['questions'] as int? ?? 1;
          final errors = quiz['errors'] ?? 0;
          final correctAnswers = totalQuestions - errors;
          totalCompletion += (correctAnswers / totalQuestions) * 100;
        }

        avgCompletion = totalCompletion / quizzes.length;
        quizAvgTime = _calculateAvgTime(quizzes);
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching analytics: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SummaryCard(
              totalAttempts: totalAttempts,
              avgScore: avgScore,
              avgCompletion: avgCompletion,
              time: quizAvgTime,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Performance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: PerformanceChart(
              cardColor: Colors.white,
              shadowColor: Colors.white.withValues(alpha: .1),
              quizzes: quizzes,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                'Your Quizzes (${quizzes.length})',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (quizzes.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No quiz analytics available yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final quiz = quizzes[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: QuizCard(
                    quiz: quiz,
                    isExpanded: _expandedQuizIndex == index,
                    onTap:
                        () => setState(() {
                          _expandedQuizIndex =
                              _expandedQuizIndex == index ? -1 : index;
                        }),
                  ),
                );
              }, childCount: quizzes.length),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
