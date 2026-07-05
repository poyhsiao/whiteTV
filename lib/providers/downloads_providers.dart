import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/api/dio_provider.dart';
import 'package:white_tv/features/history/services/history_local_service.dart';
import 'package:white_tv/features/player/services/download_service.dart';

// Re-export so existing callers using `import '...downloads_providers.dart'`
// continue to find dioProvider. Canonical location: lib/core/api/dio_provider.dart
// (Sprint 7.1).
export 'package:white_tv/core/api/dio_provider.dart' show dioProvider;

/// Base providers for download feature dependencies

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  );
});

final historyLocalServiceProvider = Provider<HistoryLocalService>((ref) {
  return HistoryLocalService(ref.read(sharedPreferencesProvider));
});

final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService(
    ref.read(dioProvider),
    ref.read(historyLocalServiceProvider),
  );
});