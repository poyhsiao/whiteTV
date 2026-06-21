import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/live/domain/services/timeshift_client_buffer.dart';

void main() {
  group('TimeshiftClientBuffer', () {
    late TimeshiftClientBuffer buffer;

    setUp(() {
      buffer = TimeshiftClientBuffer();
    });

    group('initial state', () {
      test('is not active', () {
        expect(buffer.isActive, isFalse);
      });

      test('channelId is null', () {
        expect(buffer.channelId, isNull);
      });

      test('maxDuration is zero', () {
        expect(buffer.maxDuration, Duration.zero);
      });

      test('bufferedDuration is zero', () {
        expect(buffer.bufferedDuration, Duration.zero);
      });

      test('maxBufferDuration constant is 30 minutes', () {
        expect(
          TimeshiftClientBuffer.maxBufferDuration,
          const Duration(minutes: 30),
        );
      });
    });

    group('start', () {
      test('activates buffer for a channel', () async {
        await buffer.start('ch-1', const Duration(minutes: 10));

        expect(buffer.isActive, isTrue);
        expect(buffer.channelId, 'ch-1');
        expect(buffer.maxDuration, const Duration(minutes: 10));
        expect(buffer.bufferedDuration, Duration.zero);
      });

      test('does nothing for empty channel ID', () async {
        await buffer.start('', const Duration(minutes: 10));

        expect(buffer.isActive, isFalse);
        expect(buffer.channelId, isNull);
      });

      test('clamps duration to maxBufferDuration', () async {
        await buffer.start('ch-1', const Duration(hours: 1));

        expect(buffer.maxDuration, TimeshiftClientBuffer.maxBufferDuration);
      });

      test('keeps requested duration when under max', () async {
        await buffer.start('ch-1', const Duration(minutes: 5));

        expect(buffer.maxDuration, const Duration(minutes: 5));
      });

      test('stops previous buffer when starting a new channel', () async {
        await buffer.start('ch-1', const Duration(minutes: 10));
        await buffer.start('ch-2', const Duration(minutes: 15));

        expect(buffer.channelId, 'ch-2');
        expect(buffer.maxDuration, const Duration(minutes: 15));
      });

      test('does nothing when restarting same channel', () async {
        await buffer.start('ch-1', const Duration(minutes: 10));
        // Start again — should be a no-op for same channel
        await buffer.start('ch-1', const Duration(minutes: 20));

        // Duration stays at original (first start's clamped value)
        expect(buffer.maxDuration, const Duration(minutes: 10));
        expect(buffer.channelId, 'ch-1');
      });
    });

    group('stop', () {
      test('clears all state', () async {
        await buffer.start('ch-1', const Duration(minutes: 10));
        await buffer.stop();

        expect(buffer.isActive, isFalse);
        expect(buffer.channelId, isNull);
        expect(buffer.maxDuration, Duration.zero);
        expect(buffer.bufferedDuration, Duration.zero);
      });

      test('is safe to call when not active', () async {
        await buffer.stop();

        expect(buffer.isActive, isFalse);
        expect(buffer.channelId, isNull);
      });

      test('can start a new buffer after stopping', () async {
        await buffer.start('ch-1', const Duration(minutes: 10));
        await buffer.stop();
        await buffer.start('ch-2', const Duration(minutes: 5));

        expect(buffer.isActive, isTrue);
        expect(buffer.channelId, 'ch-2');
        expect(buffer.maxDuration, const Duration(minutes: 5));
      });
    });

    group('clamping edge cases', () {
      test('duration equal to max is kept', () async {
        await buffer.start(
          'ch-1',
          TimeshiftClientBuffer.maxBufferDuration,
        );

        expect(
          buffer.maxDuration,
          TimeshiftClientBuffer.maxBufferDuration,
        );
      });

      test('very large duration is clamped', () async {
        await buffer.start('ch-1', const Duration(hours: 24));

        expect(buffer.maxDuration, TimeshiftClientBuffer.maxBufferDuration);
      });
    });
  });
}
