enum SearchCategory {
  all('all'),
  movie('movie'),
  series('series'),
  anime('anime'),
  variety('variety');

  const SearchCategory(this.apiValue);
  final String apiValue;

  String get toApiValue => apiValue;
}

class SearchState {
  final String query;
  final List<int> results;
  final List<String> searchHistory;
  final bool isLoading;
  final String? error;
  final SearchCategory activeCategory;
  final bool isKeyboardMode;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.searchHistory = const [],
    this.isLoading = false,
    this.error,
    this.activeCategory = SearchCategory.all,
    this.isKeyboardMode = false,
  });

  SearchState copyWith({
    String? query,
    List<int>? results,
    List<String>? searchHistory,
    bool? isLoading,
    String? error,
    SearchCategory? activeCategory,
    bool? isKeyboardMode,
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
    );
  }
}