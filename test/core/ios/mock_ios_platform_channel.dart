import 'package:white_tv/core/ios/ios_platform_channel.dart';

/// Mock IosPlatformChannel - 用於單元測試
class MockIosPlatformChannel implements IosPlatformChannelInterface {
  // Handoff mock state
  bool startHandoffCalled = false;
  String? lastActivityType;
  Map<String, dynamic>? lastUserInfo;
  bool shouldStartHandoffSucceed = true;
  int startHandoffCallCount = 0;

  bool updateHandoffCalled = false;
  Map<String, dynamic>? lastUpdateInfo;
  int updateHandoffCallCount = 0;

  bool endHandoffCalled = false;
  int endHandoffCallCount = 0;

  bool receiveHandoffCalled = false;
  Map<String, dynamic>? receiveHandoffResult;
  int receiveHandoffCallCount = 0;

  // PiP mock state
  bool startPiPCalled = false;
  String? lastPiPRoute;
  bool shouldStartPiPSucceed = true;
  int startPiPCallCount = 0;

  bool stopPiPCalled = false;
  int stopPiPCallCount = 0;

  bool isPiPSupportedCalled = false;
  bool piPSupportedResult = true;
  int isPiPSupportedCallCount = 0;

  @override
  Future<bool> startHandoff(
    String activityType,
    Map<String, dynamic> userInfo,
  ) async {
    startHandoffCalled = true;
    lastActivityType = activityType;
    lastUserInfo = userInfo;
    startHandoffCallCount++;
    return shouldStartHandoffSucceed;
  }

  @override
  Future<void> updateHandoff(Map<String, dynamic> userInfo) async {
    updateHandoffCalled = true;
    lastUpdateInfo = userInfo;
    updateHandoffCallCount++;
  }

  @override
  Future<void> endHandoff() async {
    endHandoffCalled = true;
    endHandoffCallCount++;
  }

  @override
  Future<Map<String, dynamic>?> receiveHandoff() async {
    receiveHandoffCalled = true;
    receiveHandoffCallCount++;
    return receiveHandoffResult;
  }

  @override
  Future<bool> startPiP(String route) async {
    startPiPCalled = true;
    lastPiPRoute = route;
    startPiPCallCount++;
    return shouldStartPiPSucceed;
  }

  @override
  Future<void> stopPiP() async {
    stopPiPCalled = true;
    stopPiPCallCount++;
  }

  @override
  Future<bool> isPiPSupported() async {
    isPiPSupportedCalled = true;
    isPiPSupportedCallCount++;
    return piPSupportedResult;
  }

  /// 重置所有 mock 狀態
  void reset() {
    // Handoff
    startHandoffCalled = false;
    lastActivityType = null;
    lastUserInfo = null;
    shouldStartHandoffSucceed = true;
    startHandoffCallCount = 0;

    updateHandoffCalled = false;
    lastUpdateInfo = null;
    updateHandoffCallCount = 0;

    endHandoffCalled = false;
    endHandoffCallCount = 0;

    receiveHandoffCalled = false;
    receiveHandoffResult = null;
    receiveHandoffCallCount = 0;

    // PiP
    startPiPCalled = false;
    lastPiPRoute = null;
    shouldStartPiPSucceed = true;
    startPiPCallCount = 0;

    stopPiPCalled = false;
    stopPiPCallCount = 0;

    isPiPSupportedCalled = false;
    piPSupportedResult = true;
    isPiPSupportedCallCount = 0;
  }
}
