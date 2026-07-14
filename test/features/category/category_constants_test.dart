import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/category/category_constants.dart';

void main() {
  group('SortOption', () {
    test('exposes the five expected variants', () {
      expect(SortOption.values.length, 5);
      expect(
        SortOption.values.toSet(),
        equals({
          SortOption.recentUpdate,
          SortOption.rating,
          SortOption.popularity,
          SortOption.recentAdded,
          SortOption.alphabetical,
        }),
      );
    });

    test('returns the correct Chinese label for each variant', () {
      expect(SortOption.recentUpdate.label, '最近更新');
      expect(SortOption.rating.label, '評分');
      expect(SortOption.popularity.label, '播放量');
      expect(SortOption.recentAdded.label, '最近添加');
      expect(SortOption.alphabetical.label, '字母');
    });
  });

  group('CategoryConstants constants', () {
    test('subCategories starts with all and includes the 11 known keys', () {
      expect(CategoryConstants.subCategories.first, 'all');
      expect(CategoryConstants.subCategories, contains('action'));
      expect(CategoryConstants.subCategories, contains('documentary'));
      expect(CategoryConstants.subCategories.length, 11);
    });

    test('regions starts with all and lists every supported region', () {
      expect(CategoryConstants.regions.first, 'all');
      expect(CategoryConstants.regions, contains('cn'));
      expect(CategoryConstants.regions, contains('us'));
      expect(CategoryConstants.regions, contains('eu'));
    });

    test('years ranges from all down to earlier', () {
      expect(CategoryConstants.years.first, 'all');
      expect(CategoryConstants.years, contains('earlier'));
      expect(CategoryConstants.years, contains('2024'));
    });

    test('sortOptions mirrors SortOption.values', () {
      expect(CategoryConstants.sortOptions, equals(SortOption.values));
    });
  });

  group('CategoryConstants.subCategoryLabel', () {
    test('returns Chinese label for known sub-categories', () {
      expect(CategoryConstants.subCategoryLabel('all'), '全部');
      expect(CategoryConstants.subCategoryLabel('action'), '動作');
      expect(CategoryConstants.subCategoryLabel('comedy'), '喜劇');
      expect(CategoryConstants.subCategoryLabel('sci_fi'), '科幻');
      expect(CategoryConstants.subCategoryLabel('romance'), '愛情');
      expect(CategoryConstants.subCategoryLabel('thriller'), '懸疑');
      expect(CategoryConstants.subCategoryLabel('war'), '戰爭');
      expect(CategoryConstants.subCategoryLabel('horror'), '恐怖');
      expect(CategoryConstants.subCategoryLabel('animation'), '動畫');
      expect(CategoryConstants.subCategoryLabel('drama'), '劇情');
      expect(CategoryConstants.subCategoryLabel('documentary'), '紀錄片');
    });

    test('returns the original key for unknown sub-categories', () {
      expect(CategoryConstants.subCategoryLabel('unknown'), 'unknown');
      expect(CategoryConstants.subCategoryLabel(''), '');
    });
  });

  group('CategoryConstants.regionLabel', () {
    test('returns Chinese label for known regions', () {
      expect(CategoryConstants.regionLabel('all'), '全部');
      expect(CategoryConstants.regionLabel('cn'), '大陸');
      expect(CategoryConstants.regionLabel('hk'), '香港');
      expect(CategoryConstants.regionLabel('tw'), '台灣');
      expect(CategoryConstants.regionLabel('jp'), '日本');
      expect(CategoryConstants.regionLabel('kr'), '韓國');
      expect(CategoryConstants.regionLabel('us'), '美國');
      expect(CategoryConstants.regionLabel('eu'), '歐洲');
    });

    test('returns the original key for unknown regions', () {
      expect(CategoryConstants.regionLabel('xx'), 'xx');
    });
  });

  group('CategoryConstants.yearLabel', () {
    test('returns translated labels for special keys', () {
      expect(CategoryConstants.yearLabel('all'), '全部');
      expect(CategoryConstants.yearLabel('earlier'), '更早期');
    });

    test('returns the original key for year numbers', () {
      expect(CategoryConstants.yearLabel('2024'), '2024');
      expect(CategoryConstants.yearLabel('2020'), '2020');
    });
  });
}
