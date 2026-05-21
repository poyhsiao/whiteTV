import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/live/data/models/m3u_channel.dart';
import 'package:white_tv/features/live/domain/models/live_state.dart';
import 'package:white_tv/features/live/domain/repositories/epg_manager.dart';
import 'package:white_tv/features/live/domain/repositories/m3u_parser.dart';
import 'package:white_tv/features/live/domain/repositories/timeshift_manager.dart';
import 'package:white_tv/features/live/domain/services/live_service.dart';

// Provider definitions
final m3uParserProvider = Provider<M3uParser>((ref) {
  return const M3uParserImpl();
});

final epgManagerProvider = Provider<EpgManager>((ref) {
  return EpgManagerImpl();
});

final timeshiftManagerProvider = Provider<TimeshiftManager>((ref) {
  return TimeshiftManagerImpl();
});

final liveServiceProvider = Provider<LiveService>((ref) {
  return LiveService(
    m3uParser: ref.watch(m3uParserProvider),
    epgManager: ref.watch(epgManagerProvider),
    timeshiftManager: ref.watch(timeshiftManagerProvider),
  );
});

final liveStoreProvider = StateNotifierProvider<LiveStore, LiveState>((ref) {
  return LiveStore(ref.watch(liveServiceProvider));
});

class LiveStore extends StateNotifier<LiveState> {
  final LiveService _service;

  LiveStore(this._service) : super(LiveState.initial());

  Future<void> loadChannels(String m3uContent) async {
    state = state.copyWith(status: LiveStatus.loading);
    state = await _service.loadChannels(m3uContent);
  }

  Future<void> selectChannel(M3uChannel channel) async {
    state = await _service.selectChannel(channel);
  }

  Future<void> startTimeshift(Duration offset) async {
    if (state.currentChannel != null) {
      state = await _service.startTimeshift(state.currentChannel!, offset);
    }
  }

  Future<void> stopTimeshift() async {
    state = await _service.stopTimeshift();
  }

  void handleSignalError(String message) {
    state = _service.handleSignalError(message);
  }

  void clearSignalError() {
    state = _service.clearSignalError();
  }

  List<M3uChannel> searchChannels(String query) {
    return _service.searchChannels(query);
  }

  Future<void> nextChannel() async {
    if (state.channels.isEmpty) return;
    final currentIndex = state.currentChannel != null
        ? state.channels.indexWhere((c) => c.url == state.currentChannel!.url)
        : -1;
    final nextIndex = (currentIndex + 1) % state.channels.length;
    await selectChannel(state.channels[nextIndex]);
  }

  Future<void> previousChannel() async {
    if (state.channels.isEmpty) return;
    final currentIndex = state.currentChannel != null
        ? state.channels.indexWhere((c) => c.url == state.currentChannel!.url)
        : -1;
    final prevIndex = currentIndex <= 0 ? state.channels.length - 1 : currentIndex - 1;
    await selectChannel(state.channels[prevIndex]);
  }

  Future<void> togglePlayPause() async {
    // Toggle play/pause state - for now just stops timeshift if active
    if (state.status == LiveStatus.timeshift) {
      await stopTimeshift();
    }
  }

  Future<void> seekTimeshift(Duration position) async {
    state = state.copyWith(timeshiftPosition: position);
  }
}