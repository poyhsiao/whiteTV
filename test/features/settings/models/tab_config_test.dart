import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/settings/models/tab_config.dart';

void main() {
  group('TabConfig', () {
    test('constructs with required fields and defaults visibility/order', () {
      const tab = TabConfig(id: 'home', label: '首頁');

      expect(tab.id, 'home');
      expect(tab.label, '首頁');
      expect(tab.isVisible, isTrue);
      expect(tab.order, 0);
    });

    test('copyWith updates only the supplied fields', () {
      const original = TabConfig(
        id: 'home',
        label: '首頁',
        isVisible: true,
        order: 0,
      );

      final hidden = original.copyWith(isVisible: false);

      expect(hidden.id, 'home');
      expect(hidden.label, '首頁');
      expect(hidden.isVisible, isFalse);
      expect(hidden.order, 0);
    });

    test('copyWith preserves unspecified fields', () {
      const original = TabConfig(
        id: 'favorites',
        label: '收藏',
        isVisible: false,
        order: 4,
      );

      final renamed = original.copyWith(label: '我的最愛');

      expect(renamed.id, 'favorites');
      expect(renamed.label, '我的最愛');
      expect(renamed.isVisible, isFalse);
      expect(renamed.order, 4);
    });

    test('equality compares all four fields', () {
      const a = TabConfig(id: 'home', label: 'Home', order: 0);
      const b = TabConfig(id: 'home', label: 'Home', order: 0);
      const c = TabConfig(id: 'home', label: 'Home', order: 1);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('toString contains all field values', () {
      const tab = TabConfig(
        id: 'home',
        label: '首頁',
        isVisible: false,
        order: 2,
      );

      expect(
        tab.toString(),
        'TabConfig(id: home, label: 首頁, isVisible: false, order: 2)',
      );
    });
  });

  group('defaultTabs', () {
    test('contains exactly six tabs in expected order', () {
      expect(defaultTabs.length, 6);
      expect(defaultTabs.map((t) => t.id).toList(), [
        'home',
        'categories',
        'live',
        'search',
        'favorites',
        'settings',
      ]);
    });

    test('orders are 0..5 and all tabs are visible by default', () {
      for (var i = 0; i < defaultTabs.length; i++) {
        expect(defaultTabs[i].order, i);
        expect(defaultTabs[i].isVisible, isTrue);
      }
    });

    test('every tab has a non-empty id and label', () {
      for (final tab in defaultTabs) {
        expect(tab.id, isNotEmpty);
        expect(tab.label, isNotEmpty);
      }
    });
  });
}
