import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/features/downloads/downloads_store.dart';
import 'package:white_tv/features/downloads/downloads_state.dart';
import 'package:white_tv/features/downloads/presentation/screens/downloads_screen.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/models/media_type.dart';
import 'package:white_tv/features/history/services/history_local_service.dart';
import 'package:white_tv/features/player/services/download_service.dart';

class FakeDownloadService implements DownloadService {
  final List<String> deletedVideoIds = [];

  @override
  Future<bool> deleteDownload(String videoId) async {
    deletedVideoIds.add(videoId);
    return true;
  }

  @override
  Future<String?> download({
    required String videoId,
    required String url,
    void Function(int received, int total)? onProgress,
  }) async =>
      null;

  @override
  Future<String?> getLocalPath(String videoId) async => null;

  @override
  Future<bool> isDownloaded(String videoId) async => false;
}

class FakeHistoryLocalService implements HistoryLocalService {
  final List<PlayHistory> records;

  FakeHistoryLocalService(this.records);

  @override
  Future<List<PlayHistory>> getAll() async => records;

  @override
  Future<void> save(PlayHistory history) async {}

  @override
  Future<void> delete(String key) async {}

  @override
  Future<void> clear() async {}
}

class FakeDownloadsStore extends DownloadsStore {
  FakeDownloadsStore(List<PlayHistory> downloads)
      : super(FakeDownloadService(), FakeHistoryLocalService(downloads)) {
    state = DownloadsState(downloads: downloads, isLoading: false);
  }
}

class _FakeDownloadsStoreLoading extends DownloadsStore {
  _FakeDownloadsStoreLoading()
      : super(FakeDownloadService(), FakeHistoryLocalService([])) {
    state = const DownloadsState(isLoading: true);
  }
}

class _FakeDownloadsStoreEmpty extends DownloadsStore {
  _FakeDownloadsStoreEmpty()
      : super(FakeDownloadService(), FakeHistoryLocalService([])) {
    state = const DownloadsState(downloads: [], isLoading: false);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testDownloads = [
    PlayHistory(
      key: 'key1',
      videoId: 'video1',
      title: 'Test Video 1',
      posterUrl: 'https://example.com/poster1.jpg',
      sourceName: 'Source A',
      saveTime: DateTime.now(),
      type: 'movie',
      mediaType: MediaType.movie,
      isDownloaded: true,
      localPath: '/path/to/video1.mp4',
      playTime: 0,
      totalTime: 7200,
      lastPosition: Duration.zero,
      watchedTime: 0,
    ),
  ];

  group('DownloadsScreen', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() => container.dispose());

    testWidgets('displays loading indicator when isLoading is true',
        (tester) async {
      container = ProviderContainer(
        overrides: [
          downloadsStoreProvider.overrideWith((ref) => _FakeDownloadsStoreLoading()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: DownloadsScreen()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays empty state when no downloads', (tester) async {
      container = ProviderContainer(
        overrides: [
          downloadsStoreProvider.overrideWith((ref) => _FakeDownloadsStoreEmpty()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: DownloadsScreen()),
        ),
      );

      expect(find.text('沒有已下載的影片'), findsOneWidget);
    });

    testWidgets('displays download list when downloads exist',
        (tester) async {
      container = ProviderContainer(
        overrides: [
          downloadsStoreProvider.overrideWith((ref) => FakeDownloadsStore(testDownloads)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: DownloadsScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Test Video 1'), findsWidgets);
    });
  });
}
