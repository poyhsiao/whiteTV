import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/live/presentation/screens/live_player_screen.dart';
import 'package:white_tv/features/live/presentation/providers/live_store.dart';
import 'package:white_tv/features/live/domain/models/live_state.dart';
import 'package:white_tv/features/live/data/models/m3u_channel.dart';
import 'package:white_tv/features/live/domain/services/live_service.dart';
import 'package:mocktail/mocktail.dart';

class MockLiveService extends Mock implements LiveService {}

void main() {
  group('LivePlayerScreen Mute Indicator', () {
    late MockLiveService mockService;
    late LiveStore store;

    setUpAll(() {
      registerFallbackValue(M3uChannel(name: 'fallback', url: 'http://fallback.com'));
    });

    setUp(() {
      mockService = MockLiveService();
      when(() => mockService.loadChannels(any())).thenAnswer((_) async {
        return LiveState.initial().copyWith(
          channels: [
            M3uChannel(name: 'CCTV-1', url: 'http://example.com/1'),
          ],
          status: LiveStatus.loaded,
        );
      });
      store = LiveStore(mockService);
    });

    testWidgets('shows mute indicator when isMuted is true', (tester) async {
      store.mute();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveStoreProvider.overrideWith((ref) => store),
          ],
          child: const MaterialApp(home: LivePlayerScreen()),
        ),
      );

      await tester.pump();
      expect(find.byIcon(Icons.volume_off), findsOneWidget);
      expect(find.text('Muted'), findsOneWidget);
    });

    testWidgets('does not show mute indicator when isMuted is false', (tester) async {
      store.unmute();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveStoreProvider.overrideWith((ref) => store),
          ],
          child: const MaterialApp(home: LivePlayerScreen()),
        ),
      );

      await tester.pump();
      expect(find.byIcon(Icons.volume_off), findsNothing);
    });
  });
}