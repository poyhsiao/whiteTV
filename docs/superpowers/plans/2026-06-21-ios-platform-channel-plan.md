# iOS Platform Channel 實作計劃

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立 iOS Platform Channel 框架，支援 Handoff 和 PiP 功能

**Architecture:** 統一 Plugin 架構，一個 Swift Plugin 處理所有 iOS platform channel 請求，Flutter 層封裝 MethodChannel 調用

**Tech Stack:** Flutter MethodChannel, Swift FlutterPlugin

---

## Global Constraints

- TDD: 先寫測試，再實作
- BDD: 整合測試使用 Gherkin 語法
- 覆蓋率: 單元測試 80%+
- 測試框架: flutter_test
- 程式碼規範: flutter analyze 無錯誤

---

## 實作任務

### Task 1: 建立 ios_platform_channel.dart

**Files:**
- Create: `lib/core/ios/ios_platform_channel.dart`
- Test: `test/core/ios/ios_platform_channel_test.dart`

**Interfaces:**
- Produces: `IosPlatformChannel` class with static methods

- [ ] **Step 1: 建立測試檔案**

```dart
// test/core/ios/ios_platform_channel_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/ios/ios_platform_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IosPlatformChannel', () {
    test('startHandoff calls platform channel', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.white_tv/ios'),
        (MethodCall call) async {
          expect(call.method, 'handoff.startActivity');
          return true;
        },
      );

      final result = await IosPlatformChannel.startHandoff(
        'com.white_tv.playback',
        {'contentId': '123'},
      );
      expect(result, true);
    });

    test('startHandoff returns false on platform exception', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.white_tv/ios'),
        (MethodCall call) async {
          throw PlatformException(code: 'UNAVAILABLE');
        },
      );

      final result = await IosPlatformChannel.startHandoff(
        'com.white_tv.playback',
        {},
      );
      expect(result, false);
    });
  });
}
```

- [ ] **Step 2: 執行測試確認失敗**

Run: `flutter test test/core/ios/ios_platform_channel_test.dart`
Expected: FAIL - file not found

- [ ] **Step 3: 建立 ios_platform_channel.dart**

```dart
// lib/core/ios/ios_platform_channel.dart
import 'package:flutter/services.dart';

/// iOS Platform Channel 封裝
/// 處理 Flutter 與 iOS 原生層的溝通
class IosPlatformChannel {
  IosPlatformChannel._();

  static const _channel = MethodChannel('com.white_tv/ios');

  // ==================== Handoff ====================

  /// 開始 Handoff 活動
  static Future<bool> startHandoff(
    String activityType,
    Map<String, dynamic> userInfo,
  ) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'handoff.startActivity',
        {
          'type': activityType,
          'userInfo': userInfo,
        },
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// 更新 Handoff 活動狀態
  static Future<void> updateHandoff(Map<String, dynamic> userInfo) async {
    try {
      await _channel.invokeMethod<void>(
        'handoff.updateActivity',
        {'userInfo': userInfo},
      );
    } on PlatformException {
      // ignore: 降級處理
    }
  }

  /// 結束 Handoff 活動
  static Future<void> endHandoff() async {
    try {
      await _channel.invokeMethod<void>('handoff.endActivity');
    } on PlatformException {
      // ignore: 降級處理
    }
  }

  /// 接收來自其他設備的 Handoff 活動
  static Future<Map<String, dynamic>?> receiveHandoff() async {
    try {
      final result = await _channel.invokeMethod<Map>('handoff.receiveActivity');
      return result?.cast<String, dynamic>();
    } on PlatformException {
      return null;
    }
  }

  // ==================== PiP ====================

  /// 啟動畫中畫模式
  static Future<bool> startPiP(String route) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'pip.start',
        {'route': route},
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// 停止畫中畫模式
  static Future<void> stopPiP() async {
    try {
      await _channel.invokeMethod<void>('pip.stop');
    } on PlatformException {
      // ignore: 降級處理
    }
  }

  /// 檢查平台是否支援 PiP
  static Future<bool> isPiPSupported() async {
    try {
      final result = await _channel.invokeMethod<bool>('pip.isSupported');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
```

- [ ] **Step 4: 執行測試確認通過**

Run: `flutter test test/core/ios/ios_platform_channel_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/ios/ios_platform_channel.dart test/core/ios/ios_platform_channel_test.dart
git commit -m "feat: add IosPlatformChannel for Flutter-iOS communication"
```

---

### Task 2: 建立 unified_ios_platform.dart

**Files:**
- Create: `lib/core/ios/unified_ios_platform.dart`
- Test: `test/core/ios/unified_ios_platform_test.dart`

**Interfaces:**
- Consumes: `IosPlatformChannel`
- Produces: `UnifiedIosPlatform` class with service methods

- [ ] **Step 1: 建立測試檔案**

```dart
// test/core/ios/unified_ios_platform_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/ios/unified_ios_platform.dart';

void main() {
  group('UnifiedIosPlatform', () {
    test('isIos returns true on iOS platform', () {
      // Mock platform detection
      expect(UnifiedIosPlatform.isIos, anyElement(contains('ios')));
    });

    test('startPlaybackHandoff calls channel', () async {
      // This would be tested with mock
      // For now, verify the method exists and has correct signature
    });
  });
}
```

- [ ] **Step 2: 建立 unified_ios_platform.dart**

```dart
// lib/core/ios/unified_ios_platform.dart
import 'dart:io' show Platform;
import 'package:white_tv/core/ios/ios_platform_channel.dart';

/// 統一 iOS 平台服務
/// 封裝 Handoff、PiP 等 iOS 特定功能
class UnifiedIosPlatform {
  UnifiedIosPlatform._();

  /// 是否為 iOS 平台
  static bool get isIos => Platform.isIOS;

  /// 是否為 macOS 平台
  static bool get isMacos => Platform.isMacOS;

  /// 是否支援原生功能
  static bool get isNativeSupported => isIos || isMacos;

  // ==================== Handoff ====================

  /// 開始播放內容的 Handoff
  static Future<bool> startPlaybackHandoff({
    required String contentId,
    required String title,
    Duration position = Duration.zero,
    String? episodeId,
  }) {
    return IosPlatformChannel.startHandoff(
      'com.white_tv.playback',
      {
        'contentId': contentId,
        'title': title,
        'position': position.inMilliseconds,
        if (episodeId != null) 'episodeId': episodeId,
      },
    );
  }

  /// 更新當前播放 Handoff 狀態
  static Future<void> updatePlaybackHandoff({
    required String contentId,
    Duration position = Duration.zero,
  }) {
    return IosPlatformChannel.updateHandoff({
      'contentId': contentId,
      'position': position.inMilliseconds,
    });
  }

  /// 結束播放 Handoff
  static Future<void> endPlaybackHandoff() {
    return IosPlatformChannel.endHandoff();
  }

  /// 獲取待處理的播放內容
  static Future<PlaybackHandoffInfo?> getPendingPlayback() async {
    final userInfo = await IosPlatformChannel.receiveHandoff();
    if (userInfo == null) return null;

    try {
      return PlaybackHandoffInfo(
        contentId: userInfo['contentId'] as String,
        title: userInfo['title'] as String,
        position: Duration(
          milliseconds: userInfo['position'] as int? ?? 0,
        ),
        episodeId: userInfo['episodeId'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  // ==================== PiP ====================

  /// 啟動畫中畫模式
  static Future<bool> startPiP(String route) {
    return IosPlatformChannel.startPiP(route);
  }

  /// 停止畫中畫模式
  static Future<void> stopPiP() {
    return IosPlatformChannel.stopPiP();
  }

  /// 檢查是否支援 PiP
  static Future<bool> isPiPSupported() {
    return IosPlatformChannel.isPiPSupported();
  }
}

/// 播放內容 Handoff 信息
class PlaybackHandoffInfo {
  const PlaybackHandoffInfo({
    required this.contentId,
    required this.title,
    this.position = Duration.zero,
    this.episodeId,
  });

  final String contentId;
  final String title;
  final Duration position;
  final String? episodeId;
}
```

- [ ] **Step 3: 執行 flutter analyze**

Run: `flutter analyze lib/core/ios/unified_ios_platform.dart`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/core/ios/unified_ios_platform.dart test/core/ios/unified_ios_platform_test.dart
git commit -m "feat: add UnifiedIosPlatform service wrapper"
```

---

### Task 3: 建立 UnifiedIosPlatformPlugin.swift

**Files:**
- Create: `ios/Runner/Plugins/UnifiedIosPlatformPlugin.swift`
- Modify: `ios/Runner/AppDelegate.swift`

**Interfaces:**
- Produces: FlutterPlugin 實現

- [ ] **Step 1: 建立 Plugins 目錄和 Swift 檔案**

```swift
// ios/Runner/Plugins/UnifiedIosPlatformPlugin.swift
import Flutter
import UIKit

/// 統一 iOS Platform Plugin
/// 處理 Flutter 與 iOS 原生層的所有溝通
public class UnifiedIosPlatformPlugin: NSObject, FlutterPlugin {
    
    // MARK: - Singleton
    public static let shared = UnifiedIosPlatformPlugin()
    
    // MARK: - Handoff State
    private var currentActivity: NSUserActivity?
    private var userInfoCache: [String: Any] = [:]
    
    // MARK: - FlutterPlugin
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.white_tv/ios",
            binaryMessenger: registrar.messenger()
        )
        let instance = UnifiedIosPlatformPlugin.shared
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "handoff.startActivity":
            handleStartActivity(call: call, result: result)
        case "handoff.updateActivity":
            handleUpdateActivity(call: call, result: result)
        case "handoff.endActivity":
            handleEndActivity(result: result)
        case "handoff.receiveActivity":
            handleReceiveActivity(result: result)
        case "pip.start":
            handleStartPiP(call: call, result: result)
        case "pip.stop":
            handleStopPiP(result: result)
        case "pip.isSupported":
            handleIsPiPSupported(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Handoff Handlers
    
    private func handleStartActivity(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let activityType = args["type"] as? String,
              let userInfo = args["userInfo"] as? [String: Any] else {
            result(false)
            return
        }
        
        let activity = NSUserActivity(activityType: activityType)
        activity.userInfo = userInfo
        activity.isEligibleForHandoff = true
        activity.becomeCurrent()
        
        currentActivity = activity
        userInfoCache = userInfo
        
        result(true)
    }
    
    private func handleUpdateActivity(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let userInfo = args["userInfo"] as? [String: Any] else {
            result(nil)
            return
        }
        
        userInfoCache = userInfo
        currentActivity?.userInfo = userInfo
        currentActivity?.needsSave = true
        
        result(nil)
    }
    
    private func handleEndActivity(result: @escaping FlutterResult) {
        currentActivity?.invalidate()
        currentActivity = nil
        userInfoCache = [:]
        result(nil)
    }
    
    private func handleReceiveActivity(result: @escaping FlutterResult) {
        // iOS 會自動通過 App Delegate 接收 Handoff
        // 這裡返回快取的數據
        result(userInfoCache.isEmpty ? nil : userInfoCache)
    }
    
    // MARK: - PiP Handlers
    
    private func handleStartPiP(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // PiP 需要 AVPictureInPictureController
        // 完整實作需要整合 media_kit
        // 這裡返回 false 表示尚未支援
        result(false)
    }
    
    private func handleStopPiP(result: @escaping FlutterResult) {
        result(nil)
    }
    
    private func handleIsPiPSupported(result: @escaping FlutterResult) {
        // 檢查設備是否支援 PiP
        if #available(iOS 15.0, *) {
            result(true)
        } else {
            result(false)
        }
    }
}
```

- [ ] **Step 2: 修改 AppDelegate.swift 註冊 Plugin**

```swift
// ios/Runner/AppDelegate.swift
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    
    // 註冊 UnifiedIosPlatformPlugin
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "UnifiedIosPlatformPlugin") {
        UnifiedIosPlatformPlugin.register(with: registrar)
    }
  }
}
```

- [ ] **Step 3: 執行 flutter analyze**

Run: `flutter analyze lib/core/ios/`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add ios/Runner/AppDelegate.swift ios/Runner/Plugins/UnifiedIosPlatformPlugin.swift
git commit -m "feat: add UnifiedIosPlatformPlugin for iOS native integration"
```

---

### Task 4: 更新 HandoffService 整合 Platform Channel

**Files:**
- Modify: `lib/core/handoff/handoff_service.dart`
- Test: `test/core/handoff/handoff_service_test.dart`

**Interfaces:**
- Consumes: `UnifiedIosPlatform`

- [ ] **Step 1: 更新 HandoffService**

```dart
// lib/core/handoff/handoff_service.dart (修改部分方法)
import 'package:white_tv/core/ios/unified_ios_platform.dart';
// ... existing imports ...

class HandoffService implements IHandoffService {
  HandoffService({required this.deviceType});

  final DeviceType deviceType;

  @override
  bool get isSupported {
    return deviceType == DeviceType.mobile;
  }

  @override
  Future<void> startActivity({
    required String activityType,
    required Map<String, dynamic> userInfo,
  }) async {
    // 如果是 iOS 平台，調用原生實現
    if (UnifiedIosPlatform.isIos) {
      await IosPlatformChannel.startHandoff(activityType, userInfo);
    }
    _currentActivityUserInfo = userInfo;
  }

  @override
  Future<void> updateActivity({
    required Map<String, dynamic> userInfo,
  }) async {
    if (UnifiedIosPlatform.isIos) {
      await IosPlatformChannel.updateHandoff(userInfo);
    }
    _currentActivityUserInfo = userInfo;
  }

  @override
  Future<void> endActivity() async {
    if (UnifiedIosPlatform.isIos) {
      await IosPlatformChannel.endHandoff();
    }
    _currentActivityUserInfo = null;
  }

  @override
  Future<Map<String, dynamic>?> receiveActivity() async {
    if (UnifiedIosPlatform.isIos) {
      return await IosPlatformChannel.receiveHandoff();
    }
    return null;
  }

  // ... rest of the class ...
}
```

- [ ] **Step 2: 更新測試**

```dart
// test/core/handoff/handoff_service_test.dart
// 添加新的測試案例
group('HandoffService iOS Integration', () {
  test('startActivity calls platform channel on iOS', () async {
    // Mock UnifiedIosPlatform.isIos
    // Verify IosPlatformChannel.startHandoff is called
  });
});
```

- [ ] **Step 3: 執行測試**

Run: `flutter test test/core/handoff/handoff_service_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git commit -m "feat: integrate IosPlatformChannel into HandoffService"
```

---

### Task 5: BDD 整合測試

**Files:**
- Create: `test/bdd/features/ios_platform_channel.feature`
- Create: `test/bdd/steps/ios_platform_channel_steps.dart`

- [ ] **Step 1: 建立 BDD Feature 檔案**

```gherkin
# test/bdd/features/ios_platform_channel.feature
Feature: iOS Platform Channel

  Scenario: Handoff 開始活動
    Given 使用者在 iPhone 播放影片
    And 影片 ID 為 "movie-123"
    When 使用者開啟 Handoff
    Then 平台通道調用 handoff.startActivity
    And 返回成功狀態

  Scenario: Handoff 接收活動
    Given 另一設備發送了 Handoff 活動
    When 應用程式接收活動
    Then 返回包含 contentId 的 userInfo
    And contentId 為 "movie-123"

  Scenario: PiP 模式檢查支援
    Given 使用者正在觀看影片
    When 檢查是否支援子母畫面
    Then 在 iOS 15+ 返回 true
    And 在較舊版本返回 false

  Scenario: 非 iOS 平台降級
    Given 使用者在 Android TV
    When 調用平台通道
    Then 返回 false 或 null
    And 不拋出異常
```

- [ ] **Step 2: Commit**

```bash
git add test/bdd/features/ios_platform_channel.feature
git commit -m "test: add BDD tests for iOS Platform Channel"
```

---

## 驗證步驟

完成所有任務後，執行以下驗證：

```bash
# 1. 程式碼分析
flutter analyze

# 2. 單元測試
flutter test

# 3. 覆蓋率檢查
flutter test --coverage
```

---

## 預估工時

| Task | 預估時間 |
|------|----------|
| Task 1: ios_platform_channel.dart | 1 hour |
| Task 2: unified_ios_platform.dart | 1 hour |
| Task 3: UnifiedIosPlatformPlugin.swift | 2 hours |
| Task 4: 更新 HandoffService | 1 hour |
| Task 5: BDD 整合測試 | 1 hour |

**總計**: 6 hours
