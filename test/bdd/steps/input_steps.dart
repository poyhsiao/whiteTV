import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/services/input_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Unified Input System BDD', () {
    late InputService inputService;

    setUp(() {
      inputService = InputService();
    });

    tearDown(() async {
      if (inputService.isRunning) {
        await inputService.stopServer();
      }
    });

    test('InputService state management', () async {
      // Verify service state management
      expect(inputService.isRunning, isFalse);
      expect(inputService.currentInput, equals(''));
    });

    test('InputService clears input', () async {
      inputService.clearInput();
      expect(inputService.currentInput, equals(''));
    });
  });
}
