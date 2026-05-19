# OrionTV 系統架構規劃書

**專案名稱**: OrionTV (重構規劃)  
**版本**: v1.0  
**日期**: 2026-05-19  
**狀態**: 初稿，待審視

---

## 1. 專案願景與目標

基於現有 OrionTV 專案和 LunaTV 的功能參考，重構為一個支援多平台的影片串流應用程式：

### 1.1 核心目標

| 目標 | 說明 |
|------|------|
| **多平台覆蓋** | iOS/iPadOS/macOS、Android Phone/Tablet、Android TV/GoogleTV、Apple TV |
| **統一代碼庫** | 最大程度共用代碼，平台差異透過條件編譯處理 |
| **TV 優先** | 以 TV 體驗為核心，遠端控制為主要輸入方式 |
| **輕量高效** | 針對 TV 效能優化，流暢的 Focus 導航 |

### 1.2 參考專案

- **LunaTV** (https://github.com/SzeMeng76/LunaTV) - 最新功能和 UI 參考
- **OrionTV** (現有) - 現有架構基礎

---

## 2. 技術堆疊

### 2.1 框架選擇

| 層級 | 技術 | 版本 | 決策理由 |
|------|------|------|----------|
| **核心框架** | React Native TVOS | 0.76.x | 官方 TV 支援，New Architecture |
| **開發工具** | Expo | SDK 52+ | 快速迭代，prebuild 生成原生專案 |
| **路由** | Expo Router | 4.x | 檔案系統路由，TV 友好 |
| **影片播放** | expo-av | 14.x | 跨平台影片播放 |
| **狀態管理** | Zustand | 5.x | 輕量，TV 記憶體友好 |
| **資料獲取** | TanStack Query | 5.x | 快取、重試、背景更新 |
| **動畫** | react-native-reanimated | 3.x | 60fps TV 動畫 |
| **導航** | @react-navigation/native | 7.x | 內建 Focus 管理 |

### 2.2 為何選擇 React Native TVOS

```
傳統 React Native + 函式庫                    React Native TVOS
├── 需自行處理 Focus 管理                      ├── 原生 Focus Engine
├── TV 事件需要繁瑣的適配                       ├── 內建 D-pad/Remote 支援
├── 平台差異需手動管理                          ├── Apple TV + Android TV 統一
└── 新 Architecture 需額外配置                  └── New Architecture 預設啟用
```

### 2.3 平台支援矩陣

| 平台 | 設備類型 | 最小 OS | 輸入方式 | UI 變體 |
|------|----------|---------|----------|---------|
| **iOS** | iPhone, iPad | iOS 15+ | 觸控/鍵盤 | mobile.tsx |
| **iPadOS** | iPad | iPadOS 15+ | 觸控/滑鼠 | tablet.tsx |
| **tvOS** | Apple TV | tvOS 15+ | Siri Remote | tv.tsx |
| **Android** | Phone, Tablet | Android 7+ (API 24) | 觸控 | mobile.tsx |
| **Android TV** | Android TV, GoogleTV | Android 9+ (API 28) | D-pad/遙控器 | tv.tsx |
| **Amazon Fire TV** | Fire TV | FireOS 6+ | D-pad/遙控器 | tv.tsx |

---

## 3. 系統架構

### 3.1 整體架構圖

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         展示層 (Presentation)                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │   TV UI     │  │  Mobile UI  │  │  Tablet UI  │  │   Web UI    │       │
│  │ (Focus Nav) │  │  (Touch)    │  │ (Hybrid)    │  │  (Mouse)    │       │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘       │
│                                   │                                        │
├───────────────────────────────────┼───────────────────────────────────────┤
│                         業務邏輯層 (Business Logic)                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │   Zustand   │  │  TanStack   │  │    Auth     │  │   Player    │       │
│  │   Store     │  │    Query    │  │   Service   │  │   Service   │       │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘       │
│                                   │                                        │
├───────────────────────────────────┼───────────────────────────────────────┤
│                         資料層 (Data Layer)                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │   REST API  │  │  WebSocket │  │   Local     │  │   Vector    │       │
│  │  (Streaming)│  │  (Live TV) │  │   Storage   │  │   Search    │       │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘       │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 目錄結構

```
OrionTV/
├── app/                          # Expo Router 頁面
│   ├── _layout.tsx               # 根路由配置
│   ├── index.tsx                 # 首頁
│   ├── detail.tsx                 # 詳情頁
│   ├── play.tsx                  # 播放器頁
│   ├── search.tsx                # 搜尋頁
│   ├── favorites.tsx             # 收藏頁
│   ├── live.tsx                  # 直播頁
│   ├── settings.tsx              # 設定頁
│   └── (platform)/               # 平台特定頁面
│       ├── _layout.tv.tsx        # TV 特定佈局
│       └── _layout.mobile.tsx    # Mobile 特定佈局
│
├── src/
│   ├── features/                 # 功能模組 (FSD 模式)
│   │   ├── home/                 # 首頁功能
│   │   ├── player/               # 播放器功能
│   │   ├── search/               # 搜尋功能
│   │   ├── favorites/            # 收藏功能
│   │   ├── live/                 # 直播功能
│   │   └── settings/             # 設定功能
│   │
│   ├── shared/                   # 共用層
│   │   ├── components/           # 可重用元件
│   │   ├── hooks/                # 自訂 Hooks
│   │   ├── services/             # 服務層
│   │   ├── stores/               # Zustand Stores
│   │   └── utils/                # 工具函數
│   │
│   ├── tv/                       # TV 特定適配
│   └── mobile/                   # Mobile 特定適配
│
├── assets/                       # 靜態資源
├── constants/                    # 常數定義
├── docs/                         # 文件
│   └── init/                     # 本文件
└── tools/                        # 開發工具腳本
```

### 3.3 平台變體模式

```typescript
// 元件組織範例
components/
├── VideoCard/
│   ├── VideoCard.tsx              # 基礎元件
│   ├── VideoCard.tv.tsx           # TV 專用
│   ├── VideoCard.mobile.tsx        # Mobile 專用
│   ├── VideoCard.tablet.tsx       # Tablet 專用
│   └── index.ts                   # 匯出入口
```

---

## 4. 核心功能模組

### 4.1 功能列表

| 模組 | 功能 | 優先級 |
|------|------|--------|
| **首頁** | 分類瀏覽、輪播牆、熱門推薦 | P0 |
| **播放器** | VOD 播放、進度控制、集數選擇 | P0 |
| **播放器** | 來源切換、速度控制 | P1 |
| **直播** | 直播列表、M3U8 解析、EPG | P1 |
| **搜尋** | 即時搜尋、歷史記錄 | P1 |
| **收藏** | 收藏列表、播放記錄 | P0 |
| **設定** | API 配置、播放設定 | P0 |
| **設定** | 遠端控制、版本資訊 | P2 |
| **投屏** | Chromecast/DLNA | P2 |
| **下載** | 離線下載 | P3 |

### 4.2 狀態管理 Stores

| Store | 職責 |
|-------|------|
| **homeStore** | 首頁分類、內容列表、播放記錄 |
| **playerStore** | 播放器狀態、播放進度、當前來源 |
| **settingsStore** | API 配置、使用者偏好設定 |
| **favoritesStore** | 收藏列表 |
| **detailStore** | 詳情頁資料、影片來源列表 |
| **sourceStore** | 可用 API 來源列表 |
| **remoteControlStore** | 遠端控制伺服器狀態 |
| **updateStore** | 版本更新檢查 |

---

## 5. TV 特定需求

### 5.1 Android TV / GoogleTV 配置

```xml
<!-- AndroidManifest.xml 必要配置 -->
<uses-feature
    android:name="android.software.leanback"
    android:required="true" />

<uses-feature
    android:name="android.hardware.touchscreen"
    android:required="false" />
```

### 5.2 Focus 管理模式

```typescript
// TV 元件需要處理 Focus 導航
const TVCard: React.FC<Props> = ({ item, onSelect }) => {
  useTVEventHandler((event) => {
    if (event.eventType === 'select') onSelect(item);
  });
  
  return <View hasTVPreferredFocus={true}>...</View>;
};
```

### 5.3 遙控器按鍵映射

| 按鍵 | 事件 | 動作 |
|------|------|------|
| OK/Select | `select` | 確認/選擇 |
| Back | `back` | 返回 |
| Left/Right | `left`/`right` | 水平導航 |
| Up/Down | `up`/`down` | 垂直導航 |
| Play/Pause | `playPause` | 播放/暫停 |
| Fast Forward | `forward` | 快進 |
| Rewind | `rewind` | 快退 |

---

## 6. 響應式設計

### 6.1 斷點定義

```typescript
const BREAKPOINTS = {
  mobile: 768,      // < 768px: 手機
  tablet: 1024,      // 768px - 1023px: 平板
  tv: 1920,          // ≥ 1024px: TV / 桌面
};
```

### 6.2 設備檢測

```typescript
export const DeviceUtils = {
  getDeviceType(): 'mobile' | 'tablet' | 'tv' {
    const { width } = Dimensions.get('window');
    if (width < BREAKPOINTS.mobile) return 'mobile';
    if (width < BREAKPOINTS.tablet) return 'tablet';
    return 'tv';
  },
  isTV(): boolean { return this.getDeviceType() === 'tv'; },
  isMobile(): boolean { return this.getDeviceType() === 'mobile'; },
};
```

---

## 7. 效能優化策略

| 優化點 | 實作方式 |
|--------|----------|
| Focus 順暢 | 使用 `reanimated` |
| 圖片載入 | `expo-image` + 漸進載入 |
| 列表效能 | FlashList 替代 FlatList |
| 預載入 | 預先載入相鄰內容 |
| 記憶體 | 及時釋放未使用資源 |

---

## 8. 依賴版本規劃

```json
{
  "dependencies": {
    "react-native-tvos": "~0.76.0-0",
    "expo": "~52.0.0",
    "expo-router": "~4.0.0",
    "expo-av": "~15.0.0",
    "zustand": "^5.0.0",
    "@tanstack/react-query": "^5.0.0",
    "react-native-reanimated": "~3.16.0"
  }
}
```

---

## 9. 開發命令

```bash
# TV 模式開發
EXPO_TV=1 yarn start

# 生成原生專案
EXPO_TV=1 yarn prebuild

# Android TV 構建
yarn android

# Apple TV 構建  
yarn ios
```

---

## 10. 待確認事項

在開始實作前需要確認：

| 項目 | 選項 | 建議 |
|------|------|------|
| 是否需要 DRM | Widevine / FairPlay | 根據內容決定 |
| 是否需要登入系統 | OAuth / 簡單 Token | 先行簡易實作 |
| 即時搜尋 API | 第三方 / 自建 | 使用現有後端 |
| 直播技術 | HLS / DASH | HLS (m3u8) |

---

## 11. 下一步行動

| 階段 | 任務 |
|------|------|
| **Phase 1** | 審視本文件，確認架構方向 |
| **Phase 2** | 建立新專案結構，實作程式碼 |
| **Phase 3** | 遷移現有功能 |
| **Phase 4** | 平台特定適配 (TV/Mobile UI) |
| **Phase 5** | 效能優化，生產可用 |

---

## 附錄：相關資源

- [React Native TVOS](https://github.com/react-native-tvos/react-native-tvos)
- [Expo TV Development](https://docs.expo.dev/develop/development-builds/)
- [LunaTV Source](https://github.com/SzeMeng76/LunaTV)
- [Android TV Developer Guide](https://developer.android.com/tv)
- [Apple TV Human Interface Guidelines](https://developer.apple.com/tvos/human-interface-guidelines/)
