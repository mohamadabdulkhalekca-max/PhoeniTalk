import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class SpeechToTextService {
  final Deepgram deepgram;
  final AudioRecorder audioRecorder = AudioRecorder();
  Stream<DeepgramListenResult>? _sttStream;
  Stream<List<int>>? _micStream;

  SpeechToTextService({required this.deepgram});

  Future<bool> _checkPermissions() async {
    final micStatus = await Permission.microphone.request();
    return micStatus.isGranted;
  }

  Future<Stream<DeepgramListenResult>?> startListening() async {
    try {
      if (!await _checkPermissions()) {
        throw Exception('Microphone permission denied');
      }

      _micStream = await audioRecorder.startStream(
        RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );

      _sttStream = deepgram.listen.live(
        _micStream!,
        queryParams: {
          'detect_language': false,
          'language': 'en',
          'encoding': 'linear16',
          'sample_rate': 16000,
          'model': 'nova-2',
          'smart_format': true,
          'punctuate': true,
          'interim_results': false,
          'endpointing': 300,
        },
      );

      return _sttStream;
    } catch (e) {
      stopListening();
      rethrow;
    }
  }

  Future<void> stopListening() async {
    try {
      await audioRecorder.stop();
      await _sttStream?.drain();
      _sttStream = null;
      _micStream = null;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> dispose() async {
    await stopListening();
    await audioRecorder.dispose();
  }
}
