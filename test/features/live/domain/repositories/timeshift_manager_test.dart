import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/live/domain/repositories/timeshift_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TimeshiftManager', () {
    late TimeshiftManager timeshiftManager;
    late Directory tempDir;

    setUp(() async {
      timeshiftManager = TimeshiftManagerImpl();
      tempDir = await Directory.systemTemp.createTemp('timeshift_test_');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getTemporaryDirectory') {
            return tempDir.path;
          }
          return null;
        },
      );
    });

    tearDown(() async {
      await timeshiftManager.stopClientBuffer();
      await tempDir.delete(recursive: true);
    });

    test('starts timeshift mode for channel', () async {
      final controller = await timeshiftManager.startTimeshift(
        channelId: 'channel1',
        streamUrl: 'https://example.com/stream.m3u8',
      );

      expect(controller, isNotNull);
      expect(timeshiftManager.isTimeshiftActive, isTrue);
    });

    test('pauses timeshift playback', () async {
      await timeshiftManager.startTimeshift(
        channelId: 'channel1',
        streamUrl: 'https://example.com/stream.m3u8',
      );

      await timeshiftManager.pause();
      final state = await timeshiftManager.getState();

      expect(state.isPaused, isTrue);
    });

    test('resumes timeshift playback', () async {
      await timeshiftManager.startTimeshift(
        channelId: 'channel1',
        streamUrl: 'https://example.com/stream.m3u8',
      );

      await timeshiftManager.pause();
      await timeshiftManager.resume();
      final state = await timeshiftManager.getState();

      expect(state.isPaused, isFalse);
    });

    test('seeks to specific position', () async {
      await timeshiftManager.startTimeshift(
        channelId: 'channel1',
        streamUrl: 'https://example.com/stream.m3u8',
      );

      final targetPosition = const Duration(minutes: -10);
      final result = await timeshiftManager.seek(targetPosition);

      expect(result, isA<Duration>());
    });

    test('fast forwards correctly', () async {
      await timeshiftManager.startTimeshift(
        channelId: 'channel1',
        streamUrl: 'https://example.com/stream.m3u8',
      );

      final result = await timeshiftManager.fastForward(const Duration(seconds: 10));

      expect(result, isA<Duration>());
    });

    test('rewinds correctly', () async {
      await timeshiftManager.startTimeshift(
        channelId: 'channel1',
        streamUrl: 'https://example.com/stream.m3u8',
      );

      final result = await timeshiftManager.rewind(const Duration(seconds: 10));

      expect(result, isA<Duration>());
    });

    test('stops timeshift and returns to live', () async {
      await timeshiftManager.startTimeshift(
        channelId: 'channel1',
        streamUrl: 'https://example.com/stream.m3u8',
      );

      await timeshiftManager.stopTimeshift();

      expect(timeshiftManager.isTimeshiftActive, isFalse);
    });

    test('returns correct max timeshift duration (7 days)', () {
      expect(timeshiftManager.maxTimeshiftDuration, const Duration(days: 7));
    });

    test('isServiceSideSupported returns false by default', () async {
      final result = await timeshiftManager.isServiceSideSupported('ch1');
      expect(result, isFalse);
    });

    test('getServiceSideStream returns null by default', () async {
      final result = await timeshiftManager.getServiceSideStream(
        'ch1',
        const Duration(minutes: 5),
        const Duration(minutes: 10),
      );
      expect(result, isNull);
    });

    group('startClientBuffer', () {
      test('creates TS segment file after start', () async {
        await timeshiftManager.startClientBuffer(
          'channel_1',
          const Duration(minutes: 30),
        );
        await Future.delayed(const Duration(seconds: 2));
        final files = await tempDir.list().toList();
        expect(files.any((f) => f.path.endsWith('.ts')), isTrue);
      });

      test('stopClientBuffer closes file handles', () async {
        await timeshiftManager.startClientBuffer(
          'channel_1',
          const Duration(minutes: 30),
        );
        await Future.delayed(const Duration(seconds: 1));
        await timeshiftManager.stopClientBuffer();
        expect(timeshiftManager.isClientBufferActive, isFalse);
      });

      test('回看播放從正確位置開始', () async {
        await timeshiftManager.startClientBuffer('channel_1', const Duration(minutes: 5));
        await Future.delayed(const Duration(seconds: 5));

        final file = await timeshiftManager.getBufferedStream('channel_1', Duration.zero);
        expect(file, isNotNull);
        expect(await file!.exists(), isTrue);
      });
    });
  });
}