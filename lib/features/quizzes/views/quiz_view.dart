import 'dart:async';
import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniapp/features/quizzes/data/speech_to_text_service.dart';
import 'package:uniapp/core/widgets/app_button.dart';
import 'package:uniapp/features/completed/completed_view.dart';
import 'package:uniapp/features/quizzes/data/local_data.dart';
import 'package:uniapp/features/quizzes/data/quizzes_service.dart';
import 'package:uniapp/features/quizzes/views/widgets/ai_feedback.dart';
import 'package:uniapp/features/quizzes/views/widgets/micro_status.dart';
import 'package:uniapp/features/quizzes/views/widgets/quiz_app_bar.dart';
import 'package:uniapp/features/quizzes/views/widgets/quiz_error.dart';
import 'package:uniapp/features/quizzes/views/widgets/quiz_exit_dialog.dart';
import 'package:uniapp/features/quizzes/views/widgets/quiz_loading.dart';
import 'package:uniapp/features/quizzes/views/widgets/quiz_progress_bar.dart';
import 'package:uniapp/features/quizzes/views/widgets/quiz_question_card.dart';
import 'package:uniapp/features/quizzes/views/widgets/record_button.dart';
import 'package:uniapp/global_services.dart/quiz_analytics_service.dart';

class QuizView extends StatefulWidget {
  const QuizView({super.key, required this.quizTitle});
  final String quizTitle;

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  final PageController _pageController = PageController();
  final QuizService _quizService = QuizService.instance;
  List<String> questions = [];
  int currentPage = 0;
  bool isAnswering = false;
  bool isLoading = true;
  String? errorMessage;
  late final SpeechToTextService _speechService;
  StreamSubscription<DeepgramListenResult>? _speechSub;
  String currentTranscript = '';
  Timer? _recordingTimer;
  String? answerFeedback;
  bool? lastAnswerStatus;
  double get progress =>
      questions.isEmpty ? 0 : (currentPage + 1) / questions.length;
  DateTime? _quizStartTime;
  Duration? _quizCompletionTime;

  @override
  void initState() {
    super.initState();
    _speechService = SpeechToTextService(
      deepgram: Deepgram(const String.fromEnvironment('DEEPGRAM_API_KEY')),
    );
    _loadQuestions();
    _quizStartTime = DateTime.now();
  }

  void _stopQuizTimer() {
    _quizCompletionTime = DateTime.now().difference(_quizStartTime!);
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final selectedQuestions = await _quizService.getSelectedQuestions(
        quizTitle: widget.quizTitle,
      );
      if (selectedQuestions.isEmpty) {
        throw Exception('No questions available');
      }

      await LocalData.instance.setAttempt(quizTitle: widget.quizTitle);
      setState(() {
        questions = selectedQuestions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load questions: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _handleVoiceAnswer() async {
    if (isAnswering) {
      await _stopRecording();
      return;
    }

    setState(() {
      isAnswering = true;
      currentTranscript = '';
      answerFeedback = null;
      lastAnswerStatus = null;
    });

    try {
      final stream = await _speechService.startListening();
      if (stream == null) throw Exception('Could not start listening');

      _speechSub?.cancel();
      _speechSub = stream.listen(
        (result) {
          if (result.transcript?.isNotEmpty == true) {
            setState(() {
              currentTranscript += '${result.transcript!} ';
            });
          }
        },
        onError: (error) {
          setState(() {
            isAnswering = false;
            errorMessage = 'Speech error: $error';
          });
          _speechSub?.cancel();
        },
        onDone: () {
          _evaluateAnswer(currentTranscript);
          _speechSub?.cancel();
        },
      );
    } catch (e) {
      setState(() {
        isAnswering = false;
        errorMessage = 'Error starting speech recognition: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    if (!isAnswering) return;

    await _speechService.stopListening();
    await _speechSub?.cancel();
    await _evaluateAnswer(currentTranscript);
  }

  Future<void> _evaluateAnswer(String transcript) async {
    if (!isAnswering) return;

    try {
      setState(() => isAnswering = false);

      if (transcript.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No speech detected. Please try again.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final currentQuestion = questions[currentPage];
      final response = await _quizService.evaluateUserAnswer(
        currentQuestion,
        transcript,
      );
      if (!mounted) return;

      if (response.isNotEmpty) {
        setState(() {
          answerFeedback = response['feedback'] ?? 'No feedback available.';
          lastAnswerStatus = response['status'] == true;
        });
        final prefs = await SharedPreferences.getInstance();
        final scorePerQuestion = 100 / questions.length;
        final earnedScore = lastAnswerStatus == true ? scorePerQuestion : 0;
        if (lastAnswerStatus == false) {
          bool q1Error = currentPage == 0;
          bool q2Error = currentPage == 1;
          bool q3Error = currentPage == 2;

          await saveErrors(q1Error, q2Error, q3Error);
        }
        await prefs.setDouble(
          '${widget.quizTitle}_$currentPage',
          earnedScore.toDouble(),
        );
        if (!mounted) return;
      }
      _showFeedbackBottomSheet();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error evaluating answer: $e')));
    }
  }

  void _goToNextQuestion() async {
    if (currentPage < questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {
        currentPage++;
        answerFeedback = null;
        lastAnswerStatus = null;
      });
    } else {
      _stopQuizTimer();

      final result = await getTotalScore(quizTitle: widget.quizTitle.trim());

      await QuizAnalyticsService.instance.getQuizAnalytics();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(
            builder:
                (context) => QuizCompletedView(
                  quizTitle: widget.quizTitle,
                  score: result,
                  time: _quizCompletionTime,
                ),
          ),
          (routes) => false,
        );
      }
    }
  }

  void _showFeedbackBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FeedbackContainer(
                  isCorrect: lastAnswerStatus,
                  feedback: answerFeedback ?? 'No feedback available.',
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 200,
                    child: AppButton(
                      ontap: () {
                        Navigator.pop(context);
                        _goToNextQuestion();
                      },
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _speechSub?.cancel();
    _speechService.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return QuizLoading(primaryRed: primaryRed);
    }

    if (errorMessage != null) {
      return quizError(
        errorMessage: errorMessage,
        primaryRed: primaryRed,
        onTap: _loadQuestions,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            QuizAppBar(
              currentPage: currentPage,
              totalQuestions: questions.length,
              onExitPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ExitQuizDialog(),
                );
              },
            ),
            QuizProgressBar(progress: progress),
            const SizedBox(height: 24),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: PageView.builder(
                controller: _pageController,
                itemCount: questions.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: SingleChildScrollView(
                      key: ValueKey(questions[index]),
                      child: Column(
                        children: [
                          QuizQuestionCard(
                            question: questions[index],
                            isAnswering: isAnswering,
                          ),
                          if (answerFeedback == null)
                            MicroStatus(
                              isAnswering: isAnswering,
                              currentTranscript: currentTranscript,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
            QuizButton(
              answerFeedback: answerFeedback,
              isAnswering: isAnswering,
              onPressed: () {
                _handleVoiceAnswer();
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
