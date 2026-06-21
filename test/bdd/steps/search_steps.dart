import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/search/search_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Search BDD', () {
    test('initial SearchState has empty query and results', () {
      const state = SearchState();
      expect(state.query, isEmpty);
      expect(state.results, isEmpty);
      expect(state.searchHistory, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.activeCategory, equals(SearchCategory.all));
    });

    test('SearchCategory has expected values', () {
      expect(SearchCategory.values.length, equals(5));
      expect(SearchCategory.all.apiValue, equals('all'));
      expect(SearchCategory.movie.apiValue, equals('movie'));
    });

    test('SearchState copyWith preserves and updates', () {
      const state = SearchState(query: 'test');
      final updated = state.copyWith(isLoading: true);
      expect(updated.query, equals('test'));
      expect(updated.isLoading, isTrue);
    });

    test('SearchState copyWith clears error', () {
      const state = SearchState(error: 'Network error');
      final cleared = state.copyWith(clearError: true);
      expect(cleared.error, isNull);
    });
  });
}
