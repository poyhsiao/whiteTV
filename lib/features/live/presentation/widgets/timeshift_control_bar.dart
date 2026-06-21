import 'package:flutter/material.dart';

/// Determines the current timeshift mode of the player.
enum TimeshiftMode {
  /// Live broadcast — watching in real time.
  live,

  /// Server-side timeshift — replaying from the service.
  service,

  /// Client-side buffer — caching in progress.
  buffer,
}

class TimeshiftControlBar extends StatelessWidget {
  final Duration position;
  final TimeshiftMode mode;
  final bool isPaused;
  final void Function(Duration) onSeek;
  final VoidCallback onPlayPause;
  final VoidCallback onGoLive;
  final VoidCallback? onRewind;
  final VoidCallback? onFastForward;

  const TimeshiftControlBar({
    super.key,
    required this.position,
    required this.mode,
    this.isPaused = false,
    required this.onSeek,
    required this.onPlayPause,
    required this.onGoLive,
    this.onRewind,
    this.onFastForward,
  });

  String _formatDuration(Duration duration) {
    final isNegative = duration.isNegative;
    final absDuration = duration.abs();
    final minutes = absDuration.inMinutes;
    final seconds = absDuration.inSeconds % 60;
    final formatted =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return isNegative ? '-$formatted' : formatted;
  }

  /// Returns the badge label text for the current mode.
  String _modeBadgeLabel() {
    switch (mode) {
      case TimeshiftMode.live:
        return '直播中';
      case TimeshiftMode.service:
        return '時移 ${_formatDuration(position)}';
      case TimeshiftMode.buffer:
        return '緩存中';
    }
  }

  /// Returns the badge background color for the current mode.
  Color _modeBadgeColor() {
    switch (mode) {
      case TimeshiftMode.live:
        return Colors.red;
      case TimeshiftMode.service:
        return Colors.blue;
      case TimeshiftMode.buffer:
        return Colors.orange;
    }
  }

  /// Whether to show the cloud_download icon (only in buffer mode).
  bool get _showBufferIcon => mode == TimeshiftMode.buffer;

  @override
  Widget build(BuildContext context) {
    final badgeColor = _modeBadgeColor();
    final badgeLabel = _modeBadgeLabel();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rewind button
          IconButton(
            icon: const Icon(Icons.replay, color: Colors.white),
            onPressed: onRewind ??
                () => onSeek(position - const Duration(seconds: 10)),
          ),

          // Play/Pause button
          IconButton(
            icon: Icon(
              isPaused ? Icons.play_arrow : Icons.pause,
              color: Colors.white,
            ),
            onPressed: onPlayPause,
          ),

          // Fast forward button
          IconButton(
            icon: const Icon(Icons.forward_10, color: Colors.white),
            onPressed: onFastForward ??
                () => onSeek(position + const Duration(seconds: 10)),
          ),

          const SizedBox(width: 16),

          // Mode indicator badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_showBufferIcon) ...[
                  const Icon(Icons.cloud_download, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                ],
                Text(
                  badgeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Progress indicator
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: mode == TimeshiftMode.live ? 1.0 : 0.5,
              backgroundColor: Colors.grey[700],
              valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
            ),
          ),

          const SizedBox(width: 16),

          // GO LIVE button
          if (mode != TimeshiftMode.live)
            TextButton(
              onPressed: onGoLive,
              child: const Text(
                'GO LIVE',
                style: TextStyle(color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }
}