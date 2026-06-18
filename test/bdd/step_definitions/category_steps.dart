import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/category/category_content_store.dart';
import 'package:white_tv/features/category/category_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Category BDD', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    // Scenario: CategoryContentState 初始值 (預設 'movie')
    test('initial state defaults to movie category', () {
      final state = container.read(categoryContentStoreProvider);
      expect(state.categoryId, equals('movie'));
      expect(state.videos, isEmpty);
      expect(state.subCategory, isNull);
    });

    // Scenario: 設定分類 ID
    test('setCategoryId updates category', () {
      final notifier = container.read(categoryContentStoreProvider.notifier);
      notifier.setCategoryId('tv');
      expect(container.read(categoryContentStoreProvider).categoryId, equals('tv'));
    });

    // Scenario: 切換二級分類
    test('setSubCategory updates filter', () {
      final notifier = container.read(categoryContentStoreProvider.notifier);
      notifier.setSubCategory('action');
      expect(container.read(categoryContentStoreProvider).subCategory, equals('action'));
    });

    // Scenario: 切換排序方式
    test('setSortOption updates sort', () {
      final notifier = container.read(categoryContentStoreProvider.notifier);
      notifier.setSortOption(SortOption.rating);
      expect(container.read(categoryContentStoreProvider).sortOption, equals(SortOption.rating));
    });

    // Scenario: 設定地區篩選
    test('setRegion updates region', () {
      final notifier = container.read(categoryContentStoreProvider.notifier);
      notifier.setRegion('台灣');
      expect(container.read(categoryContentStoreProvider).region, equals('台灣'));
    });

    // Scenario: 設定年份篩選
    test('setYear updates year', () {
      final notifier = container.read(categoryContentStoreProvider.notifier);
      notifier.setYear('2024');
      expect(container.read(categoryContentStoreProvider).year, equals('2024'));
    });
  });
}
