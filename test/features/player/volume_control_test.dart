import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/player/widgets/volume_control.dart';

void main() {
  group('VolumeControl', () {
    testWidgets('shows volume icon when not muted', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VolumeControl(
              volume: 0.75,
              isMuted: false,
              onVolumeChanged: (_) {},
              onMuteToggled: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.volume_up), findsOneWidget);
    });

    testWidgets('shows muted icon when muted', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VolumeControl(
              volume: 0.75,
              isMuted: true,
              onVolumeChanged: (_) {},
              onMuteToggled: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.volume_off), findsOneWidget);
    });

    testWidgets('shows volume slider', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VolumeControl(
              volume: 0.75,
              isMuted: false,
              onVolumeChanged: (_) {},
              onMuteToggled: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('displays volume percentage', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VolumeControl(
              volume: 0.75,
              isMuted: false,
              onVolumeChanged: (_) {},
              onMuteToggled: () {},
            ),
          ),
        ),
      );

      expect(find.text('75%'), findsOneWidget);
    });
  });
}
