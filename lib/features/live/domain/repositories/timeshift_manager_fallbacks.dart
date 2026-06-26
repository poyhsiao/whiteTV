// Default fallback implementations for TimeshiftManager abstract methods.
// Tests can mix this in instead of implementing those methods explicitly.
import 'dart:async';
import 'dart:io';
import 'timeshift_manager.dart';

/// TimeshiftState stub
class _DummyTimeshiftState implements TimeshiftState {
  @override
  bool get isPaused => false;
  @override
  bool get isLive => true;
  @override
  Duration get position => Duration.zero;
  @override
  Duration get bufferedDuration => Duration.zero;
}

mixin TimeshiftManagerFallbacks implements TimeshiftManager {
  @override
  bool get isClientBufferActive => false;

  @override
  Future<File?> getBufferedStream(String channelId, Duration offset) async => null;

  @override
  Future<TimeshiftController> startTimeshift({required String channelId, required String streamUrl}) async {
    return TimeshiftController(channelId: channelId, streamUrl: streamUrl, startTime: DateTime.now());
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<Duration> seek(Duration position) async => position;

  @override
  Future<Duration> fastForward(Duration duration) async => duration;

  @override
  Future<Duration> rewind(Duration duration) async => Duration.zero;

  @override
  Future<void> stopTimeshift() async {}

  @override
  bool get isTimeshiftActive => false;

  @override
  Duration get maxTimeshiftDuration => const Duration(minutes: 30);

  @override
  Future<TimeshiftState> getState() async => _DummyTimeshiftState();

  @override
  Future<bool> isServiceSideSupported(String channelId) async => false;

  @override
  Future<String?> getServiceSideStream(String channelId, Duration startOffset, Duration endOffset) async => null;

  @override
  Future<void> startClientBuffer(String channelId, Duration duration) async {}

  @override
  Future<void> stopClientBuffer() async {}
}