
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/core/source/source_selector.dart';
import 'package:white_tv/features/detail/detail_screen.dart';
import 'package:white_tv/features/detail/detail_store.dart';
import 'package:white_tv/features/downloads/downloads_store.dart';
import 'package:white_tv/features/history/models/media_type.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/services/history_local_service.dart';
import 'package:white_tv/features/player/services/download_service.dart';

class _FakeDownloadSvc implements DownloadService {
  @override Future<String?> download({required String videoId, required String url, void Function(int received, int total)? onProgress,
    int maxRetries = 3,
  }) async => '/fake/path/$videoId.mp4';
  @override Future<bool> deleteDownload(String videoId) async => true;
  @override Future<String?> getLocalPath(String videoId) async => null;
  @override Future<bool> isDownloaded(String videoId) async => false;
}

class _FakeHistorySvc implements HistoryLocalService {
  @override Future<void> clear() async {}
  @override Future<void> delete(String key) async {}
  @override Future<List<PlayHistory>> getAll() async => [];
  @override Future<void> save(PlayHistory history) async {}
}

class FakeDownloadsStore extends DownloadsStore {
  String? lastVideoId;
  String? lastUrl;
  FakeDownloadsStore() : super(_FakeDownloadSvc(), _FakeHistorySvc());
  @override
  Future<void> startDownload({required String videoId, required String url, required String title, String? posterUrl, String? sourceName, MediaType mediaType = MediaType.movie, int? episodeIndex}) async {
    lastVideoId = videoId;
    lastUrl = url;
  }
  @override Future<void> loadDownloads() async {}
  @override Future<void> deleteDownload(String videoId) async {}
  @override void updateProgress(String videoId, double progress) {}
}

void main() {
  testWidgets('detail screen shows download button', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final container = ProviderContainer(
      overrides: [
        detailStoreProvider.overrideWith((ref) {
          final store = DetailStore(MockClient(), SourceSelector(), null);
          store.loadDetail('movie-1');
          return store;
        }),
        downloadsStoreProvider.overrideWith((ref) => FakeDownloadsStore()),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: DetailScreen(videoId: 'movie-1')),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(seconds: 1));

    // Download button visible in mobile layout (1920x1080 renders desktop → mobile layout)
    expect(find.byKey(const Key('download_button_mobile')), findsOneWidget);
    expect(find.byKey(const Key('play_button')), findsOneWidget);
  });

  testWidgets('tap download calls startDownload', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final fakeStore = FakeDownloadsStore();
    final container = ProviderContainer(
      overrides: [
        detailStoreProvider.overrideWith((ref) {
          final store = DetailStore(MockClient(), SourceSelector(), null);
          store.loadDetail('movie-1');
          return store;
        }),
        downloadsStoreProvider.overrideWith((ref) => fakeStore),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: DetailScreen(videoId: 'movie-1')),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(seconds: 1));

    // Tap download button
    final btn = find.byKey(const Key('download_button_mobile'));
    await tester.ensureVisible(btn);
    await tester.pump();
    await tester.tap(btn);
    await tester.pump();

    expect(fakeStore.lastVideoId, 'movie-1');
    expect(fakeStore.lastUrl, contains('/stream/movie-1/'));
  });
}
