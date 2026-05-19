# whiteTV — 系統架構規劃文件 (v1.0)

**專案目標**: 以單一前端程式碼基底，實作跨平台影視串流客戶端，取代 OrionTV
**資料來源**: LunaTV / MoonTV 後端 API (TVBox JSON 格式)
**覆蓋平台**: macOS / iPad / iPhone / Android 手機平板 / Android TV / Google TV / Apple TV
**文件狀態**: v1.0
**最後更新**: 2026-05-19

---

## 1. 專案背景與需求理解

### 1.1 核心需求

| 需求 | 說明 |
|------|------|
| **單一前端框架** | 維護一套前端程式碼，支援所有目標平台 |
| **後端資料來源** | 來自 LunaTV/MoonTV 的 API (TVBox JSON 格式) |
| **完全取代 OrionTV** | 重新設計 OrionTV 成為功能完整的跨平台 client |
| **支援 LunaTV 新功能** | IPTV、網盤搜尋、AI 推薦、彈幕、YouTube 整合等 |

### 1.2 OrionTV 現況

OrionTV 目前使用 React Native TVOS + Expo，缺點：
- React Native TVOS 社群 fork 版本更新落後
- Expo AV 影片播放能力有限
- 無後端整合，純前端只能呼叫外部 API
- 無法完整支援 LunaTV 的新功能（如彈幕同步、Watch Room）

### 1.3 為何需要單一前端框架

你明確要求「維護一套前端架構」，這排除了以下方案：
- Jetpack Compose TV (Kotlin only，無法與 Swift 共享)
- SwiftUI (Apple only，無法與 Android 共享)
- Flutter (tvOS 支援不完整，詳見下方分析)

**唯一能真正實現「一套程式碼支援所有平台」的框架是 React Native**。

---

## 2. 前端框架比較

### 2.1 跨平台框架 TV 支援總覽

| 框架 | Android TV | Apple tvOS | iOS | Android 手機 | macOS | Web |
|------|------------|------------|-----|--------------|-------|-----|
| **React Native (推薦)** | 原生支援 | 原生支援 (react-native-tvos) | 原生 | 原生 | 原生 | 原生 |
| Flutter | 原生支援 | **實驗性/不完整** | 原生 | 原生 | 原生 | 原生 |
| Kotlin Multiplatform | UI 需分開 | Swift 互通有限 | Swift 互通 | 共享 business logic | Swift 互通 | JS 編譯可選 |
| SwiftUI | — | Apple only | Apple only | Apple only | Apple only | — |

### 2.2 Flutter 為何不適合 TV (特別是 Apple TV)

Flutter 官方對 tvOS 的支援**極為有限**：
- 無官方 tvOS 平台目標
- 社群有非官方 port，但穩定性存疑
- 無法通過 Apple App Store TV 認證
- Google 對 Flutter TV 的投入主要在 Android TV，Apple TV 完全沒有官方支援

**來源依據**: Flutter 社群討論、GitHub Issues、LinkedIn 開發者回饋均指出 Flutter 的 tvOS 支援落後且不完整。

### 2.3 React Native 的 TV 支援現況

```
react-native-tvos (社群維護 fork)
├── Android TV ✓ (原生支援)
├── tvOS ✓ (原生支援)
├── firetv ✓ (原生支援)
├── Web ✓ (React Native Web)
├── Windows/UWP ✓
└── macOS ✓
```

**重要**: Expo SDK 54 (2025) 已正式支援 Apple TV (實驗性) 和 Android TV (完整支援)。`expo-video` 已支援 tvOS 平台。

### 2.4 我們的推薦：React Native + Expo

| 組件 | 選擇 | 理由 |
|------|------|------|
| 核心框架 | React Native 0.76+ | 唯一支援所有目標平台 (Android TV + tvOS + iOS + Android Mobile + macOS + Web) |
| 開發工具 | Expo SDK 55+ | 簡化 TV 構建流程，expo-video 原生支援 tvOS |
| 影片播放 | expo-video / react-native-video | ExoPlayer (Android) + AVPlayer (iOS) 自動切換 |
| 路由 | Expo Router | 跨平台檔案路由，TV 支援良好 |
| 狀態管理 | Zustand | 輕量、TV 友善 |
| 導航 | React Navigation | 支援 TV focus management |
| HTTP Client | axios / ky | 全平台統一 |

---

## 3. 後端架構

### 3.1 後端定位

whiteTV 是客戶端專案，**後端直接使用 LunaTV 的現有 API**，不需自建完整後端。

```
                    ┌─────────────────────────────┐
                    │       LunaTV Backend       │
                    │  (ghcr.io/moontechlab/      │
                    │   lunatv:latest)            │
                    │                             │
                    │  - Next.js 14 App Router   │
                    │  - Node.js API             │
                    │  - TMDB / 網盤聚合          │
                    │  - TVBox JSON API           │
                    └─────────────────────────────┘
                                   │
                         Standard TVBox JSON API
                                   │
                    ┌──────────────┴──────────────┐
                    │       whiteTV Client        │
                    │    (React Native + Expo)   │
                    └─────────────────────────────┘
```

### 3.2 LunaTV API 格式 (TVBox JSON)

LunaTV/MoonTV 使用標準 TVBox JSON API 格式：

```
Base URL: http://lunatv-server:3000/api/vod/

GET /list              → 電影/劇集列表 (分頁)
GET /detail/{id}       → 內容詳情 (含播放來源)
GET /search?q={q}      → 搜尋
GET /categories        → 分類列表
GET /random            → 隨機推薦
```

**IPTV 格式 (M3U)**:

```
GET /iptv/list         → M3U 播放列表
GET /iptv/epg          → EPG 電子節目表
```

### 3.3 自建輕量後端的需求

若 LunaTV 的 API 無法完全滿足，僅需建立一個**中介 Proxy 服務**：

| 需求 | 方案 |
|------|------|
| 快取 TMDB 回應 | Redis 30min TTL |
| 使用者認證/同步 | 自建 Go auth service |
| 跨設備進度同步 | 自建 Sync service |
| 彈幕 WebSocket | 自建 Danmaku gateway |
| 網盤登入驗證 | 自建 oauth proxy |

**但不需重構整個內容聚合系統** — 直接使用 LunaTV 的現成 API。

### 3.4 推薦的後端架構

```
┌────────────────────────────────────────────────────────┐
│                    LunaTV Backend                      │
│         (ghcr.io/moontechlab/lunatv:latest)            │
│              完整內容聚合 + TVBox API                   │
└────────────────────────────────────────────────────────┘
                          │
         ┌────────────────┴────────────────┐
         │     whiteTV Backend Proxy         │
         │          (Go, 可選)              │
         ├──────────────────────────────────┤
         │ • JWT 認證 + Refresh Token        │
         │ • 觀看進度跨設備同步              │
         │ • 彈幕 WebSocket 閘道器           │
         │ • Redis 快取層                   │
         │ • 網盤 OAuth 代理                │
         └──────────────────────────────────┘
```

---

## 4. 前端架構詳細設計

### 4.1 專案結構 (monorepo)

```
whiteTV/
├── apps/
│   ├── client/              # React Native + Expo 主體
│   │   ├── app/             # Expo Router pages
│   │   ├── components/      # 跨平台元件
│   │   ├── screens/         # 各畫面
│   │   ├── stores/          # Zustand 狀態
│   │   ├── services/        # API / Storage / WebSocket
│   │   ├── hooks/           # 自訂 hooks
│   │   ├── utils/           # 工具函數
│   │   ├── platform/        # 平台特定程式碼
│   │   │   ├── tv/          # TV 特定 (focus management)
│   │   │   ├── mobile/      # 手機特定
│   │   │   └── web/         # Web 特定
│   │   └── assets/          # 圖片/字體
│   │
│   └── proxy/               # Go 後端代理 (可選)
│       ├── auth/
│       ├── sync/
│       └── danmaku/
│
├── packages/
│   └── shared/              # 共享邏輯 (TypeScript)
│       ├── models/          # 資料模型
│       ├── api/             # API client
│       └── utils/
│
├── docs/
│   └── survey/
│
└── docker/
    └── docker-compose.yml   # 開發環境
```

### 4.2 支援平台與輸出

| 平台 | 建置目標 | 輸出 |
|------|---------|------|
| Android TV | `android tv` | APK / AAB |
| Google TV | `android tv` | APK / AAB |
| Fire TV | `android tv` | APK |
| Apple tvOS | `appletv simulator` | .app bundle |
| iOS | `ios` | .app bundle |
| iPadOS | `ios` | .app bundle |
| Android Mobile | `android` | APK |
| macOS | `macos` | .app bundle |
| Web | `web` | PWA (static) |

### 4.3 影片播放器策略

| 平台 | 播放器 | 技術 |
|------|--------|------|
| Android TV | expo-video / react-native-video | Media3 ExoPlayer (原生) |
| iOS/tvOS | expo-video / react-native-video | AVPlayer (原生) |
| Android Mobile | expo-video | Media3 ExoPlayer |
| macOS | expo-video | AVPlayer (macOS) |
| Web | Video.js / plyr.js | HLS.js / 原生 |

**注意**: OrionTV 原本使用 Expo AV，但 `expo-video` (Expo SDK 53+) 是其進化版，支援更多平台且效能更好。

### 4.4 平台特定適配

雖然使用同一 codebase，但需要針對 TV 平台進行特定優化：

```
src/platform/tv/           # TV 專用
├── TVFocusManager.ts      # Focus ring 管理
├── TVRemoteHandler.ts     # 遙控器按鍵處理
├── DPadNavigation.ts      # D-pad 導航邏輯
└── TVRemoteControlServer.ts  # 外部控制 server

src/platform/mobile/      # 手機專用
├── GestureHandler.ts      # 手勢導航
└── TouchNavigation.ts

src/platform/web/          # Web 專用
├── PWAConfig.ts
└── BrowserRemoteHandler.ts
```

### 4.5 關鍵依賴

```json
{
  "dependencies": {
    "expo": "~55.0.0",
    "expo-video": "~7.0.0",
    "expo-router": "~5.0.0",
    "react-native": "0.78.0",
    "react-native-tvos": "0.78.0",
    "zustand": "^5.0.0",
    "@react-navigation/native": "^7.0.0",
    "@react-navigation/native-stack": "^7.0.0",
    "react-native-reanimated": "^4.0.0",
    "react-native-gesture-handler": "^2.20.0"
  }
}
```

---

## 5. 與 LunaTV 功能的對應

### 5.1 LunaTV 功能 vs whiteTV 實作方式

| LunaTV 功能 | whiteTV 實作 | 說明 |
|------------|-------------|------|
| **TMDB 內容** | 直接呼叫 LunaTV API | 內容聚合由 LunaTV 處理 |
| **網盤搜尋** | LunaTV API proxy | 白標用戶無需自行實作爬蟲 |
| **IPTV 直播** | M3U player | expo-video 支援 HLS 直播 |
| **Bangumi 動漫** | 分類/標籤過濾 | 透過 LunaTV 分類 API |
| **AI 推薦** | 自建 AI service 或 LunaTV API | 建議自建 proxy 以控制模型 |
| **短劇功能** | 專用 Tab | 透過 LunaTV 內容類型篩選 |
| **彈幕系統** | 自建 WebSocket gateway | 需獨立 service |
| **Watch Room** | WebSocket sync | 需獨立 service |
| **YouTube 整合** | WebView / Native player | 個別實作 |
| **觀看統計** | 自建 sync service | 使用者進度追蹤 |
| **收藏/願望清單** | 自建 auth + sync service | 使用者資料持久化 |

### 5.2 後端需求矩陣

| 功能 | 需自建 | 使用 LunaTV |
|------|--------|------------|
| 內容聚合/搜尋 | 否 | 是 |
| 使用者認證 | 可選 | LunaTV 有 Basic auth |
| 收藏/願望清單 | 可選 | LunaTV 有基本支援 |
| 跨設備同步 | **是** | 否 (需即時同步) |
| 彈幕 | **是** | 否 |
| Watch Room | **是** | 否 |
| AI 推薦 | **是** (建議) | 部分 |

---

## 6. 技術選型總結

### 6.1 前端

| 項目 | 選擇 | 原因 |
|------|------|------|
| **框架** | React Native 0.78 + Expo SDK 55 | 唯一真正支援所有平台的單一 codebase |
| **影片播放** | expo-video 7.x | 跨平台 ExoPlayer/AVPlayer，支援 tvOS |
| **路由** | Expo Router | 檔案路由，TV 支援良好 |
| **狀態管理** | Zustand 5.x | 輕量、TV 友好 |
| **導航** | React Navigation 7.x | 完整的 focus management |
| **動畫** | Reanimated 4.x | 60fps TV 動畫 |
| **圖片** | expo-image | 跨平台、TV 優化 |

### 6.2 後端 (自建部分)

| 服務 | 語言 | 框架 | 用途 |
|------|------|------|------|
| **Auth Proxy** | Go | Fiber | JWT 認證、用戶管理 |
| **Sync Service** | Go | Fiber + Redis | 觀看進度同步 |
| **Danmaku Gateway** | Go | Fiber + WebSocket | 即時彈幕 |

### 6.3 資料庫 (自建部分)

| 用途 | 選擇 |
|------|------|
| 使用者資料/進度 | PostgreSQL 17 + pgvector |
| 快取 | Redis 7 |
| 即時訊息 | Redis Pub/Sub 或直接 WebSocket |

### 6.4 基礎設施

| 組件 | 選擇 |
|------|------|
| 部署 | Docker Compose (dev) / Kubernetes (prod) |
| 後端 | LunaTV Docker + whiteTV Go proxy |
| CI/CD | GitHub Actions |

---

## 7. 部署架構

### 7.1 開發環境

```yaml
# docker-compose.yml
services:
  # LunaTV 後端
  lunatv:
    image: ghcr.io/moontechlab/lunatv:latest
    ports: ["3000:3000"]
    environment:
      - API_KEY=your_tmdb_key
      - PUID=1000
      - PGID=1000
    volumes:
      - ./data:/data

  # whiteTV 後端代理 (可選)
  whitetv-proxy:
    build: ./apps/proxy
    ports: ["8080:8080"]
    depends_on: [lunatv]
    environment:
      - LUNATV_URL=http://lunatv:3000
      - JWT_SECRET=your_secret

  # 資料庫
  postgres:
    image: pgvector/pgvector:pg17
    environment:
      POSTGRES_DB: whitetv
      POSTGRES_PASSWORD: dev_password
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine

volumes:
  pgdata:
```

### 7.2 生產環境建議

| 規模 | 架構 |
|------|------|
| 個人/小型 | VPS + Docker Compose + LunaTV Docker |
| 中型 | Kubernetes + 負載平衡 + PostgreSQL 托管 |
| 大型 | 多節點 K8s + CDN + 托管資料庫 |

---

## 8. 工期估算

| 階段 | 內容 | 工期 |
|------|------|------|
| Phase 0 | 詳細技術規格、API 對接規劃 | 1-2 週 |
| Phase 1 | React Native TV 骨架 + 核心播放 + LunaTV API 整合 | 6-8 週 |
| Phase 2 | IPTV、搜尋、收藏功能 | 4-6 週 |
| Phase 3 | 自建後端 (Auth、Sync、Danmaku) | 4-6 週 |
| Phase 4 | Web PWA、發布 |

**總工期估算**: 4-6 個月 (全職 1-2 人團隊)

---

## 9. 與 OrionTV 的差異

| 面向 | OrionTV | whiteTV (新) |
|------|---------|-------------|
| 前端框架 | React Native TVOS | React Native 0.78 + Expo SDK 55 |
| 影片播放 | Expo AV | expo-video (更新、效能更好) |
| 後端 | 無 (純外部 API) | LunaTV API + 可選 Go proxy |
| 跨平台 | iOS/Android TV 為主 | 所有 8+ 平台 |
| 功能完整性 | 基本串流 | 完整 LunaTV 功能支援 |
| 可維護性 | 社群 fork | 主線 RN 版本，更穩定 |

---

## 10. 關鍵決策摘要

| 決策 | 選擇 | 原因 |
|------|------|------|
| **前端框架** | React Native + Expo | 唯一支援所有 8+ 平台的單一 codebase |
| **不選 Flutter** | — | Flutter 無完整 tvOS 支援，無法滿足需求 |
| **不選 SwiftUI** | — | Apple only，違反單一 codebase 要求 |
| **影片播放** | expo-video | 跨平台統一、tvOS 支援 |
| **後端** | LunaTV API + 自建 proxy | 直接利用 LunaTV 內容聚合，無需重複造輪 |
| **自建服務** | Auth、Sync、Danmaku | 即時功能無法依賴 LunaTV 現有 API |

---

*文件版本: v1.0 — 供內部審視與討論*