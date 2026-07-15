import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/core/source/source_selector.dart';
import 'package:white_tv/core/source/source_selector_provider.dart';
import 'package:white_tv/features/detail/detail_screen.dart';
import 'package:white_tv/features/home/home_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DetailScreen source status badges', () {
    late SourceSelector sourceSelector;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sourceSelector = SourceSelector();
      await sourceSelector.loadBlockedSources();
    });

    testWidgets('shows status emoji for available source', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(MockClient()),
            sourceSelectorProvider.overrideWithValue(sourceSelector),
          ],
          child: const MaterialApp(home: DetailScreen(videoId: 'movie-1')),
        ),
      );
      await tester.pump(const Duration(seconds: 3));

      expect(find.textContaining('🟢'), findsAtLeast(1));
    });

    testWidgets('shows latency in ms', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(MockClient()),
            sourceSelectorProvider.overrideWithValue(SourceSelector()),
          ],
          child: const MaterialApp(home: DetailScreen(videoId: 'movie-1')),
        ),
      );
      await tester.pump(const Duration(seconds: 3));

      expect(find.textContaining('ms'), findsAtLeast(1));
    });
  });
}
