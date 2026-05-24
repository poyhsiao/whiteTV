import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/features/search/services/search_history_service.dart';
import 'package:white_tv/core/api/mock_client.dart';

class MockApiClient extends Mock implements MockClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SearchHistoryService', () {
    late SearchHistoryService service;
    late MockApiClient mockClient;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      mockClient = MockApiClient();
      service = SearchHistoryService(prefs, mockClient);
    });

    group('getHistory', () {
      test('returns empty list when no history exists', () async {
        final history = await service.getHistory();
        expect(history, isEmpty);
      });

      test('returns copy of internal list to prevent mutation', () async {
        await service.saveSearch('query1');
        final history1 = await service.getHistory();
        history1.add('mutated');

        final history2 = await service.getHistory();
        expect(history2, isNot(contains('mutated')));
      });
    });

    group('saveSearch', () {
      test('saves query to history', () async {
        await service.saveSearch('flutter');

        final history = await service.getHistory();
        expect(history, equals(['flutter']));
      });

      test('adds newest query to front', () async {
        await service.saveSearch('first');
        await service.saveSearch('second');

        final history = await service.getHistory();
        expect(history, equals(['second', 'first']));
      });

      test('removes duplicate before moving to front', () async {
        await service.saveSearch('query');
        await service.saveSearch('other');
        await service.saveSearch('query');

        final history = await service.getHistory();
        expect(history, equals(['query', 'other']));
      });

      test('limits history to max items', () async {
        for (var i = 0; i < 25; i++) {
          await service.saveSearch('query$i');
        }

        final history = await service.getHistory();
        expect(history.length, equals(20));
        expect(history.first, equals('query24'));
      });

      test('ignores empty query', () async {
        await service.saveSearch('');

        final history = await service.getHistory();
        expect(history, isEmpty);
      });

      test('ignores whitespace-only query', () async {
        await service.saveSearch('   ');

        final history = await service.getHistory();
        expect(history, isEmpty);
      });

      test('saves valid query after empty query is ignored', () async {
        await service.saveSearch('');
        await service.saveSearch('valid');

        final history = await service.getHistory();
        expect(history, equals(['valid']));
      });
    });

    group('clearHistory', () {
      test('clears all history', () async {
        await service.saveSearch('query1');
        await service.saveSearch('query2');
        await service.clearHistory();

        final history = await service.getHistory();
        expect(history, isEmpty);
      });
    });

    group('Cloud Sync', () {
      test('syncToCloud calls LunaTV API', () async {
        when(() => mockClient.syncSearchHistory(any()))
            .thenAnswer((_) async {});

        await service.saveSearch('test');
        await service.syncToCloud();

        verify(() => mockClient.syncSearchHistory(['test'])).called(1);
      });

      test('syncToCloud does nothing when history is empty', () async {
        await service.syncToCloud();

        verifyNever(() => mockClient.syncSearchHistory(any()));
      });

      test('syncToCloud silently fails on error', () async {
        when(() => mockClient.syncSearchHistory(any()))
            .thenThrow(Exception('Network error'));

        // Should not throw
        await service.saveSearch('test');
        await expectLater(() => service.syncToCloud(), returnsNormally);
      });

      test('fetchFromCloud returns cloud history', () async {
        when(() => mockClient.getSearchHistory())
            .thenAnswer((_) async => ['cloud1', 'cloud2']);

        final history = await service.fetchFromCloud();

        expect(history, equals(['cloud1', 'cloud2']));
      });

      test('fetchFromCloud returns empty on error', () async {
        when(() => mockClient.getSearchHistory())
            .thenThrow(Exception('Network error'));

        final history = await service.fetchFromCloud();

        expect(history, isEmpty);
      });
    });
  });
}