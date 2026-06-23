import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/core/source/source_selector.dart';
import 'package:white_tv/core/source/source_selector_provider.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/history/services/history_service.dart';
import 'package:white_tv/features/home/home_store.dart';
import 'package:white_tv/features/player/services/download_service.dart';

/// 播放器 Store

enum FailureReason { timeout, error }

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
  final int autoSwitchCount; // 記錄自動切換次數
  final bool controlsVisible;
  final double volume;
  final bool isMuted;
  final bool isFullscreen;
  final int currentEpisode;
  final int totalEpisodes;
  final List<VideoSource> availableSources;
  final VideoSource? currentSource;

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
    this.autoSwitchCount = 0,
    this.controlsVisible = true,
    this.volume = 1.0,
    this.isMuted = false,
    this.isFullscreen = false,
    this.currentEpisode = 1,
    this.totalEpisodes = 1,
    this.availableSources = const [],
    this.currentSource,
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
    int? autoSwitchCount,
    bool? controlsVisible,
    double? volume,
    bool? isMuted,
    bool? isFullscreen,
    int? currentEpisode,
    int? totalEpisodes,
    List<VideoSource>? availableSources,
    VideoSource? currentSource,
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
      autoSwitchCount: autoSwitchCount ?? this.autoSwitchCount,
      controlsVisible: controlsVisible ?? this.controlsVisible,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      currentEpisode: currentEpisode ?? this.currentEpisode,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
      availableSources: availableSources ?? this.availableSources,
      currentSource: currentSource ?? this.currentSource,
    );
  }
}

class PlayerStore extends StateNotifier<PlayerState> {
  final ApiClient _apiClient;
  final HistoryService? _historyService;
  final DownloadService? _downloadService;
  final SourceSelector _sourceSelector;
  Timer? _autoSaveTimer;
  Timer? _bufferingTimer;
  List<VideoSource> _lastKnownSources = [];

  static const Duration bufferingTimeout = Duration(seconds: 10);

  PlayerStore(
    this._apiClient,
    this._sourceSelector, [
    this._historyService,
    this._downloadService,
  ]) : super(const PlayerState());

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

  /// YouTube 影片播放
  ///
  /// [video] - YoutubeVideo (unified model)
  Future<void> playYoutubeVideo(YoutubeVideo video) async {
    await setVideo(
      video.id,
      video.id,
      title: video.title,
      thumbnail: video.thumbnail ?? video.thumbnailUrl,
      sources: [VideoSource(id: 'youtube', url: video.url ?? '', name: 'YouTube')],
      autoSelectSource: false,
    );
  }

  Future<void> setVideo(
    String videoId,
    String episodeId, {
    String? title,
    String? thumbnail,
    List<VideoSource>? sources,
    bool autoSelectSource = true,
  }) async {
    try {
      // Check local cache first (skip for YouTube - no local playback)
      if (sources == null && _downloadService != null) {
        final isDownloaded = await _downloadService.isDownloaded(videoId);
        if (isDownloaded) {
          final localPath = await _downloadService.getLocalPath(videoId);
          if (localPath != null) {
            state = state.copyWith(
              videoId: videoId,
              episodeId: episodeId,
              source: VideoSource(
                id: 'local_$videoId',
                url: 'file://$localPath',
                name: 'local',
              ),
              currentPosition: Duration.zero,
              error: null,
              autoSwitchCount: 0,
            );
            return;
          }
        }
      }

      // Use provided sources (YouTube) or fetch from API
      final videoSources = sources ?? await _apiClient.getSources(videoId);
      _lastKnownSources = videoSources;

      // Auto-select fastest source if enabled
      final selectedSource = autoSelectSource
          ? await _sourceSelector.selectSource(videoSources, videoId)
          : videoSources.first;

      state = state.copyWith(
        videoId: videoId,
        episodeId: episodeId,
        source: selectedSource,
        currentPosition: Duration.zero,
        error: null,
        autoSwitchCount: 0,
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
    _bufferingTimer?.cancel();

    if (buffering) {
      _bufferingTimer = Timer(bufferingTimeout, () {
        _onBufferingTimeout();
      });
    }

    state = state.copyWith(isBuffering: buffering);
  }

  void _onBufferingTimeout() {
    if (!state.isPlaying || state.source == null) return;
    _triggerAutoSwitch(FailureReason.timeout);
  }

  Future<void> _triggerAutoSwitch(FailureReason reason) async {
    if (_lastKnownSources.isEmpty) return;

    final nextSource = await switchToNextSource(_lastKnownSources);
    if (nextSource != null) {
      play();
    }
  }

  /// 播放錯誤回調
  void onPlaybackError(PlaybackError error) {
    if (state.autoSwitchCount >= SourceSelector.maxAutoSwitch) {
      state = state.copyWith(error: '播放失敗，已嘗試所有來源');
      return;
    }

    recordSourceResult(isSuccess: false);
    _triggerAutoSwitch(
      error.isTimeout ? FailureReason.timeout : FailureReason.error,
    );
  }

  /// 播放失敗時自動切換來源
  /// 返回是否成功切換，null 表示無需切換或無法切換
  Future<VideoSource?> switchToNextSource(List<VideoSource> allSources) async {
    final currentSource = state.source;
    if (currentSource == null) return null;

    // 檢查是否超過最大自動切換次數
    if (state.autoSwitchCount >= SourceSelector.maxAutoSwitch) {
      return null; // 超過限制，需要用戶手動選擇
    }

    // 過濾當前來源
    final otherSources = allSources
        .where((s) => s.id != currentSource.id)
        .toList();
    if (otherSources.isEmpty) return null;

    // 選擇下一個最快來源
    otherSources.sort((a, b) => a.latency.compareTo(b.latency));
    final nextSource = otherSources.firstWhere(
      (s) => s.isAvailable,
      orElse: () => otherSources.first,
    );

    // 記錄當前來源失敗
    _sourceSelector.recordResult(
      currentSource.id,
      isSuccess: false,
      latency: 0,
    );

    // 更新狀態
    state = state.copyWith(
      source: nextSource,
      autoSwitchCount: state.autoSwitchCount + 1,
      error: null,
    );

    return nextSource;
  }

  /// 記錄播放結果到 SourceSelector
  void recordSourceResult({required bool isSuccess, int latency = 0}) {
    final currentSource = state.source;
    if (currentSource != null) {
      _sourceSelector.recordResult(
        currentSource.id,
        isSuccess: isSuccess,
        latency: latency,
      );
    }
  }

  // === Player Controls State Methods ===

  void setControlsVisible(bool visible) {
    state = state.copyWith(controlsVisible: visible);
  }

  void setVolume(double volume) {
    state = state.copyWith(volume: volume.clamp(0.0, 1.0));
  }

  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted);
  }

  void toggleFullscreen() {
    state = state.copyWith(isFullscreen: !state.isFullscreen);
  }

  void setCurrentEpisode(int episode) {
    state = state.copyWith(currentEpisode: episode);
  }

  void setTotalEpisodes(int total) {
    state = state.copyWith(totalEpisodes: total);
  }

  void setAvailableSources(List<VideoSource> sources) {
    state = state.copyWith(availableSources: sources);
  }

  void setCurrentSource(VideoSource source) {
    state = state.copyWith(currentSource: source);
  }

  void nextEpisode() {
    if (state.currentEpisode < state.totalEpisodes) {
      state = state.copyWith(currentEpisode: state.currentEpisode + 1);
    }
  }

  void previousEpisode() {
    if (state.currentEpisode > 1) {
      state = state.copyWith(currentEpisode: state.currentEpisode - 1);
    }
  }

  /// Save current progress - persists position to HistoryService
  void saveProgress() {
    if (_historyService == null || state.videoId == null) return;

    final record = PlayHistory(
      key: '${state.videoId}_${state.episodeId}',
      videoId: state.videoId!,
      title: '', // Will be filled by HistoryService or from state
      sourceName: state.source?.name ?? 'unknown',
      playTime: state.currentPosition.inSeconds,
      totalTime: state.duration.inSeconds,
      lastPosition: state.currentPosition,
      lastWatched: DateTime.now(),
      saveTime: DateTime.now(),
      type: 'movie',
    );

    _historyService.addRecord(record);
  }

  @override
  void dispose() {
    _stopAutoSave();
    super.dispose();
  }
}

// Provider - 注入 SourceSelector
final playerStoreProvider =
    StateNotifierProvider.autoDispose<PlayerStore, PlayerState>((ref) {
      return PlayerStore(
        ref.watch(apiClientProvider),
        ref.watch(sourceSelectorProvider),
      );
    });
