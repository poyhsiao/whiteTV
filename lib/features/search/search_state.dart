import 'package:white_tv/core/api/models.dart';
sealed class SearchCategory {
  const SearchCategory(this.apiValue);
  final String apiValue;

  static const all = _All();
  static const movie = _Movie();
  static const series = _Series();
  static const anime = _Anime();
  static const variety = _Variety();

  static const values = [all, movie, series, anime, variety];
}

final class _All extends SearchCategory {
  const _All() : super('all');
}

final class _Movie extends SearchCategory {
  const _Movie() : super('movie');
}

final class _Series extends SearchCategory {
  const _Series() : super('series');
}

final class _Anime extends SearchCategory {
  const _Anime() : super('anime');
}

final class _Variety extends SearchCategory {
  const _Variety() : super('variety');
}

class SearchState {
  final String query;
  final List<Video> results;
  final List<String> searchHistory;
  final bool isLoading;
  final String? error;
  final SearchCategory activeCategory;
  final bool isKeyboardMode;
  final bool isHistoryOverlayOpen;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.searchHistory = const [],
    this.isLoading = false,
    this.error,
    this.activeCategory = SearchCategory.all,
    this.isKeyboardMode = false,
    this.isHistoryOverlayOpen = false,
  });

  SearchState copyWith({
    String? query,
    List<Video>? results,
    List<String>? searchHistory,
    bool? isLoading,
    String? error,
    SearchCategory? activeCategory,
    bool? isKeyboardMode,
    bool? isHistoryOverlayOpen,
    bool clearError = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      searchHistory: searchHistory ?? this.searchHistory,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      activeCategory: activeCategory ?? this.activeCategory,
      isKeyboardMode: isKeyboardMode ?? this.isKeyboardMode,
      isHistoryOverlayOpen: isHistoryOverlayOpen ?? this.isHistoryOverlayOpen,
    );
  }
}