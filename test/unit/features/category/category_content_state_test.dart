import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/category/category_constants.dart';
import 'package:white_tv/features/category/category_content_state.dart';

void main() {
  group('CategoryContentState', () {
    test('initial state has correct defaults', () {
      const state = CategoryContentState(categoryId: 'movie');
      expect(state.categoryId, 'movie');
      expect(state.subCategory, isNull);
      expect(state.region, isNull);
      expect(state.year, isNull);
      expect(state.sortOption, SortOption.recentUpdate);
      expect(state.videos, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('copyWith updates fields correctly', () {
      const state = CategoryContentState(categoryId: 'movie');
      final updated = state.copyWith(
        subCategory: 'action',
        region: 'hk',
        year: '2024',
        sortOption: SortOption.rating,
        isLoading: true,
      );
      expect(updated.subCategory, 'action');
      expect(updated.region, 'hk');
      expect(updated.year, '2024');
      expect(updated.sortOption, SortOption.rating);
      expect(updated.isLoading, true);
    });

    test('copyWith clears error with clearError flag', () {
      final state = CategoryContentState(
        categoryId: 'movie',
        error: 'Something went wrong',
      );
      final cleared = state.copyWith(clearError: true);
      expect(cleared.error, isNull);
      expect(cleared.isLoading, false);
    });

    test('equality works correctly', () {
      const a = CategoryContentState(categoryId: 'movie');
      const b = CategoryContentState(categoryId: 'movie');
      const c = CategoryContentState(categoryId: 'drama');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('CategoryConstants', () {
    test('subCategories contains expected values for movie', () {
      const subs = CategoryConstants.subCategories;
      expect(subs, contains('action'));
      expect(subs, contains('comedy'));
      expect(subs, contains('sci_fi'));
      expect(subs, contains('romance'));
    });

    test('regions contains expected values', () {
      const regions = CategoryConstants.regions;
      expect(regions, contains('all'));
      expect(regions, contains('cn'));
      expect(regions, contains('hk'));
      expect(regions, contains('tw'));
    });

    test('years contains expected values', () {
      const years = CategoryConstants.years;
      expect(years, contains('all'));
      expect(years, contains('2024'));
      expect(years, contains('2023'));
    });

    test('sortOptions contains all options', () {
      const options = CategoryConstants.sortOptions;
      expect(options.length, 5);
      expect(options, contains(SortOption.recentUpdate));
      expect(options, contains(SortOption.rating));
      expect(options, contains(SortOption.popularity));
      expect(options, contains(SortOption.recentAdded));
      expect(options, contains(SortOption.alphabetical));
    });

    test('labelOf returns correct display labels', () {
      expect(CategoryConstants.subCategoryLabel('action'), '動作');
      expect(CategoryConstants.subCategoryLabel('comedy'), '喜劇');
      expect(CategoryConstants.regionLabel('hk'), '香港');
      expect(CategoryConstants.regionLabel('cn'), '大陸');
      expect(CategoryConstants.regionLabel('all'), '全部');
      expect(CategoryConstants.yearLabel('2024'), '2024');
      expect(CategoryConstants.yearLabel('all'), '全部');
    });

    test('SortOption extension provides correct labels', () {
      expect(SortOption.recentUpdate.label, '最近更新');
      expect(SortOption.rating.label, '評分');
      expect(SortOption.popularity.label, '播放量');
      expect(SortOption.recentAdded.label, '最近添加');
      expect(SortOption.alphabetical.label, '字母');
    });
  });
}
