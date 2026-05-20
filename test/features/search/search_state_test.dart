import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/search/search_state.dart';

void main() {
  group('SearchCategory', () {
    test('should have all enum values', () {
      expect(SearchCategory.values.length, 5);
      expect(SearchCategory.all.apiValue, 'all');
      expect(SearchCategory.movie.apiValue, 'movie');
      expect(SearchCategory.series.apiValue, 'series');
      expect(SearchCategory.anime.apiValue, 'anime');
      expect(SearchCategory.variety.apiValue, 'variety');
    });
  });

  group('SearchState', () {
    test('should have correct default values', () {
      const state = SearchState();
      expect(state.query, '');
      expect(state.results, isEmpty);
      expect(state.searchHistory, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.activeCategory, SearchCategory.all);
      expect(state.isKeyboardMode, false);
    });

    test('copyWith creates new instance with updated values', () {
      const state = SearchState();
      final newState = state.copyWith(query: 'test', isLoading: true);
      expect(newState.query, 'test');
      expect(newState.isLoading, true);
      expect(newState.results, isEmpty);
    });

    test('copyWith with clearError clears error', () {
      final state = SearchState(error: 'some error');
      final newState = state.copyWith(clearError: true);
      expect(newState.error, isNull);
    });
  });
}