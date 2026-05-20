import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/features/search/search_state.dart';
import 'package:white_tv/features/search/search_store.dart';

void main() {
  group('SearchStore', () {
    late MockClient mockClient;
    late SearchStore store;

    setUp(() {
      mockClient = MockClient();
      store = SearchStore(mockClient);
    });

    test('initial state is empty', () {
      expect(store.state.query, '');
      expect(store.state.results, isEmpty);
      expect(store.state.isLoading, false);
    });

    test('search updates query and results', () async {
      await store.search('星際');
      expect(store.state.query, '星際');
      expect(store.state.results, isNotEmpty);
    });

    test('search sets loading state', () async {
      final future = store.search('test');
      expect(store.state.isLoading, true);
      await future;
      expect(store.state.isLoading, false);
    });

    test('setCategory updates active category', () {
      store.setCategory(SearchCategory.movie);
      expect(store.state.activeCategory, SearchCategory.movie);
    });

    test('toggleKeyboardMode switches mode', () {
      expect(store.state.isKeyboardMode, false);
      store.toggleKeyboardMode();
      expect(store.state.isKeyboardMode, true);
    });

    test('clearSearch resets query and results', () async {
      await store.search('test');
      store.clearSearch();
      expect(store.state.query, '');
      expect(store.state.results, isEmpty);
    });
  });
}