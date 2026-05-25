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
  });
}