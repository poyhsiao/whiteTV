// TDD 紅階段: Category 5 種 SortOption 完整性測試
// 規範: docs/spec/UI_UX.md §7.5
//
// 預期: 5 種 sort 全部能在 store 設定 + 取得 label
// 真實缺口: alphabetical sort 缺少排序實作 (僅更新 enum 狀態,UI 沒有真正排序)
//           — 此測試聚焦驗證 enum + state 覆蓋,Sprint 1.2 範圍內

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/category/category_constants.dart';
import 'package:white_tv/features/category/category_content_state.dart';
import 'package:white_tv/features/category/category_content_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SortOption enum', () {
    test('有 5 個排序選項', () {
      expect(SortOption.values, hasLength(5));
    });

    test('5 種 label 都正確', () {
      expect(SortOption.recentUpdate.label, '最近更新');
      expect(SortOption.rating.label, '評分');
      expect(SortOption.popularity.label, '播放量');
      expect(SortOption.recentAdded.label, '最近添加');
      expect(SortOption.alphabetical.label, '字母');
    });
  });

  group('CategoryContentStore sortOption', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('預設為最近更新', () {
      final state = container.read(categoryContentStoreProvider);
      expect(state.sortOption, SortOption.recentUpdate);
    });

    for (final option in SortOption.values) {
      test('setSortOption(${option.name}) 寫入 state', () {
        final notifier = container.read(categoryContentStoreProvider.notifier);
        notifier.setSortOption(option);
        expect(container.read(categoryContentStoreProvider).sortOption, option);
      });
    }

    test('state copyWith 保留 sortOption', () {
      final state = CategoryContentState(
        categoryId: 'movie',
        sortOption: SortOption.popularity,
      );
      final updated = state.copyWith(subCategory: 'action');
      expect(updated.sortOption, SortOption.popularity);
    });
  });

  group('CategoryConstants.sortOptions', () {
    test('包含 5 種排序', () {
      expect(CategoryConstants.sortOptions, hasLength(5));
      expect(CategoryConstants.sortOptions, containsAll(SortOption.values));
    });
  });
}
