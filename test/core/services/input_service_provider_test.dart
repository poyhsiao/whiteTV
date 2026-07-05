// Sprint 8.1 — InputServiceProvider
// Verifies lib/core/services/input_service_provider.dart exists and lets tests
// inject a fake InputService into LoginScreen / InputScreen.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/services/input_service.dart';
import 'package:white_tv/core/services/input_service_provider.dart';

/// Spy InputService that records method calls without spinning up HttpServer.
/// Extends the concrete InputService so providers don't need an interface split.
class SpyInputService extends InputService {
  int startCount = 0;
  int stopCount = 0;
  String? lastCompleteText;

  @override
  Future<bool> startServer({int port = 8080}) async {
    startCount++;
    return true;
  }

  @override
  Future<void> stopServer() async {
    stopCount++;
  }

  @override
  void setOnInputComplete(void Function(String) onComplete) {
    super.setOnInputComplete((text) {
      lastCompleteText = text;
    });
  }
}

void main() {
  test('inputServiceProvider is overridable via ProviderScope', () {
    final spy = SpyInputService();
    final container = ProviderContainer(
      overrides: [inputServiceProvider.overrideWithValue(spy)],
    );
    addTearDown(container.dispose);

    expect(container.read(inputServiceProvider), same(spy));
  });

  test('default inputServiceProvider returns a real InputService', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final service = container.read(inputServiceProvider);
    expect(service, isA<InputService>());
  });
}