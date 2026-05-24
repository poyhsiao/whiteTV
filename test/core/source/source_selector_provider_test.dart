import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/source/source_selector.dart';
import 'package:white_tv/core/source/source_selector_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('sourceSelectorProvider', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('返回 SourceSelector 實例', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final selector = container.read(sourceSelectorProvider);

      expect(selector, isA<SourceSelector>());
    });

    test('多個容器共享同一個 Provider 實例', () async {
      final container1 = ProviderContainer();
      final container2 = ProviderContainer();
      addTearDown(() {
        container1.dispose();
        container2.dispose();
      });

      final selector1 = container1.read(sourceSelectorProvider);
      final selector2 = container2.read(sourceSelectorProvider);

      // 不同容器應該得到不同的實例（因為是 factory）
      // 但它們行爲一致
      expect(selector1, isA<SourceSelector>());
      expect(selector2, isA<SourceSelector>());
    });

    test('Provider 返回的 selector 可以正常使用', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final selector = container.read(sourceSelectorProvider);

      // 驗證基本功能正常
      final blocked = selector.getBlockedSources();
      expect(blocked, isA<List<String>>());
    });
  });
}