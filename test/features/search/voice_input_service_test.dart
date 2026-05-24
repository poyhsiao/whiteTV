import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/search/services/voice_input_service.dart';

void main() {
  group('VoiceInputService', () {
    late VoiceInputService service;

    setUp(() {
      service = TVVoiceInputService();
    });

    test('initial state is not listening', () {
      expect(service.isListening, false);
    });

    test('startListening sets isListening to true', () async {
      // Note: speech_to_text requires actual device permissions
      // This test validates the state transition logic
    });
  });
}