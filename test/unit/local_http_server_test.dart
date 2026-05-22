import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/services/local_http_server.dart';

void main() {
  group('LocalHttpServer', () {
    late LocalHttpServer server;

    setUp(() {
      server = LocalHttpServer();
    });

    tearDown(() async {
      await server.stop();
    });

    test('starts on specified port', () async {
      await server.start(port: 8080, ipAddress: '127.0.0.1');
      expect(server.isRunning, isTrue);
      expect(server.port, equals(8080));
    });

    test('stopped server is not running', () async {
      await server.start(port: 8080, ipAddress: '127.0.0.1');
      await server.stop();
      expect(server.isRunning, isFalse);
    });

    test('server has correct base URL', () async {
      await server.start(port: 8080, ipAddress: '127.0.0.1');
      expect(server.baseUrl, equals('http://127.0.0.1:8080'));
    });

    test('handles input POST request', () async {
      await server.start(port: 8080, ipAddress: '127.0.0.1');
      server.setInputHandler((String text) {});
      expect(server.inputHandler, isNotNull);
    });
  });
}