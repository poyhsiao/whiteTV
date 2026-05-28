import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/live/presentation/screens/live_player_screen.dart';
import 'package:white_tv/features/live/presentation/providers/live_store.dart';
import 'package:white_tv/features/live/domain/models/live_state.dart';
import 'package:white_tv/features/live/data/models/m3u_channel.dart';
import 'package:white_tv/features/live/domain/services/live_service.dart';
import 'package:white_tv/features/live/domain/repositories/m3u_parser.dart';
import 'package:white_tv/features/live/domain/repositories/epg_manager.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/features/live/domain/repositories/timeshift_manager.dart';

void main() {
  group('LivePlayerScreen', () {
    testWidgets('displays channel name when playing', (tester) async {
      final state = LiveState(
        status: LiveStatus.loaded,
        channels: [
          const M3uChannel(name: 'Test Channel', url: 'https://example.com/test.m3u8'),
        ],
        currentChannel: const M3uChannel(name: 'Test Channel', url: 'https://example.com/test.m3u8'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveStoreProvider.overrideWith((ref) => _FakeLiveStore(state)),
          ],
          child: const MaterialApp(
            home: LivePlayerScreen(),
          ),
        ),
      );

      expect(find.text('Test Channel'), findsOneWidget);
    });

    testWidgets('shows timeshift controls when in timeshift mode', (tester) async {
      final state = LiveState(
        status: LiveStatus.timeshift,
        channels: [
          const M3uChannel(name: 'Test Channel', url: 'https://example.com/test.m3u8'),
        ],
        currentChannel: const M3uChannel(name: 'Test Channel', url: 'https://example.com/test.m3u8'),
        timeshiftPosition: const Duration(minutes: -10),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveStoreProvider.overrideWith((ref) => _FakeLiveStore(state)),
          ],
          child: const MaterialApp(
            home: LivePlayerScreen(),
          ),
        ),
      );

      expect(find.byIcon(Icons.replay), findsOneWidget);
    });

    testWidgets('shows signal error overlay when isSignalError is true', (tester) async {
      final state = LiveState(
        status: LiveStatus.loaded,
        isSignalError: true,
        errorMessage: 'Signal lost',
        channels: [
          const M3uChannel(name: 'Test Channel', url: 'https://example.com/test.m3u8'),
        ],
        currentChannel: const M3uChannel(name: 'Test Channel', url: 'https://example.com/test.m3u8'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveStoreProvider.overrideWith((ref) => _FakeLiveStore(state)),
          ],
          child: const MaterialApp(
            home: LivePlayerScreen(),
          ),
        ),
      );

      expect(find.text('Signal lost'), findsOneWidget);
    });

    testWidgets('has play/pause button', (tester) async {
      final state = LiveState(
        status: LiveStatus.loaded,
        channels: [
          const M3uChannel(name: 'Test Channel', url: 'https://example.com/test.m3u8'),
        ],
        currentChannel: const M3uChannel(name: 'Test Channel', url: 'https://example.com/test.m3u8'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveStoreProvider.overrideWith((ref) => _FakeLiveStore(state)),
          ],
          child: const MaterialApp(
            home: LivePlayerScreen(),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });
  });
}

class _FakeLiveStore extends LiveStore {
  _FakeLiveStore(LiveState initialState) : super(_FakeService()) {
    state = initialState;
  }
}

class _FakeService implements LiveService {
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
}