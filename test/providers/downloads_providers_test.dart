import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/providers/downloads_providers.dart';

void main() {
  group('sharedPreferencesProvider', () {
    test('throws UnimplementedError when not overridden', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        () => container.read(sharedPreferencesProvider),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  group('downloadServiceProvider', () {
    test('throws when dependencies are not overridden '
        '(proves dependency chain)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(() => container.read(downloadServiceProvider), throwsA(anything));
    });
  });
}
