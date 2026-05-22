import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/services/history_local_service.dart';

void main() {
  late HistoryLocalService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    service = await HistoryLocalService.create();
  });

  group('HistoryLocalService', () {
    test('getAll returns empty list when no records', () async {
      final result = await service.getAll();
      expect(result, isEmpty);
    });

    test('save adds record to storage', () async {
      final history = PlayHistory(
        key: 'key1',
        videoId: 'video1',
        title: 'Test Video',
        sourceName: 'TestSource',
        playTime: 100,
        totalTime: 200,
        saveTime: DateTime(2026, 5, 21, 10, 0),
        type: 'movie',
      );

      await service.save(history);
      final result = await service.getAll();

      expect(result.length, 1);
      expect(result.first.key, 'key1');
      expect(result.first.title, 'Test Video');
    });

    test('save updates existing record with same key', () async {
      final history1 = PlayHistory(
        key: 'key1',
        videoId: 'video1',
        title: 'Original Title',
        sourceName: 'TestSource',
        playTime: 100,
        totalTime: 200,
        saveTime: DateTime(2026, 5, 21, 10, 0),
        type: 'movie',
      );

      final history2 = PlayHistory(
        key: 'key1',
        videoId: 'video1',
        title: 'Updated Title',
        sourceName: 'TestSource',
        playTime: 150,
        totalTime: 200,
        saveTime: DateTime(2026, 5, 21, 11, 0),
        type: 'movie',
      );

      await service.save(history1);
      await service.save(history2);
      final result = await service.getAll();

      expect(result.length, 1);
      expect(result.first.title, 'Updated Title');
      expect(result.first.playTime, 150);
    });

    test('delete removes record from storage', () async {
      final history = PlayHistory(
        key: 'key1',
        videoId: 'video1',
        title: 'Test Video',
        sourceName: 'TestSource',
        playTime: 100,
        totalTime: 200,
        saveTime: DateTime(2026, 5, 21, 10, 0),
        type: 'movie',
      );

      await service.save(history);
      await service.delete('key1');
      final result = await service.getAll();

      expect(result, isEmpty);
    });

    test('getAll returns records sorted by saveTime descending', () async {
      final history1 = PlayHistory(
        key: 'key1',
        videoId: 'video1',
        title: 'First Video',
        sourceName: 'TestSource',
        playTime: 100,
        totalTime: 200,
        saveTime: DateTime(2026, 5, 21, 10, 0),
        type: 'movie',
      );

      final history2 = PlayHistory(
        key: 'key2',
        videoId: 'video2',
        title: 'Second Video',
        sourceName: 'TestSource',
        playTime: 100,
        totalTime: 200,
        saveTime: DateTime(2026, 5, 21, 12, 0),
        type: 'movie',
      );

      final history3 = PlayHistory(
        key: 'key3',
        videoId: 'video3',
        title: 'Third Video',
        sourceName: 'TestSource',
        playTime: 100,
        totalTime: 200,
        saveTime: DateTime(2026, 5, 21, 11, 0),
        type: 'movie',
      );

      await service.save(history1);
      await service.save(history2);
      await service.save(history3);

      final result = await service.getAll();

      expect(result.length, 3);
      expect(result[0].key, 'key2');
      expect(result[1].key, 'key3');
      expect(result[2].key, 'key1');
    });

    test('save and getAll preserves lastPosition Duration', () async {
      final history = PlayHistory(
        key: 'key1',
        videoId: 'video1',
        title: 'Test',
        sourceName: 'source',
        playTime: 100,
        totalTime: 200,
        saveTime: DateTime.now(),
        type: 'movie',
        lastPosition: const Duration(minutes: 5, seconds: 30),
      );

      await service.save(history);
      final result = await service.getAll();

      expect(result.first.lastPosition, const Duration(minutes: 5, seconds: 30));
    });
  });
}
