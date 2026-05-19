import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/models.dart';
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

  DetailStore(this._apiClient) : super(const DetailState());

  Future<void> loadDetail(String videoId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final detail = await _apiClient.getVideoDetail(videoId);

      final sources = await _apiClient.getSources(videoId);
      sources.sort((a, b) => a.latency.compareTo(b.latency));
      final fastestSource = sources.firstWhere(
        (s) => s.isAvailable,
        orElse: () => sources.first,
      );

      final firstEpisode = detail.episodes.isNotEmpty
          ? detail.episodes.first
          : null;

      state = state.copyWith(
        detail: detail,
        selectedSource: fastestSource,
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
}

// Provider
final detailStoreProvider =
    StateNotifierProvider.autoDispose<DetailStore, DetailState>((ref) {
  return DetailStore(ref.watch(apiClientProvider));
});