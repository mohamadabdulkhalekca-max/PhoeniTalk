import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uniapp/core/widgets/app_snack_bar.dart';
import 'package:uniapp/features/pages/views/page_view.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _auth = Supabase.instance.client.auth;

  Future signUpUser({
    required String email,
    required String password,
    required String displayName,
    required BuildContext context,
  }) async {
    try {
      await _auth.signUp(
        email: email,
        password: password,
        data: {'displayName': displayName},
      );

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (context) => QuizAppBottomNav()),
          (routes) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        snackBar(text: e.toString(), context: context);
      }
      return null;
    }
  }

  Future signInUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.signInWithPassword(email: email, password: password);

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (context) => QuizAppBottomNav()),
          (routes) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        snackBar(text: e.toString(), context: context);
      }
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }
}
