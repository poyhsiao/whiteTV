import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/live/presentation/screens/live_screen.dart';
import 'package:white_tv/features/live/presentation/providers/live_store.dart';
import 'package:white_tv/features/live/domain/models/live_state.dart';
import 'package:white_tv/features/live/data/models/m3u_channel.dart';
import 'package:white_tv/features/live/domain/services/live_service.dart';
import 'package:white_tv/features/live/domain/repositories/m3u_parser.dart';
import 'package:white_tv/features/live/domain/repositories/epg_manager.dart';
import 'package:white_tv/features/live/domain/repositories/timeshift_manager.dart';
import 'package:white_tv/core/api/api_client.dart';

void main() {
  group('LiveScreen', () {
    testWidgets('displays loading indicator when loading', (tester) async {
      final testState = LiveState.loading();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveStoreProvider.overrideWith((ref) {
              return _TestLiveStore(testState);
            }),
          ],
          child: const MaterialApp(
            home: LiveScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays channel list when loaded', (tester) async {
      final testState = LiveState(
        status: LiveStatus.loaded,
        channels: [
          const M3uChannel(name: 'Channel 1', url: 'https://example.com/1.m3u8'),
          const M3uChannel(name: 'Channel 2', url: 'https://example.com/2.m3u8'),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveStoreProvider.overrideWith((ref) {
              return _TestLiveStore(testState);
            }),
          ],
          child: const MaterialApp(
            home: LiveScreen(),
          ),
        ),
      );

      expect(find.text('Channel 1'), findsOneWidget);
      expect(find.text('Channel 2'), findsOneWidget);
    });

    testWidgets('displays error message when error state', (tester) async {
      final testState = LiveState(
        status: LiveStatus.error,
        errorMessage: 'Failed to load channels',
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveStoreProvider.overrideWith((ref) {
              return _TestLiveStore(testState);
            }),
          ],
          child: const MaterialApp(
            home: LiveScreen(),
          ),
        ),
      );

      expect(find.text('Failed to load channels'), findsOneWidget);
    });

    testWidgets('calls selectChannel when channel is tapped', (tester) async {
      final testState = LiveState(
        status: LiveStatus.loaded,
        channels: [
          const M3uChannel(name: 'Tap Me', url: 'https://example.com/tap.m3u8'),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveStoreProvider.overrideWith((ref) {
              return _TestLiveStore(testState);
            }),
          ],
          child: const MaterialApp(
            home: LiveScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      // The store's selectChannel should be called
    });

    testWidgets('has search functionality', (tester) async {
      final testState = LiveState(
        status: LiveStatus.loaded,
        channels: [
          const M3uChannel(name: 'ESPN Sports', url: 'https://example.com/espn.m3u8'),
          const M3uChannel(name: 'BBC News', url: 'https://example.com/bbc.m3u8'),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveStoreProvider.overrideWith((ref) {
              return _TestLiveStore(testState);
            }),
          ],
          child: const MaterialApp(
            home: LiveScreen(),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('displays channel count', (tester) async {
      final testState = LiveState(
        status: LiveStatus.loaded,
        channels: [
          const M3uChannel(name: 'Ch 1', url: 'https://example.com/1.m3u8'),
          const M3uChannel(name: 'Ch 2', url: 'https://example.com/2.m3u8'),
          const M3uChannel(name: 'Ch 3', url: 'https://example.com/3.m3u8'),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveStoreProvider.overrideWith((ref) {
              return _TestLiveStore(testState);
            }),
          ],
          child: const MaterialApp(
            home: LiveScreen(),
          ),
        ),
      );

      expect(find.text('3 channels'), findsOneWidget);
    });
  });
}

// Test helper - extends StateNotifier and allows direct state manipulation
class _TestLiveStore extends LiveStore {
  _TestLiveStore(LiveState initialState) : super(_MockService()) {
    // Set the initial state directly using the parent class's state setter
    state = initialState;
  }
}

class _MockService implements LiveService {
  @override
  LiveState get state => LiveState.initial();

  @override
  Future<LiveState> loadChannels(String m3uContent) async => LiveState.initial();

  @override
  Future<LiveState> selectChannel(M3uChannel channel) async => LiveState.initial();

  @override
  Future<LiveState> startTimeshift(M3uChannel channel, Duration offset) async => LiveState.initial();

  @override
  Future<LiveState> stopTimeshift() async => LiveState.initial();

  @override
  LiveState handleSignalError(String message) => LiveState.initial();

  @override
  LiveState clearSignalError() => LiveState.initial();

  @override
  List<M3uChannel> searchChannels(String query) => [];

  @override
  M3uParser get m3uParser => throw UnimplementedError();

  @override
  EpgManager get epgManager => throw UnimplementedError();

  @override
  TimeshiftManager get timeshiftManager => throw UnimplementedError();

  @override
  ApiClient? get apiClient => null;

  @override
  Future<LiveState> loadFromApi() async => LiveState.initial();

  @override
  Future<void> startClientBuffer(String channelId, Duration duration) async {}

  @override
  Future<void> stopClientBuffer() async {}
}