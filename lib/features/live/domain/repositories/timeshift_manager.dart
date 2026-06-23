import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

abstract interface class TimeshiftManager {
  const TimeshiftManager();

  Future<TimeshiftController> startTimeshift({
    required String channelId,
    required String streamUrl,
  });

  Future<void> pause();
  Future<void> resume();
  Future<Duration> seek(Duration position);
  Future<Duration> fastForward(Duration duration);
  Future<Duration> rewind(Duration duration);
  Future<void> stopTimeshift();

  bool get isTimeshiftActive;
  Duration get maxTimeshiftDuration;

  Future<TimeshiftState> getState();

  Future<bool> isServiceSideSupported(String channelId);

  Future<String?> getServiceSideStream(
    String channelId,
    Duration startOffset,
    Duration endOffset,
  );

  Future<void> startClientBuffer(String channelId, Duration duration);

  Future<void> stopClientBuffer();

  bool get isClientBufferActive;
}

class TimeshiftController {
  final String channelId;
  final String streamUrl;
  final DateTime startTime;

  const TimeshiftController({
    required this.channelId,
    required this.streamUrl,
    required this.startTime,
  });
}

class TimeshiftState {
  final Duration position;
  final Duration bufferedDuration;
  final bool isPaused;
  final bool isLive;

  const TimeshiftState({
    required this.position,
    required this.bufferedDuration,
    required this.isPaused,
    required this.isLive,
  });
}

class TimeshiftManagerImpl implements TimeshiftManager {
  TimeshiftController? _controller;
  TimeshiftState? _state;
  bool _isClientBufferActive = false;

  File? _bufferFile;
  IOSink? _bufferSink;
  Timer? _segmentTimer;
  String? _currentChannelId;
  Duration? _maxDuration;
  DateTime? _recordingStartTime;

  static const _maxTimeshiftDuration = Duration(days: 7);

  TimeshiftManagerImpl();

  @override
  Future<TimeshiftController> startTimeshift({
    required String channelId,
    required String streamUrl,
  }) async {
    _controller = TimeshiftController(
      channelId: channelId,
      streamUrl: streamUrl,
      startTime: DateTime.now(),
    );
    _state = TimeshiftState(
      position: Duration.zero,
      bufferedDuration: Duration.zero,
      isPaused: false,
      isLive: true,
    );
    return _controller!;
  }

  @override
  Future<void> pause() async {
    _state = _state?.copyWith(isPaused: true);
  }

  @override
  Future<void> resume() async {
    _state = _state?.copyWith(isPaused: false, isLive: false);
  }

  @override
  Future<Duration> seek(Duration position) async {
    final clampedPosition = position.isNegative
        ? Duration.zero
        : (position > _maxTimeshiftDuration ? _maxTimeshiftDuration : position);
    _state = _state?.copyWith(position: clampedPosition, isLive: false);
    return clampedPosition;
  }

  @override
  Future<Duration> fastForward(Duration duration) async {
    if (_state == null) return Duration.zero;
    final newPosition = _state!.position + duration;
    return seek(newPosition);
  }

  @override
  Future<Duration> rewind(Duration duration) async {
    if (_state == null) return Duration.zero;
    final newPosition = _state!.position - duration;
    return seek(newPosition);
  }

  @override
  Future<void> stopTimeshift() async {
    _controller = null;
    _state = null;
  }

  @override
  bool get isTimeshiftActive => _controller != null;

  @override
  Duration get maxTimeshiftDuration => _maxTimeshiftDuration;

  @override
  Future<TimeshiftState> getState() async {
    return _state ?? const TimeshiftState(
      position: Duration.zero,
      bufferedDuration: Duration.zero,
      isPaused: false,
      isLive: true,
    );
  }

  @override
  Future<bool> isServiceSideSupported(String channelId) async {
    return false;
  }

  @override
  Future<String?> getServiceSideStream(
    String channelId,
    Duration startOffset,
    Duration endOffset,
  ) async {
    return null;
  }

  @override
  Future<void> startClientBuffer(String channelId, Duration duration) async {
    _currentChannelId = channelId;
    _maxDuration = duration;
    _recordingStartTime = DateTime.now();
    _isClientBufferActive = true;

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _bufferFile = File('${tempDir.path}/timeshift_${channelId}_$timestamp.ts');
    _bufferSink = _bufferFile!.openWrite();

    _segmentTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _createNewSegment(channelId, duration);
    });
  }

  Future<void> _createNewSegment(String channelId, Duration maxDuration) async {
    await _bufferSink?.close();

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _bufferFile = File('${tempDir.path}/timeshift_${channelId}_$timestamp.ts');
    _bufferSink = _bufferFile!.openWrite();

    await _cleanupOldSegments(channelId, maxDuration);
  }

  Future<void> _cleanupOldSegments(String channelId, Duration maxDuration) async {
    final tempDir = await getTemporaryDirectory();
    final now = DateTime.now();
    final cutoffTime = now.subtract(maxDuration);

    await for (final entity in tempDir.list()) {
      if (entity is File && entity.path.contains('timeshift_$channelId')) {
        final stat = await entity.stat();
        if (stat.modified.isBefore(cutoffTime)) {
          await entity.delete();
        }
      }
    }
  }

  @override
  Future<void> stopClientBuffer() async {
    _segmentTimer?.cancel();
    _segmentTimer = null;
    await _bufferSink?.close();
    _bufferSink = null;
    _bufferFile = null;
    _currentChannelId = null;
    _maxDuration = null;
    _recordingStartTime = null;
    _isClientBufferActive = false;
  }

  @override
  bool get isClientBufferActive => _isClientBufferActive;
}

extension on TimeshiftState {
  TimeshiftState copyWith({
    Duration? position,
    Duration? bufferedDuration,
    bool? isPaused,
    bool? isLive,
  }) {
    return TimeshiftState(
      position: position ?? this.position,
      bufferedDuration: bufferedDuration ?? this.bufferedDuration,
      isPaused: isPaused ?? this.isPaused,
      isLive: isLive ?? this.isLive,
    );
  }
}