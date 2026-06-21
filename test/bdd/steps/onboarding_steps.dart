import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/settings/settings_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding BDD', () {
    // Scenario: SettingsState 預設值
    test('initial SettingsState has default values', () {
      const state = SettingsState();
      expect(state.lunaTVUrl, isNull);
      expect(state.autoPlay, isTrue);
      expect(state.defaultQuality, equals('auto'));
      expect(state.themeMode, equals('dark'));
    });

    // Scenario: 設定 API URL (onboarding 核心步驟)
    test('SettingsState copyWith sets lunaTVUrl', () {
      const state = SettingsState();
      final updated = state.copyWith(lunaTVUrl: 'http://test.com:8080');
      expect(updated.lunaTVUrl, equals('http://test.com:8080'));
    });

    // Scenario: 設定畫質偏好
    test('SettingsState copyWith sets quality', () {
      const state = SettingsState();
      final updated = state.copyWith(defaultQuality: '720p');
      expect(updated.defaultQuality, equals('720p'));
    });

    // Scenario: 設定自動播放
    test('SettingsState copyWith sets autoPlay', () {
      const state = SettingsState();
      final updated = state.copyWith(autoPlay: false);
      expect(updated.autoPlay, isFalse);
    });

    // Scenario: 屏蔽來源
    test('SettingsState copyWith sets blockedSources', () {
      const state = SettingsState();
      final updated = state.copyWith(blockedSources: ['src1', 'src2']);
      expect(updated.blockedSources, contains('src1'));
      expect(updated.blockedSources, contains('src2'));
    });

    // Scenario: 設定主題
    test('SettingsState copyWith sets themeMode', () {
      const state = SettingsState();
      final updated = state.copyWith(themeMode: 'light');
      expect(updated.themeMode, equals('light'));
    });
  });
}
