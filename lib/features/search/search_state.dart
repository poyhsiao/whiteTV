import "package:white_tv/core/api/models.dart";
enum SearchCategory {
  all('all'),
  movie('movie'),
  series('series'),
  anime('anime'),
  variety('variety');

  const SearchCategory(this.apiValue);
  final String apiValue;
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