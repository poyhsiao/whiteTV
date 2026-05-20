import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/features/search/services/search_history_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SearchHistoryService', () {
    late SearchHistoryService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      service = SearchHistoryService(prefs);
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
  });
}