/// Client-side timeshift buffer.
///
/// Manages a rolling buffer of recent video segments on the client device,
/// enabling timeshift playback without server-side support. This serves as
/// a fallback when the backend (LunaTV) does not provide server-side timeshift.
class TimeshiftClientBuffer {
  static const maxBufferDuration = Duration(minutes: 30);

  bool _isActive = false;
  String? _channelId;
  Duration _maxDuration = Duration.zero;
  Duration _bufferedDuration = Duration.zero;

  /// Whether the buffer is currently active for a channel.
  bool get isActive => _isActive;

  /// The channel currently being buffered, or `null` if inactive.
  String? get channelId => _channelId;

  /// The maximum timeshift window allowed for this channel.
  Duration get maxDuration => _maxDuration;

  /// The amount of video data currently held in the buffer.
  Duration get bufferedDuration => _bufferedDuration;

  /// Start buffering for [channelId] with the given [duration] window.
  ///
  /// If already active for another channel, that buffer is stopped first.
  /// The requested [duration] is clamped to [maxBufferDuration].
  Future<void> start(String channelId, Duration duration) async {
    if (channelId.isEmpty) return;

    if (_isActive && _channelId == channelId) return;

    _stopInternal();

    _channelId = channelId;
    _maxDuration = duration > maxBufferDuration ? maxBufferDuration : duration;
    _bufferedDuration = Duration.zero;
    _isActive = true;
  }

  /// Stop buffering and release all buffered data.
  Future<void> stop() async {
    _stopInternal();
  }

  void _stopInternal() {
    _isActive = false;
    _channelId = null;
    _maxDuration = Duration.zero;
    _bufferedDuration = Duration.zero;
  }
}
