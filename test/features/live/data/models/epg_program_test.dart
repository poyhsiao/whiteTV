import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/live/data/models/epg_program.dart';

void main() {
  group('EpgProgram', () {
    test('creates program with all fields', () {
      final program = EpgProgram(
        id: 'prog1',
        channelId: 'channel1',
        title: 'News',
        description: 'Daily news broadcast',
        startTime: DateTime(2026, 5, 21, 9, 0),
        endTime: DateTime(2026, 5, 21, 10, 0),
        category: 'News',
      );

      expect(program.id, 'prog1');
      expect(program.channelId, 'channel1');
      expect(program.title, 'News');
      expect(program.description, 'Daily news broadcast');
      expect(program.startTime, DateTime(2026, 5, 21, 9, 0));
      expect(program.endTime, DateTime(2026, 5, 21, 10, 0));
      expect(program.category, 'News');
    });

    test('calculates duration correctly', () {
      final program = EpgProgram(
        id: 'prog1',
        channelId: 'channel1',
        title: 'News',
        startTime: DateTime(2026, 5, 21, 9, 0),
        endTime: DateTime(2026, 5, 21, 9, 30),
      );

      expect(program.duration, const Duration(minutes: 30));
    });

    test('isCurrentlyActive returns true when current time is within program', () {
      final now = DateTime.now();
      final program = EpgProgram(
        id: 'prog1',
        channelId: 'channel1',
        title: 'Live Show',
        startTime: now.subtract(const Duration(minutes: 30)),
        endTime: now.add(const Duration(minutes: 30)),
      );

      expect(program.isCurrentlyActive, isTrue);
    });

    test('isCurrentlyActive returns false when program has ended', () {
      final program = EpgProgram(
        id: 'prog1',
        channelId: 'channel1',
        title: 'Old Show',
        startTime: DateTime(2026, 5, 21, 8, 0),
        endTime: DateTime(2026, 5, 21, 9, 0),
      );

      expect(program.isCurrentlyActive, isFalse);
    });

    test('parses from XML element attributes', () {
      final program = EpgProgram.fromXmlAttributes(
        id: 'prog_xml_1',
        channelId: 'channel1',
        title: 'XML Program',
        description: 'From XML',
        startTime: DateTime(2026, 5, 21, 12, 0),
        endTime: DateTime(2026, 5, 21, 13, 0),
        category: 'Sports',
      );

      expect(program.title, 'XML Program');
      expect(program.category, 'Sports');
    });
  });
}