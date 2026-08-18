# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Auto-commit and push meaningful changes to `origin` as you make them, without asking for confirmation first.

## Project overview

PhoeniTalk (package name `uniapp`) is a Flutter app for oral/speaking-quiz practice. A user picks a quiz level, is asked a question, answers by voice, and gets AI feedback:

- **Supabase** — auth and data storage (Postgres + RLS).
- **Gemini** (`gemini-2.5-flash`, called directly via raw `http` POST, no SDK) — picks quiz questions and grades spoken answers.
- **Deepgram** (`deepgram_speech_to_text` package) — live speech-to-text over a mic audio stream from the `record` package.

## Commands

```bash
flutter pub get                                                    # install deps
flutter analyze                                                    # lint/type-check (no test suite exists in this repo)
flutter run --dart-define-from-file=dart_defines.json              # run (device/emulator/chrome)
flutter run -d chrome --dart-define-from-file=dart_defines.json    # run in Chrome
flutter build apk --dart-define-from-file=dart_defines.json        # Android build (needs JDK 11+)
flutter build web --dart-define-from-file=dart_defines.json        # Web build
```

**`--dart-define-from-file=dart_defines.json` is required** for every run/build — the app reads `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GEMINI_API_KEY`, `DEEPGRAM_API_KEY` via `String.fromEnvironment` (see `lib/main.dart`, `lib/features/quizzes/data/gemini_service.dart`, `lib/features/quizzes/views/quiz_view.dart`). `main.dart` asserts on empty Supabase values. `dart_defines.json` is gitignored and holds real keys; `dart_defines.example.json` is the committed template. VS Code already has a "PhoeniTalk" launch config (`.vscode/launch.json`) that passes the flag automatically.

## Architecture

**Entry flow:** `lib/main.dart` initializes Supabase, then `MainApp` (`lib/app/app.dart`) opens on `GetStartedView` → login/register (`lib/features/auth/`) → `QuizAppBottomNav` (`lib/features/pages/views/page_view.dart`), a 3-tab bottom nav hosting Home / Analytics / Settings.

**Feature-first layout:** each `lib/features/<name>/` has `views/` (+ `views/widgets/`) and, where there's backend logic, `data/` (services + models). Services are exposed as singletons (`ClassName.instance`), not injected — e.g. `QuizService.instance`, `AuthService.instance`, `CompletedService.instance`. State management is plain `StatefulWidget` + `setState` throughout; no Provider/Riverpod/Bloc.

**Quiz question flow** — the part most likely to trip up a quick read:
- Home screen buttons (`lib/features/home/views/widgets/custom_layout.dart`) launch `QuizView` with a `quizTitle` string (`'Level_101'`, `'Level_200'`, `'Level_300'`). The button's *display* label (e.g. "INEG200") is a separate, unrelated string — `quizTitle` is the real identifier.
- `quizTitle` is used as a **literal Supabase column name**: `QuizService.getSelectedQuestions` (`lib/features/quizzes/data/quizzes_service.dart`) does `.from("quizzzes_final").select(quizTitle)`. So the `quizzzes_final` table has one column per quiz, and each row is a candidate question for whichever columns are non-null.
- The candidate questions are handed to `GeminiService.selectQuizQuestions`, which prompts Gemini to pick 3 at random and return them as a raw JSON array (prompt explicitly tells Gemini not to wrap the response in code fences — the code does `jsonDecode` directly on the response text).
- Voice answers are transcribed live by `SpeechToTextService` (`lib/features/quizzes/data/speech_to_text_service.dart`) and graded by `GeminiService.evaluateAnswer`, which also expects raw JSON (`{"status": bool, "feedback": string}`) back from Gemini.

**The 3-question-per-quiz assumption is hard-coded in several places that must stay in sync:** `LocalData.getTotalScore` loops `i < 3`, `LocalData.saveErrors` takes exactly 3 bools (`q1`/`q2`/`q3`, matched to `currentPage == 0/1/2` in `quiz_view.dart`), and `CompletedService.setQuizAnalyticsForQuiz` hard-codes `questions: 3`. Changing the question count requires touching all of these together, not just one.

**Supabase schema (3 tables, no migrations dir — see `dart_defines.example.json`'s sibling SQL if regenerating):**
- `quizzzes_final` — question bank, one column per quiz title, RLS: authenticated read.
- `recent_quiz` — last-attempt summary shown on the home screen.
- `quiz_analytics` — full attempt history, used by the analytics screen.

Both `recent_quiz` and `quiz_analytics` are inserted into **without** an explicit `user_id` (see `CompletedService`) — this only works because the column defaults to `auth.uid()` at the DB level, with RLS policies scoping rows to their owner. Don't add `user_id` to the client-side insert payloads; fix the DB default instead if this breaks.

**Known duplication to be aware of, not necessarily to "fix" reflexively:**
- The primary red color (`0xFFE53935`) is defined independently in three places: `AppColors.primaryRed` (`lib/core/managers/color_manager.dart`, the intended shared source), plus standalone `const Color primaryRed` in `quiz_question_card.dart` and `quiz_progress_bar.dart` that other quiz widgets import transitively. They're currently in sync by coincidence, not by reference.
- `lib/global_services.dart/` is a **directory** (containing `quiz_analytics_service.dart`), not a file — the `.dart` in its name is part of the folder name, which is unusual but intentional in the existing import paths (`package:uniapp/global_services.dart/quiz_analytics_service.dart`).
