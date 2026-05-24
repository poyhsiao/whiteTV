import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart';

abstract class VoiceInputService {
  bool get isListening;
  Stream<String> get onResult;
  Future<void> startListening();
  Future<void> stopListening();
}

class TVVoiceInputService implements VoiceInputService {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  final _resultController = StreamController<String>.broadcast();

  @override
  bool get isListening => _isListening;

  @override
  Stream<String> get onResult => _resultController.stream;

  @override
  Future<void> startListening() async {
    if (_isListening) return;
    final available = await _speech.initialize();
    if (available) {
      _isListening = true;
      _speech.listen(onResult: (result) {
        _resultController.add(result.recognizedWords);
      });
    }
  }

  @override
  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
  }
}

VoiceInputService voiceInputServiceFactory() => TVVoiceInputService();