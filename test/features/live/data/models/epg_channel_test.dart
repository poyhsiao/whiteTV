import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/live/data/models/epg_channel.dart';
import 'package:white_tv/features/live/data/models/epg_program.dart';

void main() {
  group('EpgChannel', () {
    test('creates channel with all fields', () {
      final channel = EpgChannel(
        id: 'channel1',
        name: 'News Channel',
        logoUrl: 'https://example.com/news.png',
        programs: [],
      );

      expect(channel.id, 'channel1');
      expect(channel.name, 'News Channel');
      expect(channel.logoUrl, 'https://example.com/news.png');
      expect(channel.programs, isEmpty);
    });

    test('addProgram adds program to list', () {
      final channel = EpgChannel(
        id: 'channel1',
        name: 'News Channel',
        programs: [],
      );

      final program = EpgProgram(
        id: 'prog1',
        channelId: 'channel1',
        title: 'Morning Show',
        startTime: DateTime(2026, 5, 21, 8, 0),
        endTime: DateTime(2026, 5, 21, 9, 0),
      );

      final updatedChannel = channel.addProgram(program);

      expect(updatedChannel.programs.length, 1);
      expect(updatedChannel.programs.first.title, 'Morning Show');
    });

    test('programsAreSortedByStartTime sorts programs correctly', () {
      final now = DateTime.now();
      final prog1 = EpgProgram(
        id: 'prog1',
        channelId: 'channel1',
        title: 'Earlier',
        startTime: now.add(const Duration(hours: 1)),
        endTime: now.add(const Duration(hours: 2)),
      );
      final prog2 = EpgProgram(
        id: 'prog2',
        channelId: 'channel1',
        title: 'Later',
        startTime: now.add(const Duration(hours: 2)),
        endTime: now.add(const Duration(hours: 3)),
      );

      final channel = EpgChannel(
        id: 'channel1',
        name: 'Channel',
        programs: [prog1, prog2],
      );

      expect(channel.programsAreSortedByStartTime, isTrue);
    });

    test('currentProgram returns program that is currently active', () {
      final now = DateTime.now();
      final pastProgram = EpgProgram(
        id: 'prog1',
        channelId: 'channel1',
        title: 'Past',
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 1)),
      );
      final currentProgram = EpgProgram(
        id: 'prog2',
        channelId: 'channel1',
        title: 'Current',
        startTime: now.subtract(const Duration(minutes: 30)),
        endTime: now.add(const Duration(minutes: 30)),
      );
      final futureProgram = EpgProgram(
        id: 'prog3',
        channelId: 'channel1',
        title: 'Future',
        startTime: now.add(const Duration(hours: 1)),
        endTime: now.add(const Duration(hours: 2)),
      );

      final channel = EpgChannel(
        id: 'channel1',
        name: 'Channel',
        programs: [pastProgram, currentProgram, futureProgram],
      );

      expect(channel.currentProgram?.title, 'Current');
    });

    test('programsForDay filters programs for specific day', () {
      final dayStart = DateTime(2026, 5, 21, 0, 0);
      final prog1 = EpgProgram(
        id: 'prog1',
        channelId: 'channel1',
        title: 'On Day',
        startTime: DateTime(2026, 5, 21, 10, 0),
        endTime: DateTime(2026, 5, 21, 11, 0),
      );
      final prog2 = EpgProgram(
        id: 'prog2',
        channelId: 'channel1',
        title: 'Next Day',
        startTime: DateTime(2026, 5, 22, 10, 0),
        endTime: DateTime(2026, 5, 22, 11, 0),
      );

      final channel = EpgChannel(
        id: 'channel1',
        name: 'Channel',
        programs: [prog1, prog2],
      );

      expect(channel.programsForDay(dayStart).length, 1);
      expect(channel.programsForDay(dayStart).first.title, 'On Day');
    });
  });
}