import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/downloads/downloads_store.dart';
import 'package:white_tv/features/downloads/downloads_state.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/models/media_type.dart';
import 'package:white_tv/features/history/services/history_local_service.dart';
import 'package:white_tv/features/player/services/download_service.dart';

class _FakeDownloadServiceOk implements DownloadService {
  @override
  Future<bool> deleteDownload(String videoId) async => true;

  @override
  Future<String?> download({
    required String videoId,
    required String url,
    void Function(int received, int total)? onProgress,
    int maxRetries = 3,
  }) async {
    onProgress?.call(50, 100);
    await Future.delayed(const Duration(milliseconds: 10));
    return '/fake/path/$videoId.mp4';
  }

  @override
  Future<String?> getLocalPath(String videoId) async => null;

  @override
  Future<bool> isDownloaded(String videoId) async => false;
}

class _FakeDownloadServiceFail implements DownloadService {
  @override
  Future<bool> deleteDownload(String videoId) async => true;

  @override
  Future<String?> download({
    required String videoId,
    required String url,
    void Function(int received, int total)? onProgress,
    int maxRetries = 3,
  }) async => null; // 模擬下載失敗

  @override
  Future<String?> getLocalPath(String videoId) async => null;

  @override
  Future<bool> isDownloaded(String videoId) async => false;
}

class _FakeDownloadServiceNetworkError implements DownloadService {
  @override
  Future<bool> deleteDownload(String videoId) async => true;

  @override
  Future<String?> download({
    required String videoId,
    required String url,
    void Function(int received, int total)? onProgress,
    int maxRetries = 3,
  }) async {
    throw DioException(
      type: DioExceptionType.connectionError,
      requestOptions: RequestOptions(path: url),
    );
  }

  @override
  Future<String?> getLocalPath(String videoId) async => null;

  @override
  Future<bool> isDownloaded(String videoId) async => false;
}

class _FakeHistoryServiceEmpty implements HistoryLocalService {
  final List<PlayHistory> _records = [];

  @override
  Future<void> clear() async {}

  @override
  Future<void> delete(String key) async {}

  @override
  Future<List<PlayHistory>> getAll() async => _records;

  @override
  Future<void> save(PlayHistory history) async => _records.add(history);
}

void main() {
  group('DownloadsStore.startDownload', () {
    test('startDownload sets activeDownloadIds and progress', () async {
      final store = DownloadsStore(_FakeDownloadServiceOk(), _FakeHistoryServiceEmpty());

      expect(store.state.activeDownloadIds.isEmpty, true);

      await store.startDownload(
        videoId: 'video_星際穿越',
        url: 'https://example.com/星際穿越.mp4',
        title: '星際穿越',
        sourceName: '量子資源',
      );

      expect(store.state.activeDownloadIds.isEmpty, true);
    });

    test('startDownload with network error sets error message', () async {
      final store = DownloadsStore(_FakeDownloadServiceNetworkError(), _FakeHistoryServiceEmpty());

      await store.startDownload(
        videoId: 'video_測試',
        url: 'https://example.com/test.mp4',
        title: '測試影片',
        sourceName: '量子資源',
      );

      expect(store.state.error, '網路連線中斷');
    });

    test('startDownload with null result sets generic error', () async {
      final store = DownloadsStore(_FakeDownloadServiceFail(), _FakeHistoryServiceEmpty());

      await store.startDownload(
        videoId: 'video_測試',
        url: 'https://example.com/test.mp4',
        title: '測試影片',
        sourceName: '量子資源',
      );

      expect(store.state.error, '下載失敗');
    });

    test('duplicate startDownload is ignored', () async {
      final store = DownloadsStore(_FakeDownloadServiceOk(), _FakeHistoryServiceEmpty());

      await Future.wait([
        store.startDownload(videoId: 'video_測試', url: 'https://example.com/test.mp4', title: '測試'),
        store.startDownload(videoId: 'video_測試', url: 'https://example.com/test.mp4', title: '測試'),
      ]);

      expect(store.state.error, isNull);
    });
  });
}
