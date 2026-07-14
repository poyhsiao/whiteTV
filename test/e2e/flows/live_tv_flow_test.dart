import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/main.dart';
import 'package:white_tv/core/router/app_router.dart';
import 'package:white_tv/features/live/presentation/providers/live_store.dart';
import 'package:white_tv/features/live/domain/services/live_service.dart';
import 'package:white_tv/features/live/domain/repositories/m3u_parser.dart';
import 'package:white_tv/features/live/domain/repositories/epg_manager.dart';
import 'package:white_tv/features/live/domain/repositories/timeshift_manager.dart';
import 'package:white_tv/features/live/domain/repositories/timeshift_manager_fallbacks.dart';
import 'package:white_tv/providers/downloads_providers.dart';
import 'package:white_tv/features/settings/services/settings_storage_service.dart';
import 'package:white_tv/features/settings/settings_store.dart';
import '../e2e_test_helpers.dart';

class _MockTimeshiftManager with TimeshiftManagerFallbacks implements TimeshiftManager {
  @override
  Future<TimeshiftController> startTimeshift({required String channelId, required String streamUrl}) async {
    return TimeshiftController(channelId: channelId, streamUrl: streamUrl, startTime: DateTime.now());
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Live TV Flow E2E', () {
    testWidgets('User can navigate to live TV', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      setupE2EPluginMocks();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            dioProvider.overrideWithValue(Dio()),
            settingsStorageServiceProvider.overrideWithValue(
              SettingsStorageService(prefs),
            ),
            liveStoreProvider.overrideWith((ref) {
              final m3uParser = M3uParserImpl();
              final epgManager = EpgManagerImpl();
              final timeshiftManager = _MockTimeshiftManager();
              final service = LiveService(
                m3uParser: m3uParser,
                epgManager: epgManager,
                timeshiftManager: timeshiftManager,
              );
              return LiveStore(service);
            }),
          ],
          child: WhiteTVApp(
            router: createAppRouter(initialLocation: '/live'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - App renders
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
