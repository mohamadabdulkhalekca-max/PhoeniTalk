import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  final List<Map<String, String>> _conversationHistory = [];

  Future<List<String>> selectQuizQuestions(
    List<dynamic> allQuestions,
    int count,
  ) async {
    if (_conversationHistory.isNotEmpty) {
      _conversationHistory.clear();
    }
    final prompt = '''
    From the following quiz questions, select  $count questions 
    . 
    choose them super random ones.
    Return only the question texts in a JSON array:
   dont add the \'\'\' json thing just stright to the point as an api
   always choose diffrent questions. other than you selected as well. 
    All Questions: ${jsonEncode(allQuestions)},

    ''';

    try {
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final text =
            responseData['candidates'][0]['content']['parts'][0]['text'];
        _conversationHistory.add({'role': 'assistant', 'content': text});

        return List<String>.from(jsonDecode(text));
      }
      return [];
    } catch (e) {
      debugPrint('Gemini API error: $e');
      return [];
    }
  }

  Future<Map> evaluateAnswer(String question, String answer) async {
    final prompt = '''
Evaluate whether the answer is correct for the following question.

Question: $question
Answer: $answer

Respond only with a JSON map containing:
- "status": true or false
- "feedback": a brief explanation (2 sentences max), and like your talking to the person directly., 
dont tell him to allaborate again, just a feedback.
Do not include any code fences, extra formatting, or explanations. Return only the JSON object.
and also dont be strict. even if he replyed with 1 word check if its relevent or nah.
dont add the \'\'\' json thing just stright to the point as an api.

AI Rater Instructions – Speaking Response Evaluation
You are grading a student's oral response to an unexpected question. Your feedback must be rich, constructive, and targeted to delivery and content.
Evaluate the response based on the following:
Voice & Delivery
•	Tone – Is the voice expressive and well-suited to the message?
•	Pitch – Is the speaker employing good pitch variation so that he or she is not sounding monotonous?
•	Intonation – Are sentence forms (questions, statements, etc.) naturally conveyed?
•	Pace – Is speech too fast, too slow, or just right?
•	Pronunciation – Are words clearly articulated and correct?
•	Stance/Confidence – Does the speaker speak confidently and with ease?
Content & Structure
•	Hook – Does the speaker begin with a hooked introduction?
•	Support – Are supportive ideas, examples, or explanations clear?
•	Relevance – Is the solution on-topic and with what was asked?
• Vocabulary – Is there range and accurate use of expressive vocabulary?
• Cohesion – Are ideas connected with cohesive devices (e.g., transitions, linking words)?
Feedback Tips
• Mention strengths as well as suggestions for improvement.
• Encouraging but informative: e.g., "Your pronunciation was clear, but try to slow down slightly to improve pacing."
• Be precise. Say what worked and what might be improved in particular.
• Spice up your vocabulary
• Try using a helpful, friendly tone.


''';
    _conversationHistory.add({'role': 'user', 'content': prompt});

    try {
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final innerJson = jsonDecode(
          responseData['candidates'][0]['content']['parts'][0]['text'],
        );
        _conversationHistory.add({
          'role': 'assistant',
          'content': innerJson['feedback'],
        });

        final status = innerJson['status'];
        final feedback = innerJson['feedback'];

        debugPrint(status.toString());
        debugPrint(feedback.toString());
        return {'status': status, 'feedback': feedback};
      }
      return {};
    } catch (e) {
      debugPrint('Gemini error: $e');
      return {};
    }
  }

  void clearHistory() {
    _conversationHistory.clear();
  }
}
