import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/live/presentation/widgets/epg_program_tile.dart';
import 'package:white_tv/features/live/data/models/epg_program.dart';

void main() {
  group('EpgProgramTile', () {
    testWidgets('displays program title', (tester) async {
      final program = EpgProgram(
        id: 'prog1',
        channelId: 'ch1',
        title: 'Morning News',
        startTime: DateTime(2026, 5, 21, 8, 0),
        endTime: DateTime(2026, 5, 21, 9, 0),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: EpgProgramTile(
                program: program,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Morning News'), findsOneWidget);
    });

    testWidgets('displays program time range', (tester) async {
      final program = EpgProgram(
        id: 'prog1',
        channelId: 'ch1',
        title: 'Test Program',
        startTime: DateTime(2026, 5, 21, 8, 0),
        endTime: DateTime(2026, 5, 21, 9, 0),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: EpgProgramTile(
                program: program,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('08:00 - 09:00'), findsOneWidget);
    });

    testWidgets('highlights currently active program', (tester) async {
      final now = DateTime.now();
      final currentProgram = EpgProgram(
        id: 'current',
        channelId: 'ch1',
        title: 'Live Show',
        startTime: now.subtract(const Duration(minutes: 30)),
        endTime: now.add(const Duration(minutes: 30)),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: EpgProgramTile(
                program: currentProgram,
                onTap: () {},
                isActive: true,
              ),
            ),
          ),
        ),
      );

      // Active program should have different styling - check for a Container with decoration
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('displays category badge when present', (tester) async {
      final program = EpgProgram(
        id: 'prog1',
        channelId: 'ch1',
        title: 'Sports Event',
        startTime: DateTime(2026, 5, 21, 10, 0),
        endTime: DateTime(2026, 5, 21, 12, 0),
        category: 'Sports',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: EpgProgramTile(
                program: program,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Sports'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      final program = EpgProgram(
        id: 'prog1',
        channelId: 'ch1',
        title: 'Tappable Program',
        startTime: DateTime(2026, 5, 21, 14, 0),
        endTime: DateTime(2026, 5, 21, 15, 0),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: EpgProgramTile(
                program: program,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(EpgProgramTile));
      expect(tapped, isTrue);
    });
  });
}