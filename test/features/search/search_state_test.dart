import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/search/search_state.dart';

void main() {
  group('SearchCategory', () {
    test('has 5 values', () {
      expect(SearchCategory.values.length, 5);
    });

    test('contains all expected values', () {
      expect(SearchCategory.values, contains(SearchCategory.all));
      expect(SearchCategory.values, contains(SearchCategory.movie));
      expect(SearchCategory.values, contains(SearchCategory.series));
      expect(SearchCategory.values, contains(SearchCategory.anime));
      expect(SearchCategory.values, contains(SearchCategory.variety));
    });

    test('toApiValue returns correct string for all', () {
      expect(SearchCategory.all.toApiValue, 'all');
    });

    test('toApiValue returns correct string for movie', () {
      expect(SearchCategory.movie.toApiValue, 'movie');
    });

    test('toApiValue returns correct string for series', () {
      expect(SearchCategory.series.toApiValue, 'series');
    });

    test('toApiValue returns correct string for anime', () {
      expect(SearchCategory.anime.toApiValue, 'anime');
    });

    test('toApiValue returns correct string for variety', () {
      expect(SearchCategory.variety.toApiValue, 'variety');
    });
  });

  group('SearchState', () {
    test('has correct default values', () {
      final state = SearchState();
      expect(state.query, '');
      expect(state.results, isEmpty);
      expect(state.searchHistory, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.activeCategory, SearchCategory.all);
      expect(state.isKeyboardMode, false);
    });

    test('copyWith creates new instance with updated values', () {
      final state = SearchState();
      final updated = state.copyWith(
        query: 'test query',
        isLoading: true,
      );

      expect(updated.query, 'test query');
      expect(updated.isLoading, true);
      expect(updated.results, isEmpty);
      expect(updated.searchHistory, isEmpty);
      expect(updated.error, isNull);
      expect(updated.activeCategory, SearchCategory.all);
      expect(updated.isKeyboardMode, false);
    });

    test('copyWith preserves values when not updated', () {
      final state = SearchState(
        query: 'original',
        results: [1, 2, 3],
        searchHistory: ['a', 'b'],
        isLoading: true,
        error: 'some error',
        activeCategory: SearchCategory.movie,
        isKeyboardMode: true,
      );

      final updated = state.copyWith(query: 'updated');

      expect(updated.query, 'updated');
      expect(updated.results, [1, 2, 3]);
      expect(updated.searchHistory, ['a', 'b']);
      expect(updated.isLoading, true);
      expect(updated.error, 'some error');
      expect(updated.activeCategory, SearchCategory.movie);
      expect(updated.isKeyboardMode, true);
    });

    test('copyWith with clearError clears error', () {
      final state = SearchState(error: 'some error');
      final updated = state.copyWith(clearError: true);

      expect(updated.error, isNull);
    });
  });
}