import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/features/search/search_state.dart';
import 'package:white_tv/features/search/search_store.dart';
import 'package:white_tv/features/search/services/search_history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/api/api_client.dart';

class MockApiClient extends Mock implements MockClient {}

class MockSearchHistoryService extends Mock implements SearchHistoryService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

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

    test('loadHistory populates searchHistory from local and cloud', () async {
      final mockHistoryService = MockSearchHistoryService();
      final prefs = MockSharedPreferences();

      when(() => mockHistoryService.getHistory()).thenAnswer((_) async => ['local1', 'local2']);
      when(() => mockHistoryService.fetchFromCloud()).thenAnswer((_) async => ['cloud1']);

      final storeWithHistory = SearchStore(mockClient, mockHistoryService);

      await storeWithHistory.loadHistory();

      // Merged: local priority, cloud as backup, max 20 items
      expect(storeWithHistory.state.searchHistory, containsAll(['local1', 'local2', 'cloud1']));
    });

    test('saveToHistory calls SearchHistoryService.saveSearch and reloads', () async {
      final mockHistoryService = MockSearchHistoryService();
      final prefs = MockSharedPreferences();

      when(() => mockHistoryService.getHistory()).thenAnswer((_) async => ['test1']);
      when(() => mockHistoryService.fetchFromCloud()).thenAnswer((_) async => []);
      when(() => mockHistoryService.saveSearch(any())).thenAnswer((_) async {});

      final storeWithHistory = SearchStore(mockClient, mockHistoryService);

      await storeWithHistory.saveToHistory('test1');

      verify(() => mockHistoryService.saveSearch('test1')).called(1);
    });
  });
}