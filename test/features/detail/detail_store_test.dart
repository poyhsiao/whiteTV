import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/core/source/source_selector.dart';
import 'package:white_tv/features/detail/detail_store.dart';

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
      // Pass null for ref since getProgressForMedia is not tested here
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

    // TDD RED Phase - selectEpisode tests
    test('selectEpisode updates selectedEpisode in state', () async {
      await store.loadDetail('movie-1');

      // Select episode 5
      final episode5 = store.state.detail!.episodes[4]; // episodes are 0-indexed, so index 4 = episode 5
      store.selectEpisode(episode5);

      expect(store.state.selectedEpisode, episode5);
      expect(store.state.selectedEpisode!.number, 5);
    });

    test('selectEpisode with null clears selectedEpisode', () async {
      await store.loadDetail('movie-1');
      expect(store.state.selectedEpisode, isNotNull); // Should have first episode selected

      // Clear selectedEpisode by passing null
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

      // Capture current state
      final originalDetail = store.state.detail;
      final originalSource = store.state.selectedSource;
      final originalEpisode = store.state.selectedEpisode;
      final originalLoading = store.state.isLoading;

      // Only update selectedSource via copyWith
      final newSource = store.state.detail!.sources[1];
      store.selectSource(newSource);

      // Verify detail, episode, and loading state are preserved
      expect(store.state.detail, originalDetail);
      expect(store.state.selectedEpisode, originalEpisode);
      expect(store.state.isLoading, false); // loadDetail completed

      // Verify selectedSource is updated
      expect(store.state.selectedSource, newSource);
    });

    test('selectSource preserves other state fields', () async {
      await store.loadDetail('movie-1');

      final newSource = store.state.detail!.sources[2];
      store.selectSource(newSource);

      // Verify other fields unchanged
      expect(store.state.detail, isNotNull);
      expect(store.state.selectedEpisode, isNotNull);
      expect(store.state.isLoading, false);
      expect(store.state.error, isNull);
    });
  });
}