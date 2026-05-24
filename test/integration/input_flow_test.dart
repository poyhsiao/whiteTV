import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/services/input_service.dart';
import 'package:white_tv/core/services/session_manager.dart';

void main() {
  group('Input Flow Integration', () {
    late InputService inputService;
    late SessionManager sessionManager;

    setUp(() {
      inputService = InputService();
      sessionManager = SessionManager();
    });

    tearDown(() async {
      if (inputService.isRunning) {
        await inputService.stopServer();
      }
    });

    test('full input flow from server start to stop', () async {
      // 1. Create session
      final session = sessionManager.createSession();
      expect(session.id, isNotEmpty);
      expect(session.isValid, isTrue);

      // 2. Start server on available port (8080 may be occupied)
      final started = await inputService.startServer(port: 0);
      expect(started, isTrue);
      expect(inputService.isRunning, isTrue);

      // 3. Get QR URL
      final qrUrl = inputService.getQrCodeUrl();
      expect(qrUrl, isNotEmpty);
      expect(qrUrl.contains('http://'), isTrue);

      // 4. Simulate input
      inputService.clearInput();
      expect(inputService.currentInput, equals(''));

      // 5. Stop server
      await inputService.stopServer();
      expect(inputService.isRunning, isFalse);
    });
  });
}