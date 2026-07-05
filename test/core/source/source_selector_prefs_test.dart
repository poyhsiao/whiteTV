// Sprint 8.3 — SourceSelector prefs injection
// Verifies SourceSelector accepts prefsReader / prefsWriter lambdas so tests
// can avoid touching real SharedPreferences and main.dart / providers can
// pass the existing sharedPreferencesProvider's value.

import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/core/source/source_selector.dart';

class _InMemoryPrefs {
  final Map<String, List<String>> store = {};
}

void main() {
  group('SourceSelector prefs injection', () {
    test('default ctor still calls SharedPreferences (backward compatible)',
        () async {
      // Just verify the ctor doesn't throw when no injection is provided;
      // actual SharedPreferences behavior is exercised by integration tests.
      final selector = SourceSelector();
      expect(selector, isA<SourceSelector>());
    });

    test('setBlockedSources uses injected prefsWriter', () async {
      final prefs = _InMemoryPrefs();
      final selector = SourceSelector(
        prefsReader: () async => prefs.store['blocked_sources'] ?? const [],
        prefsWriter: (ids) async => prefs.store['blocked_sources'] = ids,
      );

      await selector.setBlockedSources(['a', 'b', 'c']);
      expect(prefs.store['blocked_sources'], ['a', 'b', 'c']);
      expect(selector.getBlockedSources(), ['a', 'b', 'c']);
    });

    test('selectSource uses injected prefsReader to refresh blocked list',
        () async {
      final prefs = _InMemoryPrefs();
      prefs.store['blocked_sources'] = ['blocked-id'];

      final selector = SourceSelector(
        prefsReader: () async => prefs.store['blocked_sources'] ?? const [],
        prefsWriter: (ids) async => prefs.store['blocked_sources'] = ids,
      );

      // Don't explicitly call setBlockedSources; let selectSource refresh from prefs
      final sources = [
        const VideoSource(id: 'blocked-id', name: 'B', url: 'http://b'),
        const VideoSource(id: 'ok-id', name: 'A', url: 'http://a'),
      ];

      final picked = await selector.selectSource(sources, 'vid-1');
      // selectSource internally calls _refreshBlockedSources, which reads from prefs
      // blocked-id is filtered out, so we must get ok-id (or fallback).
      expect(picked.id, 'ok-id');
    });

    test('prefsReader returning empty list yields no-blocked state', () async {
      final prefs = _InMemoryPrefs();
      final selector = SourceSelector(
        prefsReader: () async => prefs.store['blocked_sources'] ?? const [],
        prefsWriter: (ids) async => prefs.store['blocked_sources'] = ids,
      );

      final sources = [
        const VideoSource(
          id: 'a',
          name: 'A',
          url: 'http://a',
          isAvailable: true,
        ),
      ];

      final picked = await selector.selectSource(sources, 'vid-2');
      expect(picked.id, 'a');
    });
  });
}