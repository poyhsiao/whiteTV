import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/core/source/source_selector.dart';
import 'package:white_tv/features/detail/detail_store.dart';
import 'package:white_tv/features/history/history_state.dart';
import 'package:white_tv/features/history/history_store.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/models/media_type.dart';

// FakeRef using noSuchMethod forwarding to avoid implementing all Ref methods
class FakeRef extends Ref {
  HistoryState? historyStateOverride;

  @override
  T read<T>(ProviderListenable<T> provider) {
    // Compare provider identity using identical
    if (identical(provider, historyStoreProvider)) {
      return historyStateOverride as T;
    }
    throw UnimplementedError('FakeRef does not support provider: $provider');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('DetailStore', () {
    late MockClient mockClient;
    late SourceSelector sourceSelector;
    late ProviderContainer container;
    late DetailStore store;

    setUp(() {
      mockClient = MockClient();
      sourceSelector = SourceSelector();
      container = ProviderContainer();
      store = DetailStore(mockClient, sourceSelector, null);
    });

    tearDown(() => container.dispose());

    test('initial state has no detail', () {
      expect(store.state.detail, isNull);
      expect(store.state.isLoading, false);
    });

    test('loadDetail populates detail and selects fastest source', () async {
      await store.loadDetail('movie-1');
      expect(store.state.detail, isNotNull);
      expect(store.state.detail!.id, 'movie-1');
      expect(store.state.selectedSource, isNotNull);
      expect(store.state.isLoading, false);
    });

    test('loadDetail selects first episode', () async {
      await store.loadDetail('movie-1');
      expect(store.state.selectedEpisode, isNotNull);
      expect(store.state.selectedEpisode!.number, 1);
    });

    test('selectSource updates selected source', () async {
      await store.loadDetail('movie-1');
      final newSource = store.state.detail!.sources[1];
      store.selectSource(newSource);
      expect(store.state.selectedSource, newSource);
    });

    test('selectEpisode updates selectedEpisode in state', () async {
      await store.loadDetail('movie-1');
      final episode5 = store.state.detail!.episodes[4];
      store.selectEpisode(episode5);
      expect(store.state.selectedEpisode, episode5);
      expect(store.state.selectedEpisode!.number, 5);
    });

    test('selectEpisode with null clears selectedEpisode', () async {
      await store.loadDetail('movie-1');
      expect(store.state.selectedEpisode, isNotNull);
      store.selectEpisode(null);
      expect(store.state.selectedEpisode, isNull);
    });

    test('initial state has correct default values', () {
      final freshStore = DetailStore(mockClient, sourceSelector, null);
      expect(freshStore.state.detail, isNull);
      expect(freshStore.state.selectedSource, isNull);
      expect(freshStore.state.selectedEpisode, isNull);
      expect(freshStore.state.isLoading, false);
      expect(freshStore.state.error, isNull);
    });

    test('copyWith preserves unchanged fields', () async {
      await store.loadDetail('movie-1');
      final originalDetail = store.state.detail;
      final originalEpisode = store.state.selectedEpisode;
      final originalLoading = store.state.isLoading;
      final newSource = store.state.detail!.sources[1];
      expect(originalLoading, false);
      store.selectSource(newSource);
      expect(store.state.detail, originalDetail);
      expect(store.state.selectedEpisode, originalEpisode);
      expect(store.state.isLoading, false);
      expect(store.state.selectedSource, newSource);
    });

    test('selectSource preserves other state fields', () async {
      await store.loadDetail('movie-1');
      final newSource = store.state.detail!.sources[2];
      store.selectSource(newSource);
      expect(store.state.detail, isNotNull);
      expect(store.state.selectedEpisode, isNotNull);
      expect(store.state.isLoading, false);
      expect(store.state.error, isNull);
    });

    group('recordSourceResult', () {
      test('recordSourceResult with success calls sourceSelector.recordResult correctly', () async {
        await store.loadDetail('movie-1');
        final selectedSource = store.state.selectedSource!;

        store.recordSourceResult(isSuccess: true, latency: 50);

        final metrics = sourceSelector.getMetrics(selectedSource.id);
        expect(metrics, isNotNull);
        expect(metrics!.successCount, 1);
        expect(metrics.failCount, 0);
        expect(metrics.avgLatency, 50);
      });

      test('recordSourceResult with failure calls sourceSelector with isSuccess=false', () async {
        await store.loadDetail('movie-1');
        final selectedSource = store.state.selectedSource!;

        store.recordSourceResult(isSuccess: false, latency: 200);

        final metrics = sourceSelector.getMetrics(selectedSource.id);
        expect(metrics, isNotNull);
        expect(metrics!.successCount, 0);
        expect(metrics.failCount, 1);
      });

      test('recordSourceResult when no source selected does not crash', () {
        final freshStore = DetailStore(mockClient, sourceSelector, null);
        expect(freshStore.state.selectedSource, isNull);
        expect(() => freshStore.recordSourceResult(isSuccess: true, latency: 100), returnsNormally);
      });
    });

    group('getProgressForMedia', () {
      test('getProgressForMedia returns null when ref is null', () {
        final freshStore = DetailStore(mockClient, sourceSelector, null);
        final result = freshStore.getProgressForMedia('movie-1');
        expect(result, isNull);
      });

      test('getProgressForMedia returns progress when available', () {
        final fakeRef = FakeRef();
        final existingRecord = PlayHistory(
          key: 'key-1',
          videoId: 'movie-1',
          title: 'Movie 1',
          sourceName: 'Source A',
          playTime: 300,
          totalTime: 600,
          saveTime: DateTime.now(),
          type: 'movie',
          mediaType: MediaType.movie,
        );
        final historyState = HistoryState(records: [existingRecord]);
        fakeRef.historyStateOverride = historyState;

        final storeWithRef = DetailStore(mockClient, sourceSelector, fakeRef);
        final result = storeWithRef.getProgressForMedia('movie-1');

        expect(result, isNotNull);
        expect(result!.videoId, 'movie-1');
        expect(result.playTime, 300);
        expect(result.totalTime, 600);
      });

      test('getProgressForMedia returns null when media not in history', () {
        final fakeRef = FakeRef();
        final existingRecord = PlayHistory(
          key: 'key-1',
          videoId: 'movie-1',
          title: 'Movie 1',
          sourceName: 'Source A',
          playTime: 300,
          totalTime: 600,
          saveTime: DateTime.now(),
          type: 'movie',
          mediaType: MediaType.movie,
        );
        final historyState = HistoryState(records: [existingRecord]);
        fakeRef.historyStateOverride = historyState;

        final storeWithRef = DetailStore(mockClient, sourceSelector, fakeRef);
        final result = storeWithRef.getProgressForMedia('nonexistent-media');

        expect(result, isNull);
      });
    });
  });
}
