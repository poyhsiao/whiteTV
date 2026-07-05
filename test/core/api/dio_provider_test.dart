// Sprint 7.1 — Unified dioProvider
// Verifies lib/core/api/dio_provider.dart exists, is overridable, and exports
// the same instance from both canonical (core/api) and legacy
// (downloads_providers) locations.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/dio_provider.dart';
import 'package:white_tv/providers/downloads_providers.dart' as legacy;

void main() {
  test('dioProvider lives in core/api and is overridable', () {
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(Dio(BaseOptions(baseUrl: 'http://test'))),
      ],
    );
    addTearDown(container.dispose);

    final dio = container.read(dioProvider);
    expect(dio.options.baseUrl, 'http://test');
  });

  test('legacy downloads_providers re-exports the same provider instance', () {
    expect(identical(dioProvider, legacy.dioProvider), isTrue);
  });

  test('default dioProvider returns a plain Dio', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final dio = container.read(dioProvider);
    expect(dio, isA<Dio>());
  });
}