import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/live/presentation/widgets/timeshift_control_bar.dart';

void main() {
  group('TimeshiftControlBar', () {
    testWidgets('displays current timeshift position', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TimeshiftControlBar(
                position: const Duration(minutes: -10),
                isLive: false,
                onSeek: (_) {},
                onPlayPause: () {},
                onGoLive: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('-10:00'), findsOneWidget);
    });

    testWidgets('shows LIVE badge when at live position', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TimeshiftControlBar(
                position: Duration.zero,
                isLive: true,
                onSeek: (_) {},
                onPlayPause: () {},
                onGoLive: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('LIVE'), findsOneWidget);
    });

    testWidgets('calls onPlayPause when play/pause is tapped', (tester) async {
      var playPauseCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TimeshiftControlBar(
                position: const Duration(minutes: -5),
                isLive: false,
                isPaused: true,
                onSeek: (_) {},
                onPlayPause: () => playPauseCalled = true,
                onGoLive: () {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.play_arrow));
      expect(playPauseCalled, isTrue);
    });

    testWidgets('calls onGoLive when LIVE button is tapped', (tester) async {
      var goLiveCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TimeshiftControlBar(
                position: const Duration(minutes: -10),
                isLive: false,
                onSeek: (_) {},
                onPlayPause: () {},
                onGoLive: () => goLiveCalled = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('GO LIVE'));
      expect(goLiveCalled, isTrue);
    });

    testWidgets('displays progress bar showing buffer position', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TimeshiftControlBar(
                position: const Duration(minutes: -30),
                isLive: false,
                onSeek: (_) {},
                onPlayPause: () {},
                onGoLive: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('displays rewind button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TimeshiftControlBar(
                position: const Duration(minutes: -10),
                isLive: false,
                onSeek: (_) {},
                onPlayPause: () {},
                onGoLive: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.replay), findsOneWidget);
    });

    testWidgets('displays fast forward button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TimeshiftControlBar(
                position: const Duration(minutes: -10),
                isLive: false,
                onSeek: (_) {},
                onPlayPause: () {},
                onGoLive: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.forward_10), findsOneWidget);
    });
  });
}