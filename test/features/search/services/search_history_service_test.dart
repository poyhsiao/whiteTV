import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/features/search/services/search_history_service.dart';

void main() {
  late SearchHistoryService service;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = SearchHistoryService(prefs);
  });

  group('SearchHistoryService', () {
    test('should save and retrieve search history', () async {
      await service.saveSearch('test query');
      final history = await service.getHistory();
      expect(history, contains('test query'));
    });

    test('should limit history to 20 items', () async {
      for (int i = 0; i < 25; i++) {
        await service.saveSearch('query$i');
      }
      final history = await service.getHistory();
      expect(history.length, 20);
      expect(history.first, 'query24');
    });

    test('should remove duplicate queries', () async {
      await service.saveSearch('duplicate');
      await service.saveSearch('other');
      await service.saveSearch('duplicate');
      final history = await service.getHistory();
      expect(history.where((q) => q == 'duplicate').length, 1);
    });

    test('should clear history', () async {
      await service.saveSearch('test');
      await service.clearHistory();
      final history = await service.getHistory();
      expect(history, isEmpty);
    });

    test('should return newest first', () async {
      await service.saveSearch('first');
      await service.saveSearch('second');
      await service.saveSearch('third');
      final history = await service.getHistory();
      expect(history.first, 'third');
      expect(history.last, 'first');
    });

    test('should move existing duplicate to front', () async {
      await service.saveSearch('first');
      await service.saveSearch('duplicate');
      await service.saveSearch('second');
      await service.saveSearch('duplicate');
      final history = await service.getHistory();
      expect(history.first, 'duplicate');
      expect(history.indexOf('duplicate'), 0);
    });
  });
}