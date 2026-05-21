import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/live/domain/models/live_state.dart';
import 'package:white_tv/features/live/presentation/providers/live_store.dart';
import 'package:white_tv/features/live/presentation/widgets/signal_error_widget.dart';
import 'package:white_tv/features/live/presentation/widgets/timeshift_control_bar.dart';

class LivePlayerScreen extends ConsumerWidget {
  const LivePlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(liveStoreProvider);
    final notifier = ref.read(liveStoreProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video player area (placeholder)
          Center(
            child: state.currentChannel != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.live_tv, color: Colors.white54, size: 80),
                      const SizedBox(height: 16),
                      Text(
                        state.currentChannel!.name,
                        style: const TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      if (state.status == LiveStatus.timeshift) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Replay: ${_formatDuration(state.timeshiftPosition ?? Duration.zero)}',
                          style: const TextStyle(color: Colors.orange, fontSize: 16),
                        ),
                      ],
                    ],
                  )
                : const Text(
                    'No channel selected',
                    style: TextStyle(color: Colors.white),
                  ),
          ),

          // Signal error overlay
          if (state.isSignalError)
            SignalErrorWidget(
              message: state.errorMessage ?? 'Signal lost',
              onRetry: () => notifier.clearSignalError(),
            ),

          // Controls overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildControls(context, ref, state),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, WidgetRef ref, LiveState state) {
    final notifier = ref.read(liveStoreProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Timeshift control bar (if in timeshift mode)
          if (state.status == LiveStatus.timeshift)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TimeshiftControlBar(
                position: state.timeshiftPosition ?? Duration.zero,
                isLive: state.timeshiftPosition == null || state.timeshiftPosition!.inSeconds >= 0,
                onSeek: (pos) => notifier.seekTimeshift(pos),
                onPlayPause: () => notifier.togglePlayPause(),
                onGoLive: () => notifier.stopTimeshift(),
              ),
            ),

          // Play/pause and channel navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white, size: 32),
                onPressed: () => notifier.previousChannel(),
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: const Icon(Icons.play_arrow, color: Colors.white, size: 48),
                onPressed: () {
                  if (state.status == LiveStatus.timeshift) {
                    notifier.stopTimeshift();
                  } else {
                    notifier.startTimeshift(const Duration(minutes: -1));
                  }
                },
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white, size: 32),
                onPressed: () => notifier.nextChannel(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final isNegative = duration.isNegative;
    final absDuration = duration.abs();
    final minutes = absDuration.inMinutes;
    final seconds = absDuration.inSeconds % 60;
    final formatted = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return isNegative ? '-$formatted' : formatted;
  }
}