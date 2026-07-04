// Sprint 5.2 — DI 重構:加入 SpeechController interface + fromSpeech factory
//
// 抽象 SpeechToText 行為為 SpeechController,讓 service 可注入 fake/mock
// 用於測試。原 _speech 欄位改成 SpeechController 介面

import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart';

typedef SpeechResultCallback = void Function(String words);

abstract class VoiceInputService {
  bool get isListening;
  Stream<String> get onResult;
  Future<void> startListening();
  Future<void> stopListening();
}

/// 抽象 speech_to_text 行為用於測試注入。
abstract class SpeechController {
  Future<bool> initialize();
  void listen({required SpeechResultCallback onResult});
  Future<void> stop();
  Stream<String> get results;
}

/// 真實平台 speech_to_text 適配。
class _PlatformSpeechController implements SpeechController {
  final SpeechToText _speech = SpeechToText();

  @override
  Future<bool> initialize() async => _speech.initialize();

  @override
  void listen({required SpeechResultCallback onResult}) {
    _speech.listen(onResult: (result) => onResult(result.recognizedWords));
  }

  @override
  Future<void> stop() async => _speech.stop();

  @override
  Stream<String> get results => const Stream.empty();
}

class TVVoiceInputService implements VoiceInputService {
  TVVoiceInputService([SpeechController? speech])
    : _speech = speech ?? _PlatformSpeechController();

  /// 注入既有 SpeechController (用於測試)。
  TVVoiceInputService.fromSpeech(this._speech);

  final SpeechController _speech;
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
      _speech.listen(
        onResult: (words) {
          _resultController.add(words);
        },
      );
    }
  }

  @override
  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
  }
}

VoiceInputService voiceInputServiceFactory() => TVVoiceInputService();
