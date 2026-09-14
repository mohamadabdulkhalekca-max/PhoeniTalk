# PhoeniTalk

A Flutter app for oral/speaking-quiz practice. Pick a quiz level, answer a spoken
question, and get AI feedback on your answer.

## How it works

1. Pick a quiz level from the home screen.
2. Gemini selects a set of questions from the question bank for that level.
3. You answer by voice; Deepgram transcribes your speech live.
4. Gemini grades your transcribed answer and returns pass/fail feedback.
5. Results are tracked in your quiz history and shown on the analytics screen.

## Tech stack

- **Flutter** (package name `uniapp`)
- **Supabase** — auth and data storage (Postgres + Row Level Security)
- **Gemini** (`gemini-2.5-flash`, called directly via HTTP) — question selection and answer grading
- **Deepgram** — live speech-to-text from the device microphone

## Setup

```bash
flutter pub get
```

Copy `dart_defines.example.json` to `dart_defines.json` and fill in `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GEMINI_API_KEY`, and `DEEPGRAM_API_KEY`. This file is required for every run/build:

```bash
flutter run --dart-define-from-file=dart_defines.json                # device/emulator
flutter run -d chrome --dart-define-from-file=dart_defines.json      # web (Chrome)
flutter build apk --dart-define-from-file=dart_defines.json          # Android build
flutter build web --dart-define-from-file=dart_defines.json          # Web build
```

A VS Code launch config ("PhoeniTalk") already passes the flag automatically.
