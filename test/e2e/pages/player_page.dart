import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'base_page.dart';

class PlayerPage extends BasePage {
  PlayerPage(super.tester);

  static const playerKey = Key('video_player');
  static const playPauseButtonKey = Key('play_pause_button');

  /// Verify player is visible
  bool isPlayerVisible() {
    return find.byKey(playerKey).evaluate().isNotEmpty;
  }

  /// Tap play/pause
  Future<void> togglePlayPause() async {
    await tester.tap(find.byKey(playPauseButtonKey));
    await tester.pumpAndSettle();
  }

  /// Wait for video to load
  Future<void> waitForVideo() async {
    await tester.pump(const Duration(seconds: 3));
  }
}
