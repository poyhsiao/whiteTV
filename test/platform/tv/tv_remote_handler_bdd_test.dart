import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/platform/tv/remote_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TV Remote Handler — UI_UX.md §16', () {
    // ── Player key handling ─────────────────────────────────────────────────

    test('mediaPlayPause is recognized as player key', () {
      expect(
        TVRemoteHandler.isPlayerKey(LogicalKeyboardKey.mediaPlayPause),
        true,
      );
    });

    test('mediaFastForward is recognized as player key', () {
      expect(
        TVRemoteHandler.isPlayerKey(LogicalKeyboardKey.mediaFastForward),
        true,
      );
    });

    test('mediaRewind is recognized as player key', () {
      expect(
        TVRemoteHandler.isPlayerKey(LogicalKeyboardKey.mediaRewind),
        true,
      );
    });

    test('mediaTrackNext is recognized as player key', () {
      expect(
        TVRemoteHandler.isPlayerKey(LogicalKeyboardKey.mediaTrackNext),
        true,
      );
    });

    test('mediaTrackPrevious is recognized as player key', () {
      expect(
        TVRemoteHandler.isPlayerKey(LogicalKeyboardKey.mediaTrackPrevious),
        true,
      );
    });

    // ── Volume key handling ─────────────────────────────────────────────────

    test('audioVolumeUp is recognized as volume key', () {
      expect(TVRemoteHandler.isVolumeKey(LogicalKeyboardKey.audioVolumeUp), true);
    });

    test('audioVolumeDown is recognized as volume key', () {
      expect(TVRemoteHandler.isVolumeKey(LogicalKeyboardKey.audioVolumeDown), true);
    });

    test('audioVolumeMute is recognized as volume key', () {
      expect(TVRemoteHandler.isVolumeKey(LogicalKeyboardKey.audioVolumeMute), true);
    });

    // ── Navigation key handling ────────────────────────────────────────────

    test('browserBack is recognized as navigation key', () {
      expect(TVRemoteHandler.isNavigationKey(LogicalKeyboardKey.browserBack), true);
    });

    test('home is recognized as navigation key', () {
      expect(TVRemoteHandler.isNavigationKey(LogicalKeyboardKey.home), true);
    });

    test('escape is recognized as navigation key', () {
      expect(TVRemoteHandler.isNavigationKey(LogicalKeyboardKey.escape), true);
    });

    // ── Integration: key → handled ─────────────────────────────────────────

    test('mediaPlayPause keyEvent returns true (key handled)', () {
      final event = KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.mediaPlayPause,
        logicalKey: LogicalKeyboardKey.mediaPlayPause,
        timeStamp: Duration.zero,
      );
      final handler = TVRemoteHandler();
      expect(handler.handleKey(event), true);
    });

    // ── PlayerControls callback dispatch ───────────────────────────────────

    test('FAST_FORWARD key triggers seekForward(10s) via PlayerControls', () {
      bool seekCalled = false;
      Duration seekAmount = Duration.zero;

      final handler = TVRemoteHandler(playerControls: _FakeControls(
        onSeekForward: (d) { seekCalled = true; seekAmount = d; },
      ));

      handler.handleKey(KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.mediaFastForward,
        logicalKey: LogicalKeyboardKey.mediaFastForward,
        timeStamp: Duration.zero,
      ));

      expect(seekCalled, true, reason: 'FAST_FORWARD should call seekForward');
      expect(seekAmount, const Duration(seconds: 10));
    });

    test('REWIND key triggers seekBackward(10s) via PlayerControls', () {
      bool seekCalled = false;
      Duration seekAmount = Duration.zero;

      final handler = TVRemoteHandler(playerControls: _FakeControls(
        onSeekBackward: (d) { seekCalled = true; seekAmount = d; },
      ));

      handler.handleKey(KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.mediaRewind,
        logicalKey: LogicalKeyboardKey.mediaRewind,
        timeStamp: Duration.zero,
      ));

      expect(seekCalled, true, reason: 'REWIND should call seekBackward');
      expect(seekAmount, const Duration(seconds: 10));
    });

    test('TRACK_NEXT key triggers nextEpisode via PlayerControls', () {
      bool nextCalled = false;

      final handler = TVRemoteHandler(playerControls: _FakeControls(
        onNextEpisode: () => nextCalled = true,
      ));

      handler.handleKey(KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.mediaTrackNext,
        logicalKey: LogicalKeyboardKey.mediaTrackNext,
        timeStamp: Duration.zero,
      ));

      expect(nextCalled, true, reason: 'TRACK_NEXT should call nextEpisode');
    });

    test('TRACK_PREVIOUS key triggers previousEpisode via PlayerControls', () {
      bool prevCalled = false;

      final handler = TVRemoteHandler(playerControls: _FakeControls(
        onPreviousEpisode: () => prevCalled = true,
      ));

      handler.handleKey(KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.mediaTrackPrevious,
        logicalKey: LogicalKeyboardKey.mediaTrackPrevious,
        timeStamp: Duration.zero,
      ));

      expect(prevCalled, true, reason: 'TRACK_PREVIOUS should call previousEpisode');
    });
  });
}

class _FakeControls implements PlayerControls {
  final void Function()? onPlay;
  final void Function()? onPause;
  final void Function(Duration)? onSeekForward;
  final void Function(Duration)? onSeekBackward;
  final void Function()? onNextEpisode;
  final void Function()? onPreviousEpisode;

  _FakeControls({
    this.onSeekForward,
    this.onSeekBackward,
    this.onNextEpisode,
    this.onPreviousEpisode,
  }) : onPause = null, onPlay = null;

  @override
  void play() => onPlay?.call();
  @override
  void pause() => onPause?.call();
  @override
  void seekForward(Duration d) => onSeekForward?.call(d);
  @override
  void seekBackward(Duration d) => onSeekBackward?.call(d);
  @override
  void nextEpisode() => onNextEpisode?.call();
  @override
  void previousEpisode() => onPreviousEpisode?.call();
}
