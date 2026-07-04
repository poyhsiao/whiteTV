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

    // Sprint 4.1 — 補覆蓋率
    test('getQrCodeUrl 啟動前回空字串', () {
      expect(service.getQrCodeUrl(), equals(''));
    });

    test('stopServer 未啟動時是 no-op', () async {
      await service.stopServer();
      expect(service.isRunning, isFalse);
    });

    test('inputStream 訂閱後開始 emit currentInput', () async {
      final first = await service.inputStream.first;
      // 起始 currentInput = '' → distinct 仍 emit 第一筆 ''
      expect(first, equals(''));
    });

    test('onInputComplete 可被 setOnInputComplete 替換', () {
      service.setOnInputComplete((text) {});
      final first = service.onInputComplete;
      service.setOnInputComplete((text) {});
      final second = service.onInputComplete;
      expect(identical(first, second), isFalse);
    });
  });
}
