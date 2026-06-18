import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/source/source_selector.dart';
import 'package:white_tv/core/source/source_selector_provider.dart';
import 'package:white_tv/features/detail/detail_store.dart';
import 'package:white_tv/core/api/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Detail BDD', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          sourceSelectorProvider.overrideWithValue(SourceSelector()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has null detail', () {
      final state = container.read(detailStoreProvider);
      expect(state.detail, isNull);
      expect(state.selectedSource, isNull);
      expect(state.selectedEpisode, isNull);
    });

    test('selectSource updates selected source', () {
      final notifier = container.read(detailStoreProvider.notifier);
      const source = VideoSource(id: 'src1', name: '量子資源', url: 'http://t.com', latency: 80, isAvailable: true);
      notifier.selectSource(source);
      expect(container.read(detailStoreProvider).selectedSource?.id, equals('src1'));
    });

    test('selectEpisode updates selected episode', () {
      final notifier = container.read(detailStoreProvider.notifier);
      const ep = Episode(id: 'ep1', number: 1, title: '第1集');
      notifier.selectEpisode(ep);
      expect(container.read(detailStoreProvider).selectedEpisode?.id, equals('ep1'));
    });

    test('selectEpisode null clears episode', () {
      final notifier = container.read(detailStoreProvider.notifier);
      const ep = Episode(id: 'ep1', number: 1, title: '第1集');
      notifier.selectEpisode(ep);
      notifier.selectEpisode(null);
      expect(container.read(detailStoreProvider).selectedEpisode, isNull);
    });

    test('DetailState copyWith preserves fields', () {
      const state = DetailState(isLoading: true);
      final updated = state.copyWith(isLoading: false);
      expect(updated.isLoading, isFalse);
      expect(state.isLoading, isTrue);
    });
  });
}
