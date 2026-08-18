import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:uniapp/core/widgets/app_button.dart';
import 'package:uniapp/features/completed/data/completed_service.dart';
import 'package:uniapp/features/pages/views/page_view.dart';

class QuizCompletedView extends StatefulWidget {
  final double score;
  final String quizTitle;
  final Duration? time;
  const QuizCompletedView({
    super.key,
    required this.quizTitle,
    required this.score,
    this.time,
  });

  @override
  State<QuizCompletedView> createState() => _QuizCompletedViewState();
}

class _QuizCompletedViewState extends State<QuizCompletedView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late ConfettiController _confettiController;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
    if (widget.score >= 50) {
      _confettiController.play();
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() => _showDetails = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String _getPerformanceMessage(double score) {
    if (score >= 90) return 'Outstanding!';
    if (score >= 80) return 'Excellent Work!';
    if (score >= 70) return 'Great Job!';
    if (score >= 60) return 'Well Done!';
    if (score >= 50) return 'You Passed!';
    return 'Keep Practicing!';
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return const Color(0xFF4CAF50);
    if (score >= 80) return const Color(0xFF8BC34A);
    if (score >= 70) return const Color(0xFFCDDC39);
    if (score >= 60) return const Color(0xFFFFC107);
    if (score >= 50) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  @override
  Widget build(BuildContext context) {
    final passed = widget.score >= 50;
    final scoreColor = _getScoreColor(widget.score);
    final performanceMessage = _getPerformanceMessage(widget.score);
    final correctAnswers = (widget.score / (100 / 3)).round();
    final percentage = widget.score.round().toString();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[50]!, Colors.grey[100]!],
                ),
              ),
            ),
          ),

          if (passed)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
              ),
            ),

          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated result icon
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: scoreColor.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          passed ? Icons.celebration : Icons.auto_awesome,
                          color: passed ? scoreColor : Colors.grey[400],
                          size: 100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    FadeTransition(
                      opacity: _opacityAnimation,
                      child: Text(
                        performanceMessage,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.white.withValues(alpha: 0.8),
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 130,
                          height: 130,
                          child: AnimatedRotation(
                            duration: const Duration(seconds: 2),
                            curve: Curves.elasticOut,
                            turns: 1,
                            child: CircularProgressIndicator(
                              value: widget.score / 100,
                              strokeWidth: 12,
                              backgroundColor: Colors.grey[200],
                              color: scoreColor,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$percentage%',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: scoreColor,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your Score',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    if (_showDetails)
                      AnimatedOpacity(
                        opacity: _showDetails ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutBack,
                          transform: Matrix4.translationValues(
                            0,
                            _showDetails ? 0 : 50,
                            0,
                          ),
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildScoreRow(
                                'Correct Answers',
                                '$correctAnswers/${3}',
                                Icons.check_circle,
                                Colors.green,
                              ),

                              const Divider(height: 20),
                              _buildScoreRow(
                                'Your Performance',
                                '$percentage%',
                                Icons.assessment,
                                scoreColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (widget.time != null)
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          'Time taken: ${widget.time!.inMinutes} minutes ${widget.time!.inSeconds.remainder(60)} seconds',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    SizedBox(height: 20),
                    AppButton(
                      ontap: () {
                        final formattedTime =
                            widget.time != null
                                ? '${widget.time!.inMinutes}:${widget.time!.inSeconds.remainder(60).toString().padLeft(2, '0')}'
                                : 'N/A';
                        CompletedService.instance.setRecentQuiz(
                          quizTitle: widget.quizTitle,
                          score: widget.score,
                          time: formattedTime,
                          errors: 3 - correctAnswers,
                        );

                        CompletedService.instance.setQuizAnalyticsForQuiz(
                          quizTitle: widget.quizTitle,
                          score: widget.score,
                          time: formattedTime,
                        );

                        Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(
                            builder: (context) => QuizAppBottomNav(),
                          ),
                          (routes) => false,
                        );
                      },
                      child: Text("FINISH"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
