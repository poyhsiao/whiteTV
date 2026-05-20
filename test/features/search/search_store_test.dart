import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/features/search/search_state.dart';
import 'package:white_tv/features/search/search_store.dart';

class MockApiClient extends Mock implements MockClient {}

void main() {
  group('SearchStore', () {
    late MockApiClient mockClient;
    late SearchStore store;

    setUp(() {
      mockClient = MockApiClient();
      store = SearchStore(mockClient);
    });

    test('initial state is empty', () {
      expect(store.state.query, '');
      expect(store.state.results, isEmpty);
      expect(store.state.isLoading, false);
    });

    test('search updates query and results', () async {
      when(() => mockClient.search(any(), category: any(named: 'category')))
          .thenAnswer((_) async => []);
      await store.search('test');
      expect(store.state.query, 'test');
      verify(() => mockClient.search('test', category: SearchCategory.all)).called(1);
    });

    test('search sets loading state', () async {
      when(() => mockClient.search(any(), category: any(named: 'category')))
          .thenAnswer((_) async => []);
      final future = store.search('test');
      expect(store.state.isLoading, true);
      await future;
      expect(store.state.isLoading, false);
    });

    test('search sets error on failure', () async {
      when(() => mockClient.search(any(), category: any(named: 'category')))
          .thenThrow(Exception('API error'));
      await store.search('test');
      expect(store.state.error, isNotNull);
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
      when(() => mockClient.search(any(), category: any(named: 'category')))
          .thenAnswer((_) async => []);
      await store.search('test');
      store.clearSearch();
      expect(store.state.query, '');
      expect(store.state.results, isEmpty);
    });
  });
}