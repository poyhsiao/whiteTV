# whiteTV — iOS Platform Channel 實作設計規格

**專案**: whiteTV 跨平台影視串流客戶端
**版本**: v1.0
**日期**: 2026-06-21
**狀態**: 待用戶審查

---

## 1. 概述

### 1.1 目標

實作 iOS Platform Channel 框架，支援以下功能：
- **Handoff** - 跨設備繼續播放
- **Picture-in-Picture (PiP)** - 畫中畫模式
- **Siri Shortcuts** - 語音控制（預留介面）

### 1.2 現狀

| 功能 | Flutter 層 | iOS 原生層 | 狀態 |
|------|------------|------------|------|
| Handoff | ✅ 完整 | ❌ TODO | 待實作 |
| PiP | ✅ 完整 | ❌ TODO | 待實作 |
| Siri Shortcuts | ✅ 完整 | ❌ TODO | 預留 |

### 1.3 實作範圍（本版本）

- ✅ Plugin 框架建立
- ✅ Handoff 完整實作
- ⚙️ PiP 基本框架（Siri 延後）

---

## 2. 架構設計

### 2.1 架構圖

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter 層                              │
├─────────────────────────────────────────────────────────────┤
│  lib/core/ios/                                              │
│  ├── ios_platform_channel.dart      # 統一 API 封裝         │
│  ├── unified_ios_platform.dart     # MethodChannel 定義     │
│  └── ios_service_locator.dart      # 服務定位器             │
│                                                              │
│  已實作（使用占位實現）：                                     │
│  ├── lib/core/handoff/handoff_service.dart                  │
│  ├── lib/core/siri/siri_shortcuts.dart                      │
│  └── lib/core/device/pip/pip_controller.dart               │
│                        │                                    │
│                        ▼                                    │
│              MethodChannel                                  │
│          name: 'com.white_tv/ios'                          │
├─────────────────────────────────────────────────────────────┤
│                      iOS 原生層                              │
├─────────────────────────────────────────────────────────────┤
│  ios/Runner/                                                │
│  ├── AppDelegate.swift              # 註冊 Plugin           │
│  └── Plugins/                                               │
│      └── UnifiedIosPlatformPlugin.swift  # Swift Plugin     │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 MethodChannel API

| 方法名 | 參數 | 返回 | 說明 |
|--------|------|------|------|
| `handoff.startActivity` | `{type: String, userInfo: Map}` | `bool` | 開始 Handoff |
| `handoff.updateActivity` | `{userInfo: Map}` | `void` | 更新活動狀態 |
| `handoff.endActivity` | - | `void` | 結束活動 |
| `handoff.receiveActivity` | - | `Map?` | 接收活動 |
| `pip.start` | `{route: String}` | `bool` | 啟動 PiP |
| `pip.stop` | - | `void` | 停止 PiP |
| `pip.isSupported` | - | `bool` | 檢查支援 |

---

## 3. 檔案結構

### 3.1 新增檔案

```
lib/core/ios/
├── ios_platform_channel.dart      # NEW - MethodChannel 定義
├── unified_ios_platform.dart     # NEW - 統一 API 封裝
└── ios_service_locator.dart      # NEW - 服務定位器

ios/Runner/
├── AppDelegate.swift             # MODIFY - 註冊 Plugin
└── Plugins/
    └── UnifiedIosPlatformPlugin.swift  # NEW - Swift Plugin
```

### 3.2 檔案職責

| 檔案 | 職責 |
|------|------|
| `ios_platform_channel.dart` | MethodChannel 註冊與方法調用封裝 |
| `unified_ios_platform.dart` | 統一平台服務，支援有/無原生實作降級 |
| `ios_service_locator.dart` | 服務定位，根據平台啟用對應服務 |
| `UnifiedIosPlatformPlugin.swift` | iOS 原生實作 |

---

## 4. API 設計

### 4.1 Dart 層 (ios_platform_channel.dart)

```dart
/// iOS Platform Channel 封裝
class IosPlatformChannel {
  static const _channel = MethodChannel('com.white_tv/ios');
  
  // Handoff
  static Future<bool> startHandoff(String type, Map<String, dynamic> userInfo);
  static Future<void> updateHandoff(Map<String, dynamic> userInfo);
  static Future<void> endHandoff();
  static Future<Map<String, dynamic>?> receiveHandoff();
  
  // PiP
  static Future<bool> startPiP(String route);
  static Future<void> stopPiP();
  static Future<bool> isPiPSupported();
}
```

### 4.2 Swift 層 (UnifiedIosPlatformPlugin.swift)

```swift
class UnifiedIosPlatformPlugin: NSObject, FlutterPlugin {
    // MARK: - Handoff
    func handleStartActivity(call: FlutterMethodCall, result: @escaping FlutterResult)
    func handleUpdateActivity(call: FlutterMethodCall, result: @escaping FlutterResult)
    func handleEndActivity(call: FlutterMethodCall, result: @escaping FlutterResult)
    func handleReceiveActivity(call: FlutterMethodCall, result: @escaping FlutterResult)
    
    // MARK: - PiP
    func handleStartPiP(call: FlutterMethodCall, result: @escaping FlutterResult)
    func handleStopPiP(call: FlutterMethodCall, result: @escaping FlutterResult)
    func handleIsPiPSupported(call: FlutterMethodCall, result: @escaping FlutterResult)
}
```

---

## 5. 測試策略

### 5.1 TDD 流程

1. **單元測試** - 測試 IosPlatformChannel 方法調用
2. **整合測試** - 測試 Flutter 層與 Swift 層介面
3. **Mock 測試** - 使用 FakeIosPlatform 隔離原生依賴

### 5.2 測試覆蓋率目標

| 模組 | 目標覆蓋率 |
|------|-----------|
| ios_platform_channel.dart | 90%+ |
| unified_ios_platform.dart | 85%+ |
| ios_service_locator.dart | 80%+ |

### 5.3 BDD 測試場景

```gherkin
Feature: iOS Platform Channel

  Scenario: Handoff 開始活動
    Given 使用者在 iPhone 播放影片
    When 使用者開啟 Handoff
    Then 平台通道調用 startHandoff
    And 返回成功狀態

  Scenario: PiP 模式啟動
    Given 使用者正在觀看影片
    When 使用者啟動子母畫面
    Then 平台通道調用 startPiP
    And 返回成功狀態

  Scenario: 非 iOS 平台降級
    Given 使用者在 Android TV
    When 調用平台通道
    Then 返回 false/null（降級）
    And 不拋出異常
```

---

## 6. 實作順序

| Step | 任務 | 優先級 | 預估工時 |
|------|------|--------|----------|
| 1 | 建立 ios_platform_channel.dart | P0 | 1 hour |
| 2 | 建立 unified_ios_platform.dart | P0 | 1 hour |
| 3 | 建立 ios_service_locator.dart | P0 | 1 hour |
| 4 | 建立 UnifiedIosPlatformPlugin.swift | P0 | 2 hours |
| 5 | 修改 AppDelegate.swift 註冊 Plugin | P0 | 30 min |
| 6 | 單元測試 | P0 | 2 hours |
| 7 | BDD 整合測試 | P1 | 2 hours |

**總工期估算**: 1 天

---

## 7. 風險與緩解

| 風險 | 影響 | 緩解措施 |
|------|------|----------|
| iOS Simulator 不支援 PiP | 測試困難 | 使用實體設備測試 |
| Flutter 測試無法測試原生碼 | 覆蓋率不足 | Mock 隔離 + 少量 E2E |
| iOS API 變更 | 實作失敗 | 封裝版本檢查 |

---

## 8. 驗收標準

- [ ] IosPlatformChannel 方法可正確調用
- [ ] Handoff 功能在實體 iOS 設備正常工作
- [ ] PiP 框架可啟動（需實體設備驗證）
- [ ] 非 iOS 平台正確降級
- [ ] 單元測試覆蓋率達標
- [ ] flutter analyze 無錯誤

---

*文件版本: v1.0 — 待用戶審查後實作*
