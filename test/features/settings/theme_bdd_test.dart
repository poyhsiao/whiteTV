import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/settings/settings_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Theme Switching BDD', () {
    group('SettingsState themeMode mapping', () {
      test('defaults to dark', () {
        const state = SettingsState();
        expect(state.themeMode, 'dark');
        expect(state.themeModeEnum, ThemeMode.dark);
      });

      test('light maps to ThemeMode.light', () {
        final state = const SettingsState().copyWith(themeMode: 'light');
        expect(state.themeModeEnum, ThemeMode.light);
      });

      test('system maps to ThemeMode.system', () {
        final state = const SettingsState().copyWith(themeMode: 'system');
        expect(state.themeModeEnum, ThemeMode.system);
      });

      test('copyWith preserves other fields when updating themeMode', () {
        final state = const SettingsState(
          lunaTVUrl: 'https://test.com',
          autoPlay: false,
          themeMode: 'dark',
        ).copyWith(themeMode: 'light');
        expect(state.themeMode, 'light');
        expect(state.lunaTVUrl, 'https://test.com');
        expect(state.autoPlay, false);
      });
    });
  });
}
