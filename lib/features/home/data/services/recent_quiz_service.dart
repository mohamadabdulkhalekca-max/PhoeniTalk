import 'package:supabase_flutter/supabase_flutter.dart';

class RecentQuizService {
  RecentQuizService._();
  static RecentQuizService recentQuiz = RecentQuizService._();

  Future<Map<String, dynamic>> getRecentQuiz() async {
    final response =
        await Supabase.instance.client
            .from('recent_quiz')
            .select()
            .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
            .order('created_at', ascending: false)
            .limit(1)
            .single();

    return response;
  }
}
