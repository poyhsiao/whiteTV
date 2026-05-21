import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/live/domain/repositories/epg_manager.dart';

void main() {
  group('EpgManager', () {
    late EpgManager epgManager;

    setUp(() {
      epgManager = EpgManagerImpl();
    });

    test('fetches EPG data for a channel', () async {
      final epgData = await epgManager.fetchEpg('channel1');

      expect(epgData, isNotNull);
      expect(epgData.id, 'channel1');
      expect(epgData.programs, isNotEmpty);
    });

    test('returns channel with programs sorted by start time', () async {
      final epgData = await epgManager.fetchEpg('channel1');

      expect(epgData.programsAreSortedByStartTime, isTrue);
    });

    test('gets current program for channel', () async {
      final currentProgram = await epgManager.getCurrentProgram('channel1');

      // Current program should exist and be currently active
      expect(currentProgram, isNotNull);
      expect(currentProgram!.isCurrentlyActive, isTrue);
    });

    test('gets program by specific time', () async {
      final now = DateTime.now();
      final program = await epgManager.getProgramAtTime('channel1', now);

      expect(program, isNotNull);
    });

    test('caches EPG data to avoid redundant fetches', () async {
      // First fetch
      await epgManager.fetchEpg('channel1');

      // Second fetch should use cache - we just verify it returns quickly
      final stopwatch = Stopwatch()..start();
      await epgManager.fetchEpg('channel1');
      stopwatch.stop();

      // Cache hit should be very fast
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('handles channel with no programs', () async {
      final epgData = await epgManager.fetchEpg('nonexistent_channel');

      expect(epgData.programs, isEmpty);
    });

    test('gets programs for specific day', () async {
      final today = DateTime.now();
      final programs = await epgManager.getProgramsForDay('channel1', today);

      expect(programs, isNotNull);
      // All programs should be on the specified day
      for (final program in programs) {
        expect(program.startTime.year, today.year);
        expect(program.startTime.month, today.month);
        expect(program.startTime.day, today.day);
      }
    });
  });
}