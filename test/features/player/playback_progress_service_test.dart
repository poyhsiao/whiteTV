import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/services/history_service.dart';
import 'package:white_tv/features/player/services/playback_progress_service.dart';

class FakeHistoryForProgress implements HistoryService {
  final Map<String, PlayHistory> _records = {};

  @override
  Future<List<PlayHistory>> getHistory() async => _records.values.toList();
  @override
  Future<void> addRecord(PlayHistory record) async { _records[record.key] = record; }
  @override
  Future<void> deleteRecord(String key) async { _records.remove(key); }
  @override
  List<PlayHistory> getPendingRecords() => [];
  @override
  bool get hasPendingRecords => false;
  @override
  int get pendingRecordCount => 0;
  @override
  Future<void> syncPendingRecords() async {}
  @override
  Future<void> syncFromRemote() async {}
  @override
  Future<bool> pushRecordToRemote(PlayHistory record) async => true;
}

void main() {
  group('PlaybackProgressService', () {
    late FakeHistoryForProgress fakeHistory;
    late PlaybackProgressService service;

    setUp(() {
      fakeHistory = FakeHistoryForProgress();
      service = PlaybackProgressService(fakeHistory);
    });

    test('saveProgress creates record with correct fields', () async {
      await service.saveProgress(
        'video-1', 'source-quantum', 3,
        const Duration(minutes: 15), const Duration(minutes: 45),
      );

      final records = await fakeHistory.getHistory();
      expect(records, hasLength(1));
      expect(records.first.videoId, 'video-1');
      expect(records.first.playTime, 900);
      expect(records.first.totalTime, 2700);
    });

    test('loadProgress returns existing record', () async {
      await service.saveProgress(
        'video-1', 'source-1', 3,
        const Duration(minutes: 10), const Duration(minutes: 30),
      );

      final result = service.loadProgress('video-1', 3);
      expect(result, isNotNull);
      expect(result!.playTime, 600);
    });

    test('loadProgress returns null when no record exists', () {
      final result = service.loadProgress('nonexistent', 1);
      expect(result, isNull);
    });

    test('deleteProgress removes the record', () async {
      await service.saveProgress(
        'video-1', 'source-1', 3,
        const Duration(minutes: 10), const Duration(minutes: 30),
      );

      await service.deleteProgress('video-1', 3);
      final result = service.loadProgress('video-1', 3);
      expect(result, isNull);
    });
  });
}
