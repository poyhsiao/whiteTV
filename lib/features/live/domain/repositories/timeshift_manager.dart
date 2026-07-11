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

  Future<File?> getBufferedStream(String channelId, Duration offset);
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
  final List<_SegmentMetadata> _segments = [];

  static const _maxTimeshiftDuration = Duration(days: 7);
  static const _segmentDuration = Duration(seconds: 30);

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
    _isClientBufferActive = true;
    _segments.clear();

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _bufferFile = File('${tempDir.path}/timeshift_${channelId}_$timestamp.ts');
    _bufferSink = _bufferFile!.openWrite();

    _segments.add(_SegmentMetadata(
      file: _bufferFile!,
      startTime: DateTime.now(),
    ));

    _segmentTimer = Timer.periodic(_segmentDuration, (_) {
      _createNewSegment(channelId, duration).catchError((e) {
        _segmentTimer?.cancel();
        _segmentTimer = null;
        // Re-throw on outer zone so the error is not silently swallowed
        throw e;
      });
    });
  }

  Future<void> _createNewSegment(String channelId, Duration maxDuration) async {
    await _bufferSink?.close();

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _bufferFile = File('${tempDir.path}/timeshift_${channelId}_$timestamp.ts');
    _bufferSink = _bufferFile!.openWrite();

    _segments.add(_SegmentMetadata(
      file: _bufferFile!,
      startTime: DateTime.now(),
    ));

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

    // Delete all segment files from disk
    for (final segment in _segments) {
      try {
        if (await segment.file.exists()) {
          await segment.file.delete();
        }
      } catch (_) {
        // Best effort delete — continue cleaning up other segments
      }
    }
    _segments.clear();

    // Delete the current buffer file if it exists
    if (_bufferFile != null) {
      try {
        if (await _bufferFile!.exists()) {
          await _bufferFile!.delete();
        }
      } catch (_) {
        // Best effort delete
      }
    }
    _bufferFile = null;

    _currentChannelId = null;
    _isClientBufferActive = false;
  }

  @override
  bool get isClientBufferActive => _isClientBufferActive;

  @override
  Future<File?> getBufferedStream(String channelId, Duration offset) async {
    if (!_isClientBufferActive || _currentChannelId != channelId) {
      return null;
    }

    if (_segments.isEmpty && _bufferFile != null) {
      return _bufferFile;
    }

    final now = DateTime.now();
    final targetTime = now.subtract(offset);

    for (final segment in _segments) {
      final segmentEndTime = segment.startTime.add(_segmentDuration);
      if (!targetTime.isBefore(segment.startTime) && targetTime.isBefore(segmentEndTime)) {
        return segment.file;
      }
    }

    return _segments.isNotEmpty ? _segments.last.file : _bufferFile;
  }
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

class _SegmentMetadata {
  final File file;
  final DateTime startTime;

  const _SegmentMetadata({required this.file, required this.startTime});
}