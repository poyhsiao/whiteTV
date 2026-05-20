import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/settings/services/settings_storage_service.dart';

class SettingsState {
  final String? lunaTVUrl;
  final String themeMode;
  final bool autoPlay;
  final String defaultQuality;
  final bool autoSelectSource;
  final List<String> blockedSources;
  final Map<String, bool> homeBlocks;
  final List<String> tabOrder;

  const SettingsState({
    this.lunaTVUrl,
    this.themeMode = 'dark',
    this.autoPlay = true,
    this.defaultQuality = 'auto',
    this.autoSelectSource = true,
    this.blockedSources = const [],
    this.homeBlocks = const {},
    this.tabOrder = const [],
  });

  SettingsState copyWith({
    String? lunaTVUrl,
    String? themeMode,
    bool? autoPlay,
    String? defaultQuality,
    bool? autoSelectSource,
    List<String>? blockedSources,
    Map<String, bool>? homeBlocks,
    List<String>? tabOrder,
  }) {
    return SettingsState(
      lunaTVUrl: lunaTVUrl ?? this.lunaTVUrl,
      themeMode: themeMode ?? this.themeMode,
      autoPlay: autoPlay ?? this.autoPlay,
      defaultQuality: defaultQuality ?? this.defaultQuality,
      autoSelectSource: autoSelectSource ?? this.autoSelectSource,
      blockedSources: blockedSources ?? this.blockedSources,
      homeBlocks: homeBlocks ?? this.homeBlocks,
      tabOrder: tabOrder ?? this.tabOrder,
    );
  }

  ThemeMode get themeModeEnum {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }
}

class SettingsStore extends StateNotifier<SettingsState> {
  final SettingsStorageService _storage;

  SettingsStore(this._storage) : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final lunaTVUrl = await _storage.getLunaTVUrl();
    final themeMode = await _storage.getThemeMode();
    final autoPlay = await _storage.getAutoPlay();
    final defaultQuality = await _storage.getDefaultQuality();
    final autoSelectSource = await _storage.getAutoSelectSource();
    final blockedSources = await _storage.getBlockedSources();
    final homeBlocks = await _storage.getHomeBlocks();
    final tabOrder = await _storage.getTabOrder();

    state = state.copyWith(
      lunaTVUrl: lunaTVUrl,
      themeMode: themeMode,
      autoPlay: autoPlay,
      defaultQuality: defaultQuality,
      autoSelectSource: autoSelectSource,
      blockedSources: blockedSources,
      homeBlocks: homeBlocks,
      tabOrder: tabOrder,
    );
  }

  Future<void> updateLunaTVUrl(String url) async {
    await _storage.saveLunaTVUrl(url);
    state = state.copyWith(lunaTVUrl: url);
  }

  Future<void> updateThemeMode(String mode) async {
    await _storage.saveThemeMode(mode);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> updateAutoPlay(bool enabled) async {
    await _storage.saveAutoPlay(enabled);
    state = state.copyWith(autoPlay: enabled);
  }

  Future<void> updateDefaultQuality(String quality) async {
    await _storage.saveDefaultQuality(quality);
    state = state.copyWith(defaultQuality: quality);
  }

  Future<void> updateAutoSelectSource(bool enabled) async {
    await _storage.saveAutoSelectSource(enabled);
    state = state.copyWith(autoSelectSource: enabled);
  }

  Future<void> toggleBlockedSource(String source) async {
    final blocked = List<String>.from(state.blockedSources);
    if (blocked.contains(source)) {
      blocked.remove(source);
    } else {
      blocked.add(source);
    }
    await _storage.saveBlockedSources(blocked);
    state = state.copyWith(blockedSources: blocked);
  }

  Future<void> updateHomeBlocks(Map<String, bool> blocks) async {
    await _storage.saveHomeBlocks(blocks);
    state = state.copyWith(homeBlocks: blocks);
  }

  Future<void> updateTabOrder(List<String> order) async {
    await _storage.saveTabOrder(order);
    state = state.copyWith(tabOrder: order);
  }
}

// Provider - Must be overridden in ProviderScope
final settingsStorageServiceProvider = Provider<SettingsStorageService>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final settingsStoreProvider =
    StateNotifierProvider<SettingsStore, SettingsState>((ref) {
      final storage = ref.watch(settingsStorageServiceProvider);
      return SettingsStore(storage);
    });
