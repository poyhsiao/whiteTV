import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/services/history_local_service.dart';
import 'package:white_tv/features/player/services/download_service.dart';

class MockDio extends Mock implements Dio {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class FakeResponse extends Fake implements Response<Object> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DownloadService downloadService;
  late MockDio mockDio;
  late HistoryLocalService localService;

  setUpAll(() {
    registerFallbackValue(FakeResponse());

    // Mock path_provider channel
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return Directory.systemTemp.createTempSync('download_service_test_').path;
      }
      return null;
    });
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    localService = await HistoryLocalService.create();
    mockDio = MockDio();
    downloadService = DownloadService(mockDio, localService);
  });

  group('DownloadService', () {
    group('download', () {
      test('returns file path on successful download', () async {
        when(() => mockDio.download(
              any(),
              any(),
              onReceiveProgress: any(named: 'onReceiveProgress'),
            )).thenAnswer((_) async => Response<Object>(
              requestOptions: RequestOptions(path: ''),
              statusCode: 200,
            ));

        final result = await downloadService.download(
          videoId: 'video1',
          url: 'https://example.com/video1.mp4',
        );

        expect(result, isNotNull);
        expect(result, endsWith('video1.mp4'));
      });

      test('throws DioException when download fails', () async {
        // Non-retryable error: service skips retry loop and throws lastError
        when(() => mockDio.download(
              any(),
              any(),
              onReceiveProgress: any(named: 'onReceiveProgress'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.cancel,
        ));

        expect(
          () => downloadService.download(
            videoId: 'video1',
            url: 'https://example.com/video1.mp4',
          ),
          throwsA(isA<DioException>()),
        );
      });

      test('retries on connectionTimeout and succeeds on second attempt', () async {
        var attempt = 0;
        when(() => mockDio.download(
              any(),
              any(),
              onReceiveProgress: any(named: 'onReceiveProgress'),
            )).thenAnswer((_) async {
          attempt++;
          if (attempt == 1) {
            throw DioException(
              requestOptions: RequestOptions(path: ''),
              type: DioExceptionType.connectionTimeout,
            );
          }
          return Response<Object>(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          );
        });

        final result = await downloadService.download(
          videoId: 'video1',
          url: 'https://example.com/video1.mp4',
        );

        expect(result, isNotNull);
        expect(result, endsWith('video1.mp4'));
        expect(attempt, equals(2));
      });
    });

    group('isDownloaded', () {
      test('returns false when no history records exist', () async {
        final result = await downloadService.isDownloaded('video1');
        expect(result, isFalse);
      });

      test('returns false when video is not downloaded', () async {
        final history = PlayHistory(
          key: 'key1',
          videoId: 'video1',
          title: 'Test Video',
          sourceName: 'TestSource',
          playTime: 100,
          totalTime: 200,
          saveTime: DateTime.now(),
          type: 'movie',
          isDownloaded: false,
        );
        await localService.save(history);

        final result = await downloadService.isDownloaded('video1');
        expect(result, isFalse);
      });

      test('returns true when video is marked as downloaded', () async {
        final history = PlayHistory(
          key: 'key1',
          videoId: 'video1',
          title: 'Test Video',
          sourceName: 'TestSource',
          playTime: 100,
          totalTime: 200,
          saveTime: DateTime.now(),
          type: 'movie',
          isDownloaded: true,
          localPath: '/path/to/video1.mp4',
        );
        await localService.save(history);

        final result = await downloadService.isDownloaded('video1');
        expect(result, isTrue);
      });
    });

    group('getLocalPath', () {
      test('returns null when video is not downloaded', () async {
        final history = PlayHistory(
          key: 'key1',
          videoId: 'video1',
          title: 'Test Video',
          sourceName: 'TestSource',
          playTime: 100,
          totalTime: 200,
          saveTime: DateTime.now(),
          type: 'movie',
          isDownloaded: false,
        );
        await localService.save(history);

        final result = await downloadService.getLocalPath('video1');
        expect(result, isNull);
      });

      test('returns local path when video is downloaded', () async {
        const localPath = '/path/to/video1.mp4';
        final history = PlayHistory(
          key: 'key1',
          videoId: 'video1',
          title: 'Test Video',
          sourceName: 'TestSource',
          playTime: 100,
          totalTime: 200,
          saveTime: DateTime.now(),
          type: 'movie',
          isDownloaded: true,
          localPath: localPath,
        );
        await localService.save(history);

        final result = await downloadService.getLocalPath('video1');
        expect(result, equals(localPath));
      });
    });

    group('deleteDownload', () {
      test('returns false when video is not downloaded', () async {
        final result = await downloadService.deleteDownload('video1');
        expect(result, isFalse);
      });

      test('returns true and removes local path when file deleted', () async {
        final tempDir = Directory.systemTemp.createTempSync('delete_test_');
        final fakeFile = File('${tempDir.path}/video1.mp4');
        await fakeFile.writeAsString('fake content');

        final history = PlayHistory(
          key: 'key1',
          videoId: 'video1',
          title: 'Test Video',
          sourceName: 'TestSource',
          playTime: 100,
          totalTime: 200,
          saveTime: DateTime.now(),
          type: 'movie',
          isDownloaded: true,
          localPath: fakeFile.path,
        );
        await localService.save(history);

        final result = await downloadService.deleteDownload('video1');
        expect(result, isTrue);
        expect(await fakeFile.exists(), isFalse);

        // Verify record was updated
        final isDownloaded = await downloadService.isDownloaded('video1');
        expect(isDownloaded, isFalse);

        // Cleanup
        await tempDir.delete(recursive: true);
      });
    });
  });
}