import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/services/input_service.dart';

void main() {
  group('InputService', () {
    late InputService service;

    setUp(() {
      service = InputService();
    });

    tearDown(() async {
      if (service.isRunning) {
        await service.stopServer();
      }
    });

    test('is not running initially', () {
      expect(service.isRunning, isFalse);
    });

    test('currentInput is empty initially', () {
      expect(service.currentInput, equals(''));
    });

    test('setOnInputComplete registers callback', () {
      service.setOnInputComplete((text) {
        // callback registered
      });
      expect(service.onInputComplete, isNotNull);
    });

    test('clearInput resets currentInput', () async {
      service.clearInput();
      expect(service.currentInput, equals(''));
    });
  });
}