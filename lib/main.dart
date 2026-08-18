import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  assert(
    supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty,
    'Missing SUPABASE_URL/SUPABASE_ANON_KEY. Run with '
    '--dart-define-from-file=dart_defines.json',
  );

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const MainApp());
}
