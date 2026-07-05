// Sprint 5.2 — TVVoiceInputService DI 重構
// TDD 紅階段: 驗證 SpeechController 應為可注入 interface
// 規範: Sprint 4 限制:SpeechToText 硬編碼,純 mock 不可替換

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/search/services/voice_input_service.dart';

class _MockSpeechController implements SpeechController {
  bool initializeCalled = false;
  bool listenCalled = false;
  bool stopCalled = false;
  bool initializeReturns = true;
  SpeechResultCallback? listenCallback;

  @override
  Future<bool> initialize() async {
    initializeCalled = true;
    return initializeReturns;
  }

  @override
  void listen({required SpeechResultCallback onResult}) {
    listenCalled = true;
    listenCallback = onResult;
  }

  @override
  Future<void> stop() async {
    stopCalled = true;
  }

  void emitWords(String words) {
    listenCallback?.call(words);
  }
}

void main() {
  group('VoiceInputService (Sprint 5.2)', () {
    late _MockSpeechController mockSpeech;
    late TVVoiceInputService service;
    late List<String> capturedResults;

    setUp(() {
      mockSpeech = _MockSpeechController();
      capturedResults = [];
      // TDD 紅: fromSpeech 注入建構子尚未存在 → 編譯錯誤
      service = TVVoiceInputService.fromSpeech(mockSpeech);
      service.onResult.listen(capturedResults.add);
    });

    tearDown(() {
      service.stopListening();
    });

    test('initial state is not listening', () {
      expect(service.isListening, isFalse);
    });

    test('startListening 呼叫 initialize 然後 listen', () async {
      await service.startListening();

      expect(mockSpeech.initializeCalled, isTrue);
      expect(mockSpeech.listenCalled, isTrue);
      expect(service.isListening, isTrue);
    });

    test('重複 startListening 為 no-op', () async {
      await service.startListening();
      mockSpeech.listenCalled = false;
      await service.startListening();

      expect(mockSpeech.listenCalled, isFalse);
    });

    test('onResult 接收 speech emit 的 words', () async {
      await service.startListening();
      mockSpeech.emitWords('星際');
      await Future<void>.delayed(Duration.zero);

      expect(capturedResults, contains('星際'));
    });

    test('initialize 失敗時不進入 listening', () async {
      mockSpeech.initializeReturns = false;
      await service.startListening();

      expect(service.isListening, isFalse);
      expect(mockSpeech.listenCalled, isFalse);
    });

    test('stopListening 呼叫 speech.stop 並清空狀態', () async {
      await service.startListening();
      await service.stopListening();

      expect(mockSpeech.stopCalled, isTrue);
      expect(service.isListening, isFalse);
    });

    test('預設 factory voiceInputServiceFactory() 仍可用', () {
      expect(voiceInputServiceFactory(), isA<VoiceInputService>());
    });
  });
}
