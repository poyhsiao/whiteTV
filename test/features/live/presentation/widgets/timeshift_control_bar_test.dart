import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/live/presentation/widgets/timeshift_control_bar.dart';

void main() {
  group('TimeshiftControlBar', () {
    group('live mode', () {
      testWidgets('shows red badge with label 直播中', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimeshiftControlBar(
                position: Duration.zero,
                mode: TimeshiftMode.live,
                onSeek: (_) {},
                onPlayPause: () {},
                onGoLive: () {},
              ),
            ),
          ),
        );

        expect(find.text('直播中'), findsOneWidget);
      });

      testWidgets('progress bar is full (1.0) in live mode', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimeshiftControlBar(
                position: Duration.zero,
                mode: TimeshiftMode.live,
                onSeek: (_) {},
                onPlayPause: () {},
                onGoLive: () {},
              ),
            ),
          ),
        );

        final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(indicator.value, 1.0);
      });

      testWidgets('GO LIVE button is hidden', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimeshiftControlBar(
                position: Duration.zero,
                mode: TimeshiftMode.live,
                onSeek: (_) {},
                onPlayPause: () {},
                onGoLive: () {},
              ),
            ),
          ),
        );

        expect(find.text('GO LIVE'), findsNothing);
      });
    });

    group('service mode', () {
      testWidgets('shows blue badge with time label', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimeshiftControlBar(
                position: const Duration(minutes: -10),
                mode: TimeshiftMode.service,
                onSeek: (_) {},
                onPlayPause: () {},
                onGoLive: () {},
              ),
            ),
          ),
        );

        expect(find.text('時移 -10:00'), findsOneWidget);
      });

      testWidgets('progress bar is half in service mode', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimeshiftControlBar(
                position: const Duration(minutes: -5),
                mode: TimeshiftMode.service,
                onSeek: (_) {},
                onPlayPause: () {},
                onGoLive: () {},
              ),
            ),
          ),
        );

        final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(indicator.value, 0.5);
      });

      testWidgets('GO LIVE button is visible', (tester) async {
        var goLiveCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimeshiftControlBar(
                position: const Duration(minutes: -10),
                mode: TimeshiftMode.service,
                onSeek: (_) {},
                onPlayPause: () {},
                onGoLive: () => goLiveCalled = true,
              ),
            ),
          ),
        );

        expect(find.text('GO LIVE'), findsOneWidget);
        await tester.tap(find.text('GO LIVE'));
        expect(goLiveCalled, isTrue);
      });
    });

    group('buffer mode', () {
      testWidgets('shows orange badge with label 緩存中', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimeshiftControlBar(
                position: const Duration(seconds: -30),
                mode: TimeshiftMode.buffer,
                onSeek: (_) {},
                onPlayPause: () {},
                onGoLive: () {},
              ),
            ),
          ),
        );

        expect(find.text('緩存中'), findsOneWidget);
      });

      testWidgets('shows cloud_download icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimeshiftControlBar(
                position: const Duration(seconds: -30),
                mode: TimeshiftMode.buffer,
                onSeek: (_) {},
                onPlayPause: () {},
                onGoLive: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.cloud_download), findsOneWidget);
      });

      testWidgets('progress bar is half in buffer mode', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimeshiftControlBar(
                position: const Duration(seconds: -30),
                mode: TimeshiftMode.buffer,
                onSeek: (_) {},
                onPlayPause: () {},
                onGoLive: () {},
              ),
            ),
          ),
        );

        final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(indicator.value, 0.5);
      });
    });

    group('controls', () {
      testWidgets('calls onPlayPause when play/pause is tapped',
          (tester) async {
        var playPauseCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimeshiftControlBar(
                position: const Duration(minutes: -5),
                mode: TimeshiftMode.service,
                isPaused: true,
                onSeek: (_) {},
                onPlayPause: () => playPauseCalled = true,
                onGoLive: () {},
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.play_arrow));
        expect(playPauseCalled, isTrue);
      });

      testWidgets('displays rewind button', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimeshiftControlBar(
                position: const Duration(minutes: -10),
                mode: TimeshiftMode.service,
                onSeek: (_) {},
                onPlayPause: () {},
                onGoLive: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.replay), findsOneWidget);
      });

      testWidgets('displays fast forward button', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimeshiftControlBar(
                position: const Duration(minutes: -10),
                mode: TimeshiftMode.service,
                onSeek: (_) {},
                onPlayPause: () {},
                onGoLive: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.forward_10), findsOneWidget);
      });

      testWidgets('displays progress bar', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TimeshiftControlBar(
                position: const Duration(minutes: -30),
                mode: TimeshiftMode.service,
                onSeek: (_) {},
                onPlayPause: () {},
                onGoLive: () {},
              ),
            ),
          ),
        );

        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });
    });
  });
}
