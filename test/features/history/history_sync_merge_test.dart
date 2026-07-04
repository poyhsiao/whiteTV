// TDD 紅階段: HistoryService.syncFromRemote 合併邏輯
// 規範: docs/spec/UI_UX.md §6 + ROADMAP §2.1
// 真實缺口: syncFromRemote() 直接覆蓋本地記錄,
//           違反「本地較新進度應覆寫遠端」規範

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:white_tv/features/history/models/media_type.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/services/history_local_service.dart';
import 'package:white_tv/features/history/services/history_remote_service.dart';
import 'package:white_tv/features/history/services/history_service.dart';

class _MockLocal extends Mock implements HistoryLocalService {}

class _MockRemote extends Mock implements HistoryRemoteService {}

class _FakeRegister extends Fake implements PlayHistory {}

PlayHistory _hist(
  String key, {
  required int playTime,
  required DateTime lastWatched,
  int totalTime = 7200,
}) => PlayHistory(
  key: key,
  videoId: key,
  title: 'title-$key',
  sourceName: 'src',
  playTime: playTime,
  totalTime: totalTime,
  saveTime: lastWatched,
  lastWatched: lastWatched,
  type: 'movie',
  mediaType: MediaType.movie,
);

PlayHistory _histOnlySaveTime(
  String key, {
  required int playTime,
  required DateTime saveTime,
  int totalTime = 7200,
}) => PlayHistory(
  key: key,
  videoId: key,
  title: 'title-$key',
  sourceName: 'src',
  playTime: playTime,
  totalTime: totalTime,
  saveTime: saveTime,
  lastWatched: null,
  type: 'movie',
  mediaType: MediaType.movie,
);

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeRegister());
  });

  group('HistoryService.syncFromRemote 合併策略', () {
    late _MockLocal local;
    late _MockRemote remote;
    late HistoryService service;

    setUp(() {
      local = _MockLocal();
      remote = _MockRemote();
      service = HistoryService(local, remote);
      when(() => local.save(any())).thenAnswer((_) async {});
    });

    test('本地進度較新 → 保留本地,不寫入', () async {
      // Given: 本地 v1 進度 300s (剛看)
      final localRecord = _hist(
        'v1',
        playTime: 300,
        lastWatched: DateTime(2026, 7, 1, 12, 0),
      );
      // 遠端 v1 進度 100s (較舊)
      final remoteRecord = _hist(
        'v1',
        playTime: 100,
        lastWatched: DateTime(2026, 7, 1, 10, 0),
      );

      when(() => local.getAll()).thenAnswer((_) async => [localRecord]);
      when(
        () => remote.fetchFromRemote(),
      ).thenAnswer((_) async => [remoteRecord]);

      // When
      await service.syncFromRemote();

      // Then: 本地較新 → 不應呼叫 save (保留本地)
      verifyNever(() => local.save(any()));
    });

    test('遠端進度較新 → 用遠端覆蓋本地', () async {
      final localRecord = _hist(
        'v1',
        playTime: 100,
        lastWatched: DateTime(2026, 7, 1, 10, 0),
      );
      final remoteRecord = _hist(
        'v1',
        playTime: 300,
        lastWatched: DateTime(2026, 7, 1, 12, 0),
      );

      when(() => local.getAll()).thenAnswer((_) async => [localRecord]);
      when(
        () => remote.fetchFromRemote(),
      ).thenAnswer((_) async => [remoteRecord]);

      await service.syncFromRemote();

      final captured =
          verify(() => local.save(captureAny())).captured.single as PlayHistory;
      expect(captured.playTime, equals(300), reason: '遠端較新進度 (300s) 應覆蓋本地');
    });

    test('本地無記錄 → 直接寫入遠端', () async {
      final remoteRecord = _hist(
        'v2',
        playTime: 500,
        lastWatched: DateTime(2026, 7, 1, 12, 0),
      );

      when(() => local.getAll()).thenAnswer((_) async => []);
      when(
        () => remote.fetchFromRemote(),
      ).thenAnswer((_) async => [remoteRecord]);

      await service.syncFromRemote();

      final captured =
          verify(() => local.save(captureAny())).captured.single as PlayHistory;
      expect(captured.videoId, equals('v2'));
    });

    test('遠端 lastWatched 為空 → 用 saveTime 比較', () async {
      final localRecord = _histOnlySaveTime(
        'v3',
        playTime: 100,
        saveTime: DateTime(2026, 7, 1, 10, 0),
      );
      final remoteRecord = _histOnlySaveTime(
        'v3',
        playTime: 300,
        saveTime: DateTime(2026, 7, 1, 12, 0),
      );

      when(() => local.getAll()).thenAnswer((_) async => [localRecord]);
      when(
        () => remote.fetchFromRemote(),
      ).thenAnswer((_) async => [remoteRecord]);

      await service.syncFromRemote();

      final captured =
          verify(() => local.save(captureAny())).captured.single as PlayHistory;
      expect(captured.playTime, equals(300));
    });
  });
}
