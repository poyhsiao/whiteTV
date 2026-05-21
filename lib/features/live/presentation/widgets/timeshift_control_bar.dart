import 'package:flutter/material.dart';

class TimeshiftControlBar extends StatelessWidget {
  final Duration position;
  final bool isLive;
  final bool isPaused;
  final void Function(Duration) onSeek;
  final VoidCallback onPlayPause;
  final VoidCallback onGoLive;
  final VoidCallback? onRewind;
  final VoidCallback? onFastForward;

  const TimeshiftControlBar({
    super.key,
    required this.position,
    required this.isLive,
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
    final formatted = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return isNegative ? '-$formatted' : formatted;
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: onRewind ?? () => onSeek(position - const Duration(seconds: 10)),
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
            onPressed: onFastForward ?? () => onSeek(position + const Duration(seconds: 10)),
          ),

          const SizedBox(width: 16),

          // Position indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isLive ? Colors.red : Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isLive ? 'LIVE' : _formatDuration(position),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Progress indicator
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: isLive ? 1.0 : 0.5,
              backgroundColor: Colors.grey[700],
              valueColor: AlwaysStoppedAnimation<Color>(
                isLive ? Colors.red : Colors.blue,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // GO LIVE button
          if (!isLive)
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