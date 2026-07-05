// Sprint 7.2 — AppRouter smoke test
// Verifies that named GoRoutes pump without throwing and that the destination
// widget actually renders. Uses minimal overrides (favoritesRemoteServiceProvider
// + sharedPreferencesProvider) for routes that touch those. Routes requiring
// full HTTP (player, detail, search) are skipped here — covered by their own
// stores/widget tests.

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/api/dio_provider.dart';
import 'package:white_tv/core/router/app_router.dart';
import 'package:white_tv/features/downloads/presentation/screens/downloads_screen.dart';
import 'package:white_tv/features/favorites/services/favorites_remote_service.dart';
import 'package:white_tv/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:white_tv/features/settings/presentation/screens/remote_guide_screen.dart';
import 'package:white_tv/providers/downloads_providers.dart';

class _SpyFavoritesRemoteService extends FavoritesRemoteService {
  _SpyFavoritesRemoteService() : super(baseUrl: 'http://test.local');
}

/// Minimal ProviderScope: only the providers that ALL routes need at boot,
/// or that some routes touch during their first build (DownloadsScreen,
/// HistoryScreen). Players/Search are not tested here.
Future<ProviderContainer> _container() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      dioProvider.overrideWithValue(Dio()),
      favoritesRemoteServiceProvider.overrideWithValue(
        _SpyFavoritesRemoteService(),
      ),
    ],
  );
}

Future<void> _pumpRoute(WidgetTester tester, String location) async {
  final router = createAppRouter(initialLocation: location);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: await _container(),
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  // Let initial route + any sync overrides settle.
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  group('AppRouter smoke', () {
    testWidgets('navigates to /downloads and renders DownloadsScreen',
        (tester) async {
      await _pumpRoute(tester, '/downloads');
      expect(find.byType(DownloadsScreen), findsOneWidget);
    });

    testWidgets('navigates to /onboarding and renders OnboardingScreen',
        (tester) async {
      await _pumpRoute(tester, '/onboarding');
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('navigates to /remote-guide and renders RemoteGuideScreen',
        (tester) async {
      await _pumpRoute(tester, '/remote-guide');
      expect(find.byType(RemoteGuideScreen), findsOneWidget);
    });
  });
}