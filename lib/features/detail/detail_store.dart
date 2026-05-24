import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/core/source/source_selector.dart';
import 'package:white_tv/core/source/source_selector_provider.dart';
import 'package:white_tv/features/home/home_store.dart';

/// 詳情頁 Store

class DetailState {
  final VideoDetail? detail;
  final VideoSource? selectedSource;
  final Episode? selectedEpisode;
  final bool isLoading;
  final String? error;

  const DetailState({
    this.detail,
    this.selectedSource,
    this.selectedEpisode,
    this.isLoading = false,
    this.error,
  });

  DetailState copyWith({
    VideoDetail? detail,
    VideoSource? selectedSource,
    Episode? selectedEpisode,
    bool? isLoading,
    String? error,
  }) {
    return DetailState(
      detail: detail ?? this.detail,
      selectedSource: selectedSource ?? this.selectedSource,
      selectedEpisode: selectedEpisode ?? this.selectedEpisode,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DetailStore extends StateNotifier<DetailState> {
  final ApiClient _apiClient;
  final SourceSelector _sourceSelector;

  DetailStore(this._apiClient, this._sourceSelector) : super(const DetailState());

  Future<void> loadDetail(String videoId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final detail = await _apiClient.getVideoDetail(videoId);

      // 使用 SourceSelector 選擇來源
      final sources = await _apiClient.getSources(videoId);
      final selectedSource = await _sourceSelector.selectSource(sources, videoId);

      final firstEpisode = detail.episodes.isNotEmpty
          ? detail.episodes.first
          : null;

      state = state.copyWith(
        detail: detail,
        selectedSource: selectedSource,
        selectedEpisode: firstEpisode,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectSource(VideoSource source) {
    state = state.copyWith(selectedSource: source);
  }

  void selectEpisode(Episode episode) {
    state = state.copyWith(selectedEpisode: episode);
  }

  /// 記錄播放結果到 SourceSelector
  void recordSourceResult({required bool isSuccess, int latency = 0}) {
    final selected = state.selectedSource;
    if (selected != null) {
      _sourceSelector.recordResult(
        selected.id,
        isSuccess: isSuccess,
        latency: latency,
      );
    }
  }
}

// Provider - 注入 SourceSelector
final detailStoreProvider =
    StateNotifierProvider.autoDispose<DetailStore, DetailState>((ref) {
  return DetailStore(
    ref.watch(apiClientProvider),
    ref.watch(sourceSelectorProvider),
  );
});