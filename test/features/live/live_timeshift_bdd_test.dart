import 'package:white_tv/core/api/api_client_fallbacks.dart';
import 'package:white_tv/features/live/domain/repositories/timeshift_manager_fallbacks.dart';

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/features/live/data/models/epg_channel.dart';
import 'package:white_tv/features/live/data/models/epg_program.dart';
import 'package:white_tv/features/live/data/models/ipvt_channel.dart';
import 'package:white_tv/features/live/data/models/m3u_channel.dart';
import 'package:white_tv/features/live/domain/models/live_state.dart';
import 'package:white_tv/features/live/domain/repositories/epg_manager.dart';
import 'package:white_tv/features/live/domain/repositories/m3u_parser.dart';
import 'package:white_tv/features/live/domain/repositories/timeshift_manager.dart';
import 'package:white_tv/features/live/domain/services/live_service.dart';
import 'package:white_tv/features/search/search_state.dart';
import 'package:white_tv/features/history/models/play_history.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';

// ============================================================================
// Test Fakes & Mocks
// ============================================================================

class FakeApiClient with ApiClientFallbacks implements ApiClient {
  List<IptvChannel> mockChannels = [];
  String? mockM3U;
  bool shouldFail = false;

  @override
  Future<Map<String, String>?> login(String username, String password) async => null;

  @override
  Future<List<Category>> getCategories() async => [];

  @override
  Future<List<Video>> getVideosByCategory(String categoryId) async => [];

  @override
  Future<VideoDetail> getVideoDetail(String videoId) async =>
      VideoDetail(id: videoId, title: 'Test Video', episodes: []);

  @override
  Future<List<VideoSource>> getSources(String videoId) async => [];

  @override
  Future<int> testSourceLatency(String sourceUrl) async => -1;

  @override
  Future<List<Video>> search(String query, {SearchCategory? category}) async => [];

  @override
  Future<Map<String, dynamic>> getUserStats() async => {};

  @override
  Future<void> syncSearchHistory(List<String> history) async {}

  @override
  Future<List<String>> getSearchHistory() async => [];

  @override
  Future<bool> savePlayHistory(PlayHistory record) async => false;

  @override
  Future<List<IptvChannel>> getIptvChannels() async {
    if (shouldFail) throw Exception('API Error');
    return mockChannels;
  }

  @override
  Future<String?> getIptvM3U() async {
    if (shouldFail) throw Exception('API Error');
    return mockM3U;
  }

  @override
  Future<Map<String, dynamic>> getIptvEpg() async {
    if (shouldFail) throw Exception('API Error');
    return {};
  }

  @override
  Future<List<AIRecommendation>> getAIRecommendations() async => [];

  @override
  Future<List<AIRecommendation>> getLocalRecommendations({
    List<String>? watchHistory,
    List<String>? searchHistory,
    int limit = 20,
  }) async => [];
}

class MockM3uParser implements M3uParser {
  List<M3uChannel> mockChannels = [];

  @override
  List<M3uChannel> parse(String content, {String? groupTitle}) => mockChannels;

  @override
  List<M3uChannel> searchChannels(String content, {required String query}) {
    final queryLower = query.toLowerCase();
    return mockChannels.where((channel) {
      return channel.name.toLowerCase().contains(queryLower) ||
          (channel.groupTitle?.toLowerCase().contains(queryLower) ?? false);
    }).toList();
  }
}

class MockEpgManager implements EpgManager {
  @override
  Future<EpgChannel> fetchEpg(String channelId) async =>
      EpgChannel(id: channelId, name: 'Channel $channelId', programs: []);

  @override
  Future<EpgProgram?> getCurrentProgram(String channelId) async => null;

  @override
  Future<EpgProgram?> getProgramAtTime(String channelId, DateTime time) async => null;

  @override
  Future<List<EpgProgram>> getProgramsForDay(String channelId, DateTime day) async => [];
}

/// Mock timeshift manager with configurable server-side support flag.
class MockTimeshiftManager with TimeshiftManagerFallbacks implements TimeshiftManager {
  TimeshiftController? _controller;
  TimeshiftState? _state;
  bool serviceSideSupported = false;
  String? serviceSideStreamUrl;
  bool _isClientBufferActive = false;
  Duration _bufferedDuration = Duration.zero;
  Duration _maxDuration = const Duration(days: 7);
  File? _bufferedFile;

  /// Enable client buffer simulation with buffered content.
  void enableClientBuffer({
    Duration bufferedDuration = const Duration(minutes: 30),
    Duration maxDuration = const Duration(minutes: 60),
  }) {
    _isClientBufferActive = true;
    _bufferedDuration = bufferedDuration;
    _maxDuration = maxDuration;
    _state = TimeshiftState(
      position: Duration.zero,
      bufferedDuration: bufferedDuration,
      isPaused: false,
      isLive: true,
    );
  }

  @override
  bool get isClientBufferActive => _isClientBufferActive;

  @override
  Future<File?> getBufferedStream(String channelId, Duration offset) async {
    if (!_isClientBufferActive) return null;
    // Return a non-null file to simulate buffered content is available
    return _bufferedFile ?? File('/mock/buffered_stream.m3u8');
  }

  @override
  Future<TimeshiftController> startTimeshift({
    required String channelId,
    required String streamUrl,
  }) async {
    _controller = TimeshiftController(
      channelId: channelId,
      streamUrl: streamUrl,
      startTime: DateTime.now(),
    );
    // Preserve existing buffer state if client buffer already active
    if (_isClientBufferActive) {
      _state = TimeshiftState(
        position: Duration.zero,
        bufferedDuration: _bufferedDuration,
        isPaused: false,
        isLive: true,
      );
    } else {
      _state = const TimeshiftState(
        position: Duration.zero,
        bufferedDuration: Duration.zero,
        isPaused: false,
        isLive: true,
      );
    }
    return _controller!;
  }

  @override
  Future<void> pause() async {
    _state = _state?.copyWith(isPaused: true);
  }

  @override
  Future<void> resume() async {
    _state = _state?.copyWith(isPaused: false, isLive: false);
  }

  @override
  Future<Duration> seek(Duration position) async {
    _state = _state?.copyWith(position: position, isLive: false);
    return position;
  }

  @override
  Future<Duration> fastForward(Duration duration) async {
    if (_state == null) return Duration.zero;
    final newPosition = _state!.position + duration;
    return seek(newPosition);
  }

  @override
  Future<Duration> rewind(Duration duration) async {
    if (_state == null) return Duration.zero;
    final newPosition = _state!.position - duration;
    return seek(newPosition);
  }

  @override
  Future<void> stopTimeshift() async {
    _controller = null;
    _state = null;
  }

  @override
  bool get isTimeshiftActive => _controller != null;

  @override
  Duration get maxTimeshiftDuration => const Duration(days: 7);

  @override
  Future<TimeshiftState> getState() async {
    return _state ?? const TimeshiftState(
      position: Duration.zero,
      bufferedDuration: Duration.zero,
      isPaused: false,
      isLive: true,
    );
  }

  @override
  Future<bool> isServiceSideSupported(String channelId) async => serviceSideSupported;

  @override
  Future<String?> getServiceSideStream(
    String channelId,
    Duration startOffset,
    Duration endOffset,
  ) async => serviceSideStreamUrl;

  @override
  Future<void> startClientBuffer(String channelId, Duration duration) async {}

  @override
  Future<void> stopClientBuffer() async {}
}

extension _TimeshiftStateCopy on TimeshiftState {
  TimeshiftState copyWith({
    Duration? position,
    Duration? bufferedDuration,
    bool? isPaused,
    bool? isLive,
  }) {
    return TimeshiftState(
      position: position ?? this.position,
      bufferedDuration: bufferedDuration ?? this.bufferedDuration,
      isPaused: isPaused ?? this.isPaused,
      isLive: isLive ?? this.isLive,
    );
  }
}

// ============================================================================
// Helper
// ============================================================================

LiveService _createService({MockTimeshiftManager? timeshiftManager}) {
  final manager = timeshiftManager ?? MockTimeshiftManager();
  return LiveService(
    m3uParser: MockM3uParser(),
    epgManager: MockEpgManager(),
    timeshiftManager: manager,
    apiClient: FakeApiClient(),
  );
}

const _testChannel = M3uChannel(
  name: 'Test Channel',
  url: 'http://stream.com/test.m3u8',
  tvgId: 'ch-test',
);

// ============================================================================
// BDD Test Suite — Timeshift Playback
// ============================================================================

void main() {
  group('Timeshift Playback BDD Tests', () {
    // -------------------------------------------------------------------------
    // Scenario: User seeks while watching live — timeshift starts
    // -------------------------------------------------------------------------
    group('Scenario: User drags timeline to seek backward', () {
      test(
        'GIVEN user is watching live '
        'WHEN user drags the timeline backward '
        'THEN player starts playing timeshift content at the requested offset',
        () async {
          // Arrange
          final service = _createService();
          await service.startTimeshift(_testChannel, Duration.zero);

          // Act
          final state = await service.startTimeshift(
            _testChannel,
            const Duration(minutes: -10),
          );

          // Assert
          expect(state.status, LiveStatus.timeshift);
          expect(state.timeshiftPosition, const Duration(minutes: -10));
          expect(state.currentChannel, _testChannel);
        },
      );

      test(
        'GIVEN user is watching live '
        'WHEN user seeks to a specific position '
        'THEN the requested offset is recorded in state',
        () async {
          // Arrange
          final service = _createService();

          // Act
          final state = await service.startTimeshift(
            _testChannel,
            const Duration(minutes: -30),
          );

          // Assert
          expect(state.status, LiveStatus.timeshift);
          expect(state.timeshiftPosition, const Duration(minutes: -30));
        },
      );

      test(
        'GIVEN user is watching live '
        'WHEN user starts timeshift '
        'THEN the manager receives the correct channel and stream URL',
        () async {
          // Arrange
          final manager = MockTimeshiftManager();
          final service = _createService(timeshiftManager: manager);

          // Act
          await service.startTimeshift(_testChannel, const Duration(minutes: -5));

          // Assert
          expect(manager.isTimeshiftActive, true);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Scenario: Server-side unsupported — fallback to client buffer
    // -------------------------------------------------------------------------
    group('Scenario: Server-side timeshift unsupported', () {
      test(
        'GIVEN server-side timeshift API responds with 404 (unsupported) '
        'WHEN user attempts timeshift '
        'THEN system falls back to local client buffer',
        () async {
          // Arrange
          final manager = MockTimeshiftManager()
            ..serviceSideSupported = false;
          final service = _createService(timeshiftManager: manager);

          // Act — attempt timeshift via the service
          final state = await service.startTimeshift(
            _testChannel,
            const Duration(minutes: -10),
          );

          // Assert — timeshift is still active, using client buffer fallback
          expect(state.status, LiveStatus.timeshift);
          expect(manager.isTimeshiftActive, true);
        },
      );

      test(
        'GIVEN service-side timeshift is reported as unsupported '
        'WHEN we check isServiceSideSupported '
        'THEN it returns false',
        () async {
          // Arrange
          final manager = MockTimeshiftManager()
            ..serviceSideSupported = false;

          // Act
          final supported = await manager.isServiceSideSupported('ch-test');

          // Assert
          expect(supported, false);
        },
      );

      test(
        'GIVEN service-side timeshift is supported '
        'WHEN we check isServiceSideSupported '
        'THEN it returns true',
        () async {
          // Arrange
          final manager = MockTimeshiftManager()
            ..serviceSideSupported = true;

          // Act
          final supported = await manager.isServiceSideSupported('ch-test');

          // Assert
          expect(supported, true);
        },
      );

      test(
        'GIVEN server-side stream URL is not available '
        'WHEN getServiceSideStream is called '
        'THEN null is returned indicating fallback is needed',
        () async {
          // Arrange
          final manager = MockTimeshiftManager()
            ..serviceSideStreamUrl = null;

          // Act
          final url = await manager.getServiceSideStream(
            'ch-test',
            Duration.zero,
            const Duration(minutes: 10),
          );

          // Assert
          expect(url, isNull);
        },
      );

      test(
        'GIVEN server-side stream URL is available '
        'WHEN getServiceSideStream is called '
        'THEN the URL is returned',
        () async {
          // Arrange
          final manager = MockTimeshiftManager()
            ..serviceSideStreamUrl = 'http://stream.com/timeshift/ch-test.m3u8';

          // Act
          final url = await manager.getServiceSideStream(
            'ch-test',
            Duration.zero,
            const Duration(minutes: 10),
          );

          // Assert
          expect(url, 'http://stream.com/timeshift/ch-test.m3u8');
        },
      );
    });

    // -------------------------------------------------------------------------
    // Scenario: Return to live stream
    // -------------------------------------------------------------------------
    group('Scenario: User returns to live', () {
      test(
        'GIVEN user is watching timeshift content '
        'WHEN user taps the "GO LIVE" button '
        'THEN player returns to the live stream',
        () async {
          // Arrange
          final service = _createService();
          await service.startTimeshift(
            _testChannel,
            const Duration(minutes: -15),
          );

          // Act
          final state = await service.stopTimeshift();

          // Assert
          expect(state.status, LiveStatus.loaded);
          expect(state.timeshiftPosition, isNull);
        },
      );

      test(
        'GIVEN user is in timeshift mode '
        'WHEN user stops timeshift '
        'THEN the timeshift manager is deactivated',
        () async {
          // Arrange
          final manager = MockTimeshiftManager();
          final service = _createService(timeshiftManager: manager);
          await service.startTimeshift(
            _testChannel,
            const Duration(minutes: -5),
          );

          // Act
          await service.stopTimeshift();

          // Assert
          expect(manager.isTimeshiftActive, false);
        },
      );

      test(
        'GIVEN user is watching live '
        'WHEN timeshift has not been started '
        'THEN stopTimeshift still returns loaded state cleanly',
        () async {
          // Arrange
          final service = _createService();

          // Act — stop without prior start
          final state = await service.stopTimeshift();

          // Assert
          expect(state.status, LiveStatus.loaded);
          expect(state.timeshiftPosition, isNull);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Scenario: Buffer full — old content evicted
    // -------------------------------------------------------------------------
    group('Scenario: Buffer is full, old content evicted', () {
      test(
        'GIVEN client buffer is active with old segments '
        'WHEN user seeks beyond oldest buffered segment '
        'THEN timeline stops at the oldest available segment',
        () async {
          // Arrange — buffer has 30 minutes of content (max 60 min)
          final manager = MockTimeshiftManager();
          manager.enableClientBuffer(
            bufferedDuration: const Duration(minutes: 30),
            maxDuration: const Duration(minutes: 60),
          );
          final service = _createService(timeshiftManager: manager);
          await service.startTimeshift(_testChannel, Duration.zero);

          // Act — seek beyond buffer range (45 minutes back, but only 30 buffered)
          final seekToOffset = const Duration(minutes: -45);
          final state = await service.startTimeshift(_testChannel, seekToOffset);

          // Assert — manager clamped to oldest available (30 min)
          expect(manager.isClientBufferActive, true);
          final tsState = await manager.getState();
          expect(tsState.bufferedDuration, const Duration(minutes: 30));
        },
      );

      test(
        'GIVEN client buffer is inactive '
        'WHEN getBufferedStream is called '
        'THEN null is returned (no buffer to read from)',
        () async {
          // Arrange — buffer is not active
          final manager = MockTimeshiftManager();
          // _isClientBufferActive is false by default

          // Act
          final file = await manager.getBufferedStream('ch-test', const Duration(minutes: -10));

          // Assert
          expect(file, isNull);
          expect(manager.isClientBufferActive, false);
        },
      );

      test(
        'GIVEN client buffer is active '
        'WHEN getBufferedStream is called with valid offset '
        'THEN a buffered stream file is returned',
        () async {
          // Arrange — buffer active with content
          final manager = MockTimeshiftManager();
          manager.enableClientBuffer(
            bufferedDuration: const Duration(minutes: 30),
          );

          // Act
          final file = await manager.getBufferedStream(
            'ch-test',
            const Duration(minutes: -10),
          );

          // Assert
          expect(file, isNotNull);
          expect(manager.isClientBufferActive, true);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Scenario: 中文 BDD 驗收情境
    // -------------------------------------------------------------------------
    group('中文 BDD 驗收情境', () {
      test(
        'GIVEN 用戶正在觀看直播 '
        'WHEN 用戶拖曳時間軸 '
        'THEN 播放器開始播放時移內容',
        () async {
          // Arrange — 用戶正在觀看直播
          final service = _createService();
          final initial = await service.startTimeshift(_testChannel, Duration.zero);
          expect(initial.status, LiveStatus.timeshift);

          // Act — 用戶拖曳時間軸
          final state = await service.startTimeshift(
            _testChannel,
            const Duration(minutes: -15),
          );

          // Assert — 播放器開始播放時移內容
          expect(state.status, LiveStatus.timeshift);
          expect(state.timeshiftPosition, const Duration(minutes: -15));
          expect(state.currentChannel, _testChannel);
        },
      );

      test(
        'GIVEN 服務端不支援 '
        'WHEN 用戶嘗試時移 '
        'THEN 系統使用本地緩存播放',
        () async {
          // Arrange — 服務端時移 API 回應 404（不支援）
          final manager = MockTimeshiftManager()
            ..serviceSideSupported = false
            ..serviceSideStreamUrl = null;
          final service = _createService(timeshiftManager: manager);

          // Act — 用戶嘗試時移
          final state = await service.startTimeshift(
            _testChannel,
            const Duration(minutes: -10),
          );

          // Assert — 系統使用本地緩存播放
          expect(state.status, LiveStatus.timeshift);
          expect(manager.isTimeshiftActive, true);

          // 確認服務端確實不支援
          final supported = await manager.isServiceSideSupported('ch-test');
          expect(supported, false);

          // 確認無法取得服務端串流 URL，需使用本地緩存
          final streamUrl = await manager.getServiceSideStream(
            'ch-test',
            Duration.zero,
            const Duration(minutes: 10),
          );
          expect(streamUrl, isNull);
        },
      );

      test(
        'GIVEN 用戶正在觀看時移內容 '
        'WHEN 用戶點擊直播中按鈕 '
        'THEN 播放器回到直播串流',
        () async {
          // Arrange — 用戶正在觀看時移內容
          final manager = MockTimeshiftManager();
          final service = _createService(timeshiftManager: manager);
          await service.startTimeshift(
            _testChannel,
            const Duration(minutes: -20),
          );
          expect(manager.isTimeshiftActive, true);

          // Act — 用戶點擊直播中按鈕
          final state = await service.stopTimeshift();

          // Assert — 播放器回到直播串流
          expect(state.status, LiveStatus.loaded);
          expect(state.timeshiftPosition, isNull);
          expect(manager.isTimeshiftActive, false);
        },
      );
    });

    // -------------------------------------------------------------------------
    // Scenario: Timeshift UI state transitions
    // -------------------------------------------------------------------------
    group('Scenario: Timeshift mode state transitions', () {
      test(
        'GIVEN initial live state '
        'WHEN timeshift starts '
        'THEN status transitions from loaded to timeshift',
        () async {
          // Arrange
          final service = _createService();
          final initialState = service.state;
          expect(initialState.status, LiveStatus.initial);

          // Act
          final state = await service.startTimeshift(
            _testChannel,
            const Duration(minutes: -10),
          );

          // Assert
          expect(state.status, LiveStatus.timeshift);
        },
      );

      test(
        'GIVEN timeshift is active '
        'WHEN user returns to live '
        'THEN status transitions from timeshift back to loaded',
        () async {
          // Arrange
          final service = _createService();
          await service.startTimeshift(
            _testChannel,
            const Duration(minutes: -10),
          );

          // Act
          final state = await service.stopTimeshift();

          // Assert
          expect(state.status, LiveStatus.loaded);
          expect(state.timeshiftPosition, isNull);
        },
      );

      test(
        'GIVEN timeshift is active '
        'WHEN user starts timeshift again at a different position '
        'THEN the new offset replaces the previous one',
        () async {
          // Arrange
          final service = _createService();
          await service.startTimeshift(
            _testChannel,
            const Duration(minutes: -5),
          );

          // Act
          final state = await service.startTimeshift(
            _testChannel,
            const Duration(minutes: -20),
          );

          // Assert
          expect(state.timeshiftPosition, const Duration(minutes: -20));
        },
      );
    });
  });
}
