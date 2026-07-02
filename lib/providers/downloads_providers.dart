import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/features/history/services/history_local_service.dart';
import 'package:white_tv/features/player/services/download_service.dart';

/// Base providers for download feature dependencies

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  );
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 60);
  return dio;
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
