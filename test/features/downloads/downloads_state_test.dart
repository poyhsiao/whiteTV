import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/downloads/downloads_state.dart';
import 'package:white_tv/features/history/models/play_history.dart';

PlayHistory _ph(String id, {DateTime? lastWatched}) {
  return PlayHistory(
    key: id,
    videoId: id,
    title: 'Title $id',
    sourceName: 'test',
    playTime: 0,
    totalTime: 0,
    saveTime: lastWatched ?? DateTime(2025, 1, 1),
    type: 'movie',
    lastWatched: lastWatched,
  );
}

void main() {
  group('DownloadsState defaults', () {
    test('exposes empty collections by default', () {
      const state = DownloadsState();

      expect(state.downloads, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.downloadProgress, isEmpty);
      expect(state.activeDownloadIds, isEmpty);
    });

    test('isDownloading returns false for unknown ids', () {
      const state = DownloadsState();
      expect(state.isDownloading('anything'), isFalse);
    });
  });

  group('DownloadsState.copyWith', () {
    test('replaces downloads list when supplied', () {
      const original = DownloadsState();
      final updated = original.copyWith(downloads: [_ph('a')]);

      expect(updated.downloads.length, 1);
      expect(updated.downloads.first.key, 'a');
      expect(updated.isLoading, isFalse);
    });

    test('toggles isLoading independently', () {
      const original = DownloadsState();
      final loading = original.copyWith(isLoading: true);

      expect(loading.isLoading, isTrue);
      expect(loading.downloads, isEmpty);
    });

    test('updates error message', () {
      const original = DownloadsState();
      final failure = original.copyWith(error: 'network down');

      expect(failure.error, 'network down');
    });

    test('clears error when clearError is true', () {
      const original = DownloadsState(error: 'boom');
      final cleared = original.copyWith(clearError: true);

      expect(cleared.error, isNull);
    });

    test('preserves previous error when copyWith called without params', () {
      const original = DownloadsState(error: 'still bad');
      final updated = original.copyWith(isLoading: true);

      expect(updated.error, 'still bad');
      expect(updated.isLoading, isTrue);
    });

    test('updates progress map and active ids', () {
      const original = DownloadsState();
      final updated = original.copyWith(
        downloadProgress: {'a': 0.5},
        activeDownloadIds: {'a'},
      );

      expect(updated.downloadProgress['a'], 0.5);
      expect(updated.activeDownloadIds.contains('a'), isTrue);
      expect(updated.isDownloading('a'), isTrue);
    });
  });
}
