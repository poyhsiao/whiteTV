# whiteTV — 系統架構規劃文件 (v2.0)

**專案目標**: 以單一前端程式碼基底，實作跨平台影視串流客戶端
**資料來源**: LunaTV Backend API (TVBox JSON 格式)
**覆蓋平台**: Android TV / GoogleTV / iOS / Android Mobile (必備)，iPad / macOS / Web (Nice to have)
**文件狀態**: v2.0 — 審查後更新
**最後更新**: 2026-05-19

---

## 1. 專案背景與需求理解

### 1.1 核心需求

| 需求 | 說明 |
|------|------|
| **單一前端框架** | 維護一套前端程式碼，支援所有目標平台 |
| **後端資料來源** | 來自 LunaTV 的 API (TVBox JSON 格式) |
| **取代 OrionTV** | 重新設計 OrionTV 成為功能完整的跨平台 client |
| **LunaTV 新功能** | IPTV、網盤搜尋、AI 推薦、YouTube 整合等（透過 LunaTV API） |

### 1.2 審查後確認的關鍵決策

| 項目 | 決策 |
|------|------|
| **框架** | Flutter（tvOS 不需要，Flutter 對 Android TV 支援完整） |
| **後端** | 純客戶端，透過設定頁配置 LunaTV API URL |
| **登入系統** | 需要（LunaTV cookie 認證，支援跨設備同步） |
| **跨設備同步** | 透過 LunaTV API 實現（收藏、播放歷史） |
| **IPTV** | 需要，P1 優先級 |
| **來源選擇** | 自動選擇最快 + 手動切換 + 狀態顯示 |

### 1.3 平台支援優先級

| 平台 | 優先級 | 輸入方式 |
|------|--------|----------|
| **Android TV / GoogleTV** | 一定要 | D-pad/遙控器 |
| **iPhone / Android 手機** | 一定要 | 觸控 |
| **iPad** | 最好有 | 觸控/滑鼠 |
| **macOS** | 最好有 | 鍵盤/滑鼠 |
| **Web** | 最好有（快速驗證） | 鍵盤/滑鼠 |
| **tvOS** | 不需要 | — |

---

## 2. 前端框架選擇

### 2.1 為何選擇 Flutter

| 面向 | Flutter | React Native |
|------|---------|--------------|
| Android TV 支援 | **官方支援** | 需社群 fork 或 Expo |
| 影片播放 | `media_kit` 成熟完善 | expo-video 需額外適配 |
| Web PWA | 成熟 | 需額外設定 |
| 對爾爾 | 無歷史包袱 | OrionTV 經驗可參考 |
| 你的熟悉度 | 沒問題 | — |

### 2.2 平台支援總覽

| 平台 | Flutter | 說明 |
|------|---------|------|
| Android TV / GoogleTV | ✅ 原生 | 官方 Android TV target |
| iOS | ✅ 原生 | 標準 iOS build |
| Android Mobile | ✅ 原生 | 標準 APK |
| iPad | ✅ 原生 | iPad target |
| macOS | ✅ 原生 | macOS target |
| Web | ✅ PWA | Flutter Web |

---

## 3. 後端架構

### 3.1 純客戶端設計

```
┌─────────────────────────────────────────────────────────┐
│                      whiteTV Client                      │
│                   (Flutter + Expo)                      │
│                                                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │              設定頁 (Settings)                    │   │
│  │  • LunaTV API Server URL                          │   │
│  │  • 登入帳號 / 密碼                                │   │
│  │  • 播放偏好                                        │   │
│  └─────────────────────────────────────────────────┘   │
│                           │                              │
│                           ▼                              │
│  ┌─────────────────────────────────────────────────┐   │
│  │              LunaTV API (外部)                    │   │
│  │  • 內容列表 / 搜尋 / 詳情                         │   │
│  │  • 使用者收藏 / 歷史                              │   │
│  │  • IPTV 直播                                      │   │
│  │  • AI 推薦                                        │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

**不需要自建後端服務** — 所有功能透過 LunaTV API 實現。

### 3.2 LunaTV API 格式

LunaTV 使用標準 TVBox JSON API 格式：

```
Base URL: http://lunatv-server:3000/api/

GET /tvbox?format=json              → TVBox 配置（含所有來源）
GET /list                           → 電影/劇集列表
GET /detail/{id}                    → 內容詳情
GET /search?q={q}                  → 搜尋
GET /categories                     → 分類列表

IPTV:
GET /iptv/list                      → M3U 播放列表
GET /iptv/epg                       → EPG 節目表

使用者相關（需登入）:
GET /favorites                      → 收藏列表
GET /searchhistory                   → 搜尋歷史
GET /user/my-stats                  → 使用者統計
```

### 3.3 設定頁設計

```dart
// 設定頁面需要儲存的配置
class AppSettings {
  String lunaTVUrl;        // LunaTV API 伺服器 URL
  String? username;        // LunaTV 帳號（可選）
  String? password;        // LunaTV 密碼（可選）
  String? authToken;       // LunaTV cookie/token
  bool autoSelectSource;   // 自動選擇最快來源
  int defaultSpeed;        // 預設播放速度
}
```

---

## 4. 前端架構詳細設計

### 4.1 專案結構

```
whiteTV/
├── lib/
│   ├── main.dart                    # 入口
│   │
│   ├── app/                        # 頁面
│   │   ├── home/                   # 首頁
│   │   ├── detail/                 # 詳情頁
│   │   ├── player/                 # 播放器頁
│   │   ├── search/                 # 搜尋頁
│   │   ├── favorites/              # 收藏頁
│   │   ├── live/                   # 直播頁
│   │   ├── settings/               # 設定頁
│   │   └── login/                  # 登入頁
│   │
│   ├── core/                       # 核心
│   │   ├── api/                    # API client
│   │   │   ├── luna_client.dart    # LunaTV API 封裝
│   │   │   ├── auth_service.dart   # 登入認證
│   │   │   └── models/             # API 模型
│   │   ├── storage/                # 本地儲存
│   │   │   └── settings_store.dart # 設定儲存
│   │   └── utils/                  # 工具
│   │       ├── device_utils.dart   # 設備檢測
│   │       └── source_tester.dart   # 來源測速
│   │
│   ├── features/                    # 功能
│   │   ├── home/                   # 首頁功能
│   │   ├── player/                 # 播放器功能
│   │   ├── search/                 # 搜尋功能
│   │   ├── favorites/              # 收藏功能
│   │   ├── live/                   # 直播功能
│   │   └── settings/               # 設定功能
│   │
│   ├── shared/                     # 共用
│   │   ├── components/             # UI 元件
│   │   │   ├── video_card.dart
│   │   │   ├── source_selector.dart
│   │   │   └── ...
│   │   ├── hooks/                  # 自訂 Hooks
│   │   ├── theme/                  # 主題
│   │   └── widgets/                # 通用 widget
│   │
│   └── platform/                   # 平台特定
│       ├── tv/                     # TV 特定
│       │   ├── focus_manager.dart
│       │   └── remote_handler.dart
│       ├── mobile/                 # 手機特定
│       └── web/                    # Web 特定
│
├── assets/                         # 靜態資源
│   └── ...
│
└── docs/                           # 文件
```

### 4.2 關鍵依賴

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter

  # 狀態管理
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # 影片播放
  media_kit: ^1.1.0
  media_kit_video: ^1.2.0
  media_kit_libs_video: ^1.1.0

  # HTTP
  dio: ^5.4.0

  # 本地儲存
  shared_preferences: ^2.2.0
  flutter_secure_storage: ^1.1.0

  # 導航
  go_router: ^14.0.0

  # UI
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0

  # 平台特定
  flutter_tv: ^1.0.0         # Android TV 支援
  google_fonts: ^6.1.0
```

### 4.3 平台特定適配

```dart
// 設備檢測
enum DeviceType { tv, mobile, tablet, web }

DeviceType getDeviceType() {
  // 根據平台和螢幕大小判斷
}

// TV 特定
bool get isTV => getDeviceType() == DeviceType.tv;
bool get isMobile => getDeviceType() == DeviceType.mobile;
```

---

## 5. 核心功能模組

### 5.1 功能優先級

| 優先級 | 功能 | 說明 |
|--------|------|------|
| **P0** | 首頁分類瀏覽 | 分類展示、內容列表 |
| **P0** | 影片播放 | VOD 播放、基本控制 |
| **P0** | 來源切換 | 自動選擇 + 手動切換 |
| **P0** | 設定頁 | LunaTV URL 設定、登入 |
| **P1** | 搜尋 | 即時搜尋、歷史記錄 |
| **P1** | 收藏 | 收藏列表、跨設備同步 |
| **P1** | 播放記錄 | 觀看歷史、繼續播放 |
| **P1** | IPTV 直播 | M3U 播放、EPG |
| **P2** | AI 推薦 | 串 LunaTV API |
| **P2** | YouTube 整合 | 串 LunaTV API |

### 5.2 來源選擇策略

```dart
// 自動選擇最快的來源
Future<VideoSource?> selectFastestSource(List<VideoSource> sources) async {
  final tester = SourceTester();
  
  // 並行測試所有來源
  final results = await Future.wait(
    sources.map((s) => tester.testSpeed(s, timeout: 5.seconds)),
  );
  
  // 按速度排序
  results.sort((a, b) => a.latency.compareTo(b.latency));
  
  // 返回最快且可用的
  return results.firstWhere((r) => r.available, orElse: () => null);
}
```

UI 需要顯示：
- 各來源狀態徽章（可用/測試中/不可用）
- 當前來源
- 手動切換按鈕

---

## 6. 使用者系統設計

### 6.1 登入流程

```
使用者輸入 LunaTV 帳號密碼
         │
         ▼
  调用 LunaTV 登入 API
         │
    是否成功？──否──▶ 顯示錯誤
         │
        是
         │
         ▼
  保存 auth cookie/token
         │
         ▼
  後續請求自動攜帶 cookie
```

### 6.2 認證機制

| 方式 | 說明 |
|------|------|
| **Cookie** | LunaTV 使用 cookie 認證，保存並在後續請求中攜帶 |
| **Token** | TVBox token 認證，適用於不支援 cookie 的客戶端 |

### 6.3 跨設備同步

| 功能 | API 端點 | 說明 |
|------|---------|------|
| 收藏列表 | `GET /favorites` | 需要登入 |
| 播放歷史 | `GET /user/my-stats` | 需要登入 |
| 搜尋歷史 | `GET /searchhistory` | 需要登入 |

---

## 7. 播放器策略

### 7.1 播放器選擇

| 平台 | 播放器 | 技術 |
|------|--------|------|
| Android TV | media_kit | ExoPlayer (原生) |
| iOS/tvOS | media_kit | AVPlayer (原生) |
| Android Mobile | media_kit | ExoPlayer |
| macOS | media_kit | AVPlayer (macOS) |
| Web | media_kit | HTML5 video |

### 7.2 播放器功能

| 功能 | 說明 |
|------|------|
| VOD 播放 | HLS/DASH 串流 |
| 進度控制 | 播放進度儲存 |
| 集數選擇 | 多集切換 |
| 來源切換 | 熱切換不中斷播放 |
| 速度控制 | 0.5x - 2.0x |
| IPTV 直播 | M3U8 HLS |

---

## 8. TV 特定需求

### 8.1 Android TV / GoogleTV 配置

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-feature
    android:name="android.software.leanback"
    android:required="true" />

<uses-feature
    android:name="android.hardware.touchscreen"
    android:required="false" />

<intent-filter>
    <action android:name="android.intent.action.MAIN" />
    <category android:name="android.intent.category.LEANBACK_LAUNCHER" />
</intent-filter>
```

### 8.2 Focus 管理

Flutter 中 TV 的 Focus 管理：

```dart
// 使用 FocusNode 管理 focus
class TVFocusable extends StatefulWidget {
  // D-pad 導航自動支援
  // hasFocus = true 時顯示 focus ring
}
```

### 8.3 遙控器按鍵

| 按鍵 | 動作 |
|------|------|
| OK | 確認/選擇 |
| Back | 返回 |
| D-pad | 導航 |
| Play/Pause | 播放控制 |
| Fast Forward | 快進 |
| Rewind | 快退 |

---

## 9. 工期估算

| 階段 | 內容 | 工期 |
|------|------|------|
| Phase 0 | 詳細技術規格、Flutter 專案初始化 | 1 週 |
| Phase 1 | 核心播放 + LunaTV API 整合 + 基本 UI | 4-6 週 |
| Phase 2 | IPTV、搜尋、收藏功能 | 4-6 週 |
| Phase 3 | 登入系統、跨設備同步、UI 優化 | 2-4 週 |
| Phase 4 | 發布、平台特定優化 | 1-2 週 |

**總工期估算**: 3-4 個月（全職 1 人團隊）

---

## 10. 與 OrionTV 的差異

| 面向 | OrionTV | whiteTV (新) |
|------|---------|-------------|
| 前端框架 | React Native TVOS (社群 fork) | Flutter |
| 影片播放 | Expo AV | media_kit |
| 後端 | 無（純外部 API） | LunaTV API + 設定頁 |
| 跨平台 | iOS/Android TV 為主 | 全部 6+ 平台 |
| 登入系統 | 無 | LunaTV cookie 認證 |
| 來源選擇 | 手動切換 | 自動最快 + 手動 |
| 可維護性 | 社群 fork 版本落後 | 主線 Flutter，穩定 |

---

## 11. 關鍵決策摘要

| 決策 | 選擇 | 原因 |
|------|------|------|
| **前端框架** | Flutter | 官方 Android TV 支援，無社群 fork 依賴 |
| **不選 React Native** | — | tvOS 不需要，RN 對 Android TV 需社群 fork |
| **後端** | 純客戶端 + LunaTV API | 直接利用 LunaTV 功能，無需自建 |
| **登入** | LunaTV cookie 認證 | 支援跨設備同步 |
| **影片播放** | media_kit | 跨平台統一、成熟穩定 |
| **來源選擇** | 自動最快 + 手動切換 | 體驗最佳 |

---

*文件版本: v2.0 — 經過 grill-with-docs 審查後更新*
