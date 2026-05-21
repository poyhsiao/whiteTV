import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/live/presentation/widgets/epg_program_list.dart';
import 'package:white_tv/features/live/data/models/epg_program.dart';

void main() {
  group('EpgProgramList', () {
    testWidgets('displays list of programs', (tester) async {
      final programs = [
        EpgProgram(
          id: 'prog1',
          channelId: 'ch1',
          title: 'Morning Show',
          startTime: DateTime(2026, 5, 21, 8, 0),
          endTime: DateTime(2026, 5, 21, 9, 0),
        ),
        EpgProgram(
          id: 'prog2',
          channelId: 'ch1',
          title: 'Afternoon Show',
          startTime: DateTime(2026, 5, 21, 9, 0),
          endTime: DateTime(2026, 5, 21, 10, 0),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: EpgProgramList(
                programs: programs,
                onProgramTap: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Morning Show'), findsOneWidget);
      expect(find.text('Afternoon Show'), findsOneWidget);
    });

    testWidgets('shows currently active program', (tester) async {
      final now = DateTime.now();
      final programs = [
        EpgProgram(
          id: 'prog1',
          channelId: 'ch1',
          title: 'Past Show',
          startTime: now.subtract(const Duration(hours: 2)),
          endTime: now.subtract(const Duration(hours: 1)),
        ),
        EpgProgram(
          id: 'prog2',
          channelId: 'ch1',
          title: 'Current Show',
          startTime: now.subtract(const Duration(minutes: 30)),
          endTime: now.add(const Duration(minutes: 30)),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: EpgProgramList(
                programs: programs,
                onProgramTap: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Current Show'), findsOneWidget);
    });

    testWidgets('calls onProgramTap with correct program', (tester) async {
      EpgProgram? tappedProgram;
      final programs = [
        EpgProgram(
          id: 'prog1',
          channelId: 'ch1',
          title: 'Tap Me',
          startTime: DateTime(2026, 5, 21, 10, 0),
          endTime: DateTime(2026, 5, 21, 11, 0),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: EpgProgramList(
                programs: programs,
                onProgramTap: (program) => tappedProgram = program,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      expect(tappedProgram?.title, 'Tap Me');
    });

    testWidgets('shows empty state when no programs', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: EpgProgramList(
                programs: const [],
                onProgramTap: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('No programs available'), findsOneWidget);
    });

    testWidgets('is scrollable for many programs', (tester) async {
      final programs = List.generate(
        20,
        (i) => EpgProgram(
          id: 'prog$i',
          channelId: 'ch1',
          title: 'Program $i',
          startTime: DateTime(2026, 5, 21, i, 0),
          endTime: DateTime(2026, 5, 21, i + 1, 0),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: EpgProgramList(
                programs: programs,
                onProgramTap: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}