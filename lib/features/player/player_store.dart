import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/features/home/home_store.dart';

/// 播放器 Store

class PlayerState {
  final String? videoId;
  final String? episodeId;
  final VideoSource? source;
  final bool isPlaying;
  final bool isBuffering;
  final Duration currentPosition;
  final Duration duration;
  final double playbackSpeed;
  final String? error;

  const PlayerState({
    this.videoId,
    this.episodeId,
    this.source,
    this.isPlaying = false,
    this.isBuffering = false,
    this.currentPosition = Duration.zero,
    this.duration = Duration.zero,
    this.playbackSpeed = 1.0,
    this.error,
  });

  PlayerState copyWith({
    String? videoId,
    String? episodeId,
    VideoSource? source,
    bool? isPlaying,
    bool? isBuffering,
    Duration? currentPosition,
    Duration? duration,
    double? playbackSpeed,
    String? error,
  }) {
    return PlayerState(
      videoId: videoId ?? this.videoId,
      episodeId: episodeId ?? this.episodeId,
      source: source ?? this.source,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      currentPosition: currentPosition ?? this.currentPosition,
      duration: duration ?? this.duration,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      error: error,
    );
  }
}

class PlayerStore extends StateNotifier<PlayerState> {
  final ApiClient _apiClient;
  Timer? _autoSaveTimer;

  PlayerStore(this._apiClient) : super(const PlayerState());

  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      saveProgress();
    });
  }

  void _stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  Future<void> setVideo(String videoId, String episodeId) async {
    try {
      final sources = await _apiClient.getSources(videoId);
      sources.sort((a, b) => a.latency.compareTo(b.latency));
      final fastestSource = sources.firstWhere(
        (s) => s.isAvailable,
        orElse: () => sources.first,
      );

      state = state.copyWith(
        videoId: videoId,
        episodeId: episodeId,
        source: fastestSource,
        currentPosition: Duration.zero,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void play() {
    state = state.copyWith(isPlaying: true);
    _startAutoSave();
  }

  void pause() {
    state = state.copyWith(isPlaying: false);
    _stopAutoSave();
  }

  void seek(Duration position) {
    state = state.copyWith(currentPosition: position);
  }

  void setPlaybackSpeed(double speed) {
    state = state.copyWith(playbackSpeed: speed);
  }

  void updatePosition(Duration position) {
    state = state.copyWith(currentPosition: position);
  }

  void setDuration(Duration duration) {
    state = state.copyWith(duration: duration);
  }

  void setBuffering(bool buffering) {
    state = state.copyWith(isBuffering: buffering);
  }

  /// Save current progress - stub for auto-save functionality
  void saveProgress() {
    // TODO(1.4): Implement auto-save timer to persist position to HistoryService
  }

  @override
  void dispose() {
    _stopAutoSave();
    super.dispose();
  }
}

// Provider
final playerStoreProvider =
    StateNotifierProvider.autoDispose<PlayerStore, PlayerState>((ref) {
      return PlayerStore(ref.watch(apiClientProvider));
    });
