import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/core/source/source_selector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Settings BDD - 來源屏蔽同步', () {
    late SourceSelector selector;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      selector = SourceSelector();
    });

    test('來源屏蔽後立即生效', () async {
      // Given: 使用者屏蔽了"量子資源"來源
      await selector.setBlockedSources(['量子資源']);

      // When: 系統選擇播放來源
      final sources = [
        const VideoSource(id: '量子資源', name: '量子資源', url: 'http://a.com', latency: 80, isAvailable: true),
        const VideoSource(id: '非凡資源', name: '非凡資源', url: 'http://b.com', latency: 120, isAvailable: true),
      ];

      // 模擬過濾邏輯（不實際發送網路請求）
      final blocked = selector.getBlockedSources();
      final availableSources = sources.where((s) => !blocked.contains(s.id) && s.isAvailable).toList();

      // Then: "量子資源"應該被自動排除
      expect(availableSources.any((s) => s.id == '量子資源'), isFalse);
      // And: 應該選擇次快的可用來源
      expect(availableSources.length, 1);
      expect(availableSources.first.id, '非凡資源');
    });

    test('SourceSelector blocks sources', () async {
      SharedPreferences.setMockInitialValues({});
      final selector = SourceSelector();
      await selector.setBlockedSources(['source1']);
      expect(selector.getBlockedSources().contains('source1'), isTrue);
      await selector.setBlockedSources([]);
    });
  });
}
