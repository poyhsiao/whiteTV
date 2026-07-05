// Sprint 8.1 — Shared SpyInputService for InputScreen / LoginScreen tests.
// In-memory InputService that records method calls without binding a real
// HttpServer, so widget tests stay synchronous and free of network I/O.

import 'package:white_tv/core/services/input_service.dart';

class SpyInputService extends InputService {
  @override
  Future<bool> startServer({int port = 8080}) async => true;

  @override
  Future<void> stopServer() async {}

  @override
  String? get currentIp => '127.0.0.1';

  @override
  int? get currentPort => 8080;

  @override
  bool get isRunning => true;

  @override
  String getQrCodeUrl() => 'http://127.0.0.1:8080/qr';

  @override
  void setOnInputComplete(void Function(String) onComplete) {
    // no-op: widget tests don't drive the input callback.
  }
}