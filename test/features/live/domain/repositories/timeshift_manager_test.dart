import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/live/domain/repositories/timeshift_manager.dart';

void main() {
  group('TimeshiftManager', () {
    late TimeshiftManager timeshiftManager;

    setUp(() {
      timeshiftManager = TimeshiftManagerImpl();
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
  });
}