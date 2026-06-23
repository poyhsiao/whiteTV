import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/features/live/data/models/m3u_channel.dart';
import 'package:white_tv/features/live/domain/models/live_state.dart';
import 'package:white_tv/features/live/domain/repositories/epg_manager.dart';
import 'package:white_tv/features/live/domain/repositories/m3u_parser.dart';
import 'package:white_tv/features/live/domain/repositories/timeshift_manager.dart';

class LiveService {
  final M3uParser m3uParser;
  final EpgManager epgManager;
  final TimeshiftManager timeshiftManager;
  final ApiClient? apiClient;

  LiveState _state = LiveState.initial();

  LiveService({
    required this.m3uParser,
    required this.epgManager,
    required this.timeshiftManager,
    this.apiClient,
  });

  /// 從 API 載入頻道（JSON 優先，M3U 備援）
  Future<LiveState> loadFromApi() async {
    _state = _state.copyWith(status: LiveStatus.loading);

    // 嘗試 JSON 格式
    if (apiClient != null) {
      final channels = await apiClient!.getIptvChannels();
      if (channels.isNotEmpty) {
        final m3uChannels = channels.map((c) => c.toM3uChannel()).toList();
        _state = _state.copyWith(
          status: LiveStatus.loaded,
          channels: m3uChannels,
        );
        return _state;
      }

      // Fallback 到 M3U
      final m3uContent = await apiClient!.getIptvM3U();
      if (m3uContent != null && m3uContent.isNotEmpty) {
        final channels = m3uParser.parse(m3uContent);
        _state = _state.copyWith(status: LiveStatus.loaded, channels: channels);
        return _state;
      }
    }

    // 無法載入，回傳錯誤
    _state = _state.copyWith(
      status: LiveStatus.error,
      errorMessage: '無法載入頻道列表',
    );
    return _state;
  }

  Future<LiveState> loadChannels(String m3uContent) async {
    _state = _state.copyWith(status: LiveStatus.loading);

    final channels = m3uParser.parse(m3uContent);

    _state = _state.copyWith(status: LiveStatus.loaded, channels: channels);

    return _state;
  }

  Future<LiveState> selectChannel(M3uChannel channel) async {
    _state = _state.copyWith(
      currentChannel: channel,
      status: LiveStatus.loaded,
      isSignalError: false,
      errorMessage: null,
    );
    return _state;
  }

  Future<LiveState> startTimeshift(M3uChannel channel, Duration offset) async {
    await timeshiftManager.startTimeshift(
      channelId: channel.tvgId ?? channel.name,
      streamUrl: channel.url,
    );

    _state = _state.copyWith(
      status: LiveStatus.timeshift,
      currentChannel: channel,
      timeshiftPosition: offset,
    );

    return _state;
  }

  Future<LiveState> stopTimeshift() async {
    await timeshiftManager.stopTimeshift();

    _state = _state.copyWith(
      status: LiveStatus.loaded,
      clearTimeshiftPosition: true,
    );

    return _state;
  }

  Future<void> startClientBuffer(String channelId, Duration duration) async {
    await timeshiftManager.startClientBuffer(channelId, duration);
  }

  Future<void> stopClientBuffer() async {
    await timeshiftManager.stopClientBuffer();
  }

  LiveState handleSignalError(String message) {
    _state = _state.copyWith(isSignalError: true, errorMessage: message);
    return _state;
  }

  LiveState clearSignalError() {
    _state = _state.copyWith(isSignalError: false, clearErrorMessage: true);
    return _state;
  }

  List<M3uChannel> searchChannels(String query) {
    return m3uParser.searchChannels(
      _state.channels.map((c) => _channelToM3uString(c)).join('\n'),
      query: query,
    );
  }

  String _channelToM3uString(M3uChannel channel) {
    final buffer = StringBuffer();
    buffer.write('#EXTINF:-1');
    if (channel.tvgId != null) buffer.write(' tvg-id="${channel.tvgId}"');
    if (channel.name.isNotEmpty) buffer.write(' tvg-name="${channel.name}"');
    if (channel.logoUrl != null) buffer.write(' tvg-logo="${channel.logoUrl}"');
    if (channel.groupTitle != null) {
      buffer.write(' group-title="${channel.groupTitle}"');
    }
    buffer.write(',${channel.name}');
    buffer.write('\n${channel.url}');
    return buffer.toString();
  }

  LiveState get state => _state;
}
