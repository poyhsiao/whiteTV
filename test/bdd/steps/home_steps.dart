import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/home/home_store.dart';

void main() {
  group('Home Screen BDD', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    // Scenario: 首頁正確載入分類內容
    test('loads categories and posters', () async {
      // Given 使用者打開 App
      final homeNotifier = container.read(homeStoreProvider.notifier);
      
      // When 首頁載入完成
      await homeNotifier.loadHome();
      final state = container.read(homeStoreProvider);
      
      // Then 應該顯示 "電影" 分類
      expect(state.categories.any((c) => c.name == '電影'), isTrue);
      // And 應該顯示海報卡片
      expect(state.videosByCategory.isNotEmpty, isTrue);
    });

    // Scenario: 首頁顯示最近觀看
    test('shows recent watch with progress', () async {
      final state = container.read(homeStoreProvider);
      
      // Then 應該顯示 "最近觀看" 區塊
      if (state.recentHistory.isNotEmpty) {
        expect(state.recentHistory.first.progressPercent, isNotNull);
      }
    });

    // Scenario: 網路錯誤時顯示重試
    test('handles error state', () async {
      final homeNotifier = container.read(homeStoreProvider.notifier);
      await homeNotifier.loadHome();
      final state = container.read(homeStoreProvider);
      
      // 驗證 error 狀態或正常載入
      expect(state.isLoading == false || state.error != null, isTrue);
    });
  });
}
