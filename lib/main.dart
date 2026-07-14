import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/settings/services/settings_storage_service.dart';
import 'features/settings/settings_store.dart';
import 'providers/downloads_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  final baseUrl = dotenv.env['LUNATV_API_URL'] ?? 'https://moon2.kimhsiao.com';
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        dioProvider.overrideWithValue(dio),
        settingsStorageServiceProvider.overrideWithValue(
          SettingsStorageService(prefs),
        ),
      ],
      child: WhiteTVApp(
        router: createAppRouter(
          initialLocation: onboardingComplete ? '/' : '/onboarding',
        ),
      ),
    ),
  );
}

class WhiteTVApp extends ConsumerWidget {
  final GoRouter router;

  const WhiteTVApp({super.key, required this.router});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider);
    final theme = settings.themeModeEnum == ThemeMode.light
        ? AppTheme.lightTheme
        : AppTheme.darkTheme;
    return MaterialApp.router(
      title: 'whiteTV',
      theme: theme,
      themeMode: settings.themeModeEnum, // UI_UX.md §13.1
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
