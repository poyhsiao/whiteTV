// TDD 紅階段: Downloads BDD 整合驗證 — 對應 downloads.feature scenario 1
// 規範: BDD test/bdd/features/downloads.feature
// 真實缺口: startDownload 成功後,history 應有一筆 isDownloaded=true 的 record

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/downloads/downloads_store.dart';
import 'package:white_tv/features/history/models/media_type.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/services/history_local_service.dart';
import 'package:white_tv/features/player/services/download_service.dart';

class _MemHistory implements HistoryLocalService {
  final List<PlayHistory> _records = [];
  @override
  Future<List<PlayHistory>> getAll() async => List.from(_records);

  @override
  Future<void> save(PlayHistory record) async {
    _records.removeWhere((r) => r.key == record.key);
    _records.add(record);
  }

  @override
  Future<void> delete(String key) async {
    _records.removeWhere((r) => r.key == key);
  }

  @override
  Future<void> clear() async => _records.clear();

  List<PlayHistory> get all => List.unmodifiable(_records);
}

class _FakeDownloadService extends Fake implements DownloadService {
  final HistoryLocalService _local;
  final String fakePath;

  _FakeDownloadService(this._local, this.fakePath);

  @override
  Future<String?> download({
    required String videoId,
    required String url,
    void Function(int received, int total)? onProgress,
  }) async {
    onProgress?.call(100, 100);
    final records = await _local.getAll();
    final idx = records.indexWhere((r) => r.videoId == videoId);
    if (idx >= 0) {
      await _local.save(
        records[idx].copyWith(isDownloaded: true, localPath: fakePath),
      );
    } else {
      await _local.save(
        PlayHistory(
          key: videoId,
          videoId: videoId,
          title: videoId,
          sourceName: 'src',
          playTime: 0,
          totalTime: 100,
          saveTime: DateTime(2026, 1, 1),
          type: 'movie',
          mediaType: MediaType.movie,
          isDownloaded: true,
          localPath: fakePath,
        ),
      );
    }
    return fakePath;
  }

  @override
  Future<bool> deleteDownload(String videoId) async => true;

  @override
  Future<String?> getLocalPath(String videoId) async => null;

  @override
  Future<bool> isDownloaded(String videoId) async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BDD downloads.feature Scenario 1: 下載完成後出現在列表', () {
    late _MemHistory history;
    late ProviderContainer container;

    setUp(() {
      history = _MemHistory();
      final download = _FakeDownloadService(history, '/fake/downloads/v1.mp4');
      container = ProviderContainer(
        overrides: [
          downloadsStoreProvider.overrideWith(
            (ref) => DownloadsStore(download, history),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('startDownload 完成後 downloads 列表含該 video', () async {
      // Given: history 有該 video (未下載)
      await history.save(
        PlayHistory(
          key: 'v1',
          videoId: 'v1',
          title: '星際穿越',
          sourceName: 'src',
          playTime: 0,
          totalTime: 7200,
          saveTime: DateTime(2026, 1, 1),
          type: 'movie',
          mediaType: MediaType.movie,
        ),
      );

      // When: 觸發下載
      await container
          .read(downloadsStoreProvider.notifier)
          .startDownload(videoId: 'v1', url: 'http://x', title: '星際穿越');

      // Then: state.downloads 包含 v1 且路徑正確
      final state = container.read(downloadsStoreProvider);
      expect(
        state.downloads.any((d) => d.videoId == 'v1'),
        isTrue,
        reason: '下載完成後 v1 應出現在 downloads 列表',
      );
      expect(
        state.downloads.firstWhere((d) => d.videoId == 'v1').localPath,
        equals('/fake/downloads/v1.mp4'),
      );
    });
  });
}
