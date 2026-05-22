# 統一輸入系統設計規格 (Unified Input System)

**專案**: whiteTV 跨平台影視串流客戶端
**版本**: v1.0
**日期**: 2026-05-22
**作者**: whiteTV Team

---

## 1. 概述

### 1.1 目標

建立一個**統一的 TV 輸入系統**，讓所有需要文字輸入的場景（登入、搜尋、設定等）都使用同一套機制，解決 TV 遙控器輸入不便的問題。

### 1.2 技術方案

**完全 client-side 實現**，使用 Flutter 內建 `shelf` 套件建立本地 HTTP 伺服器，手機透過瀏覽器掃描 QR Code 進行文字輸入。

### 1.3 優勢

| 優勢 | 說明 |
|------|------|
| 完全 client-side | 不需要 LunaTV 後端修改 |
| 延遲低 | 同一區網直接溝通，毫秒級響應 |
| 離線可用 | 即使 LunaTV 伺服器關閉，輸入功能仍正常 |
| 復用性高 | 所有需要文字輸入的場景都可以用 |
| 安全性 | 祇有同一 WiFi 的設備能連接 |

---

## 2. 架構設計

### 2.1 系統架構圖

```
┌─────────────────────────────────────────────────────┐
│                    TV (Flutter App)                 │
│                                                     │
│  ┌─────────────────┐     ┌───────────────────────┐ │
│  │   InputService   │────▶│  InputScreen / Widget │ │
│  │   (Singleton)    │     │  (即時顯示輸入內容)    │ │
│  └────────┬────────┘     └───────────────────────┘ │
│           │                                           │
│  ┌────────▼────────┐                                │
│  │  LocalHttpServer │◀─── 手機瀏覽器 POST           │
│  │  (Shelf, Port 8080)│     /input                  │
│  └─────────────────┘                                │
└─────────────────────────────────────────────────────┘
           ▲
           │ (同一 WiFi, HTTP)
    ┌──────┴──────┐
    │   Phone     │
    │  Browser    │
    └─────────────┘
```

### 2.2 組件列表

| 組件 | 路徑 | 職責 |
|------|------|------|
| `InputService` | `lib/core/services/input_service.dart` | 統一輸入服務，管理工作階段 |
| `LocalHttpServer` | `lib/core/services/local_http_server.dart` | Shelf HTTP 伺服器 |
| `SessionManager` | `lib/core/services/session_manager.dart` | 管理 QR Session 狀態 |
| `InputScreen` | `lib/features/settings/presentation/screens/input_screen.dart` | TV 顯示 QR 和輸入狀態 |
| `QrInputWidget` | `lib/shared/widgets/qr_input_widget.dart` | QR Code 產生器 |

---

## 3. 功能詳細設計

### 3.1 InputService API

```dart
class InputService {
  // 啟動本地 HTTP 伺服器
  Future<void> startServer({int port = 8080});

  // 停止伺服器
  Future<void> stopServer();

  // 取得 QR Code URL
  String getQrCodeUrl();

  // 取得輸入內容串流
  Stream<String> get inputStream;

  // 取得當前輸入內容
  String get currentInput;

  // 清除輸入
  void clearInput();

  // 設定輸入完成後的回調
  void setOnInputComplete(void Function(String) callback);

  // 伺服器是否運行中
  bool get isRunning;
}
```

### 3.2 輸入流程

```
1. 使用者觸發輸入（點擊「使用手機輸入」）
       ↓
2. InputService.startServer()
       ↓
3. LocalHttpServer 啟動，監聽 port 8080
       ↓
4. 取得 TV 區網 IP（如 192.168.1.100）
       ↓
5. 生成 Session ID + QR Code URL
       ↓
6. 顯示 InputScreen（QR Code + 等待提示）
       ↓
7. 手機掃描 QR → 開啟瀏覽器 → 顯示 HTML 輸入頁面
       ↓
8. 手機輸入文字 → POST /input → TV 接收
       ↓
9. InputService 廣播輸入內容 → UI 即時顯示
       ↓
10. 使用者完成 → 點擊「完成」→ 觸發回調 → stopServer()
```

### 3.3 手機 HTML 輸入頁面

當手機掃描 QR Code，開啟 `http://{tv_ip}:8080/` 時，显示：

```html
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>whiteTV 輸入</title>
  <style>
    body { font-family: -apple-system, sans-serif; padding: 20px; background: #1a1a1a; color: #fff; }
    input { width: 100%; padding: 15px; font-size: 18px; border-radius: 8px; border: none; margin: 10px 0; }
    button { padding: 15px 30px; font-size: 18px; border-radius: 8px; border: none; cursor: pointer; }
    .send { background: #ffb347; color: #000; }
    .clear { background: #666; color: #fff; }
  </style>
</head>
<body>
  <h2>whiteTV 輸入</h2>
  <input type="text" id="inputField" placeholder="輸入文字..." autofocus>
  <button class="send" onclick="send()">發送</button>
  <button class="clear" onclick="clearInput()">清除</button>

  <script>
    function send() {
      const text = document.getElementById('inputField').value;
      if (text) {
        fetch('/input', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ text })
        });
        document.getElementById('inputField').value = '';
      }
    }
    function clearInput() {
      fetch('/clear', { method: 'POST' });
      document.getElementById('inputField').value = '';
    }
  </script>
</body>
</html>
```

### 3.4 HTTP 端點

| Method | Path | 說明 |
|--------|------|------|
| GET | `/` | 返回 HTML 輸入頁面 |
| GET | `/status` | 伺服器狀態（偵錯用） |
| POST | `/input` | 接收手機輸入 `{"text": "..."}` |
| POST | `/clear` | 清除輸入內容 |
| POST | `/complete` | 通知輸入完成 |

---

## 4. 使用場景

### 4.1 登入頁（TV Full Screen, Mobile Modal）

```
┌──────────────────────────────────────────────────┐
│  ← 返回                         登入            │
├──────────────────────────────────────────────────┤
│                                                   │
│         ┌─────────────────────────┐              │
│         │                         │              │
│         │      QR Code            │              │
│         │   (掃描以輸入帳密)       │              │
│         │                         │              │
│         └─────────────────────────┘              │
│                                                   │
│         [切換至遙控器輸入]                        │
│                                                   │
└──────────────────────────────────────────────────┘
```

### 4.2 搜尋頁（TV 統一輸入）

```
┌──────────────────────────────────────────────────┐
│  🔍 搜尋                                    [X]  │
├──────────────────────────────────────────────────┤
│                                                   │
│  [使用手機輸入]                                  │
│                                                   │
└──────────────────────────────────────────────────┘
```

### 4.3 無 WiFi 降級

當偵測到 TV 無法取得有效 IP 或 WiFi 不可用時：

```
┌──────────────────────────────────────────────────┐
│  ⚠️ 無法使用手機輸入                            │
│                                                   │
│  請確認 TV 和手機連接同一 WiFi                   │
│                                                   │
│         [使用遙控器輸入]                          │
│                                                   │
└──────────────────────────────────────────────────┘
```

---

## 5. 錯誤處理

| 情況 | 處理方式 |
|------|----------|
| Port 8080 被佔用 | 自動嘗試 8081, 8082... 遞增 |
| 無法取得區網 IP | 顯示錯誤，引導用戶使用遙控器輸入 |
| 手機連線失敗 | 顯示「確認同一 WiFi」提示 |
| Server 崩潰 | 自動重啟，嘗試恢復輸入狀態 |
| 輸入超時（5分鐘） | 自動關閉 Server，提示用戶 |

---

## 6. 檔案結構

```
lib/
├── core/
│   └── services/
│       ├── input_service.dart      # 統一輸入服務
│       ├── local_http_server.dart  # Shelf HTTP 伺服器
│       └── session_manager.dart    # Session 管理
├── features/
│   └── settings/
│       └── presentation/
│           └── screens/
│               └── input_screen.dart  # TV 輸入畫面
└── shared/
    └── widgets/
        └── qr_input_widget.dart     # QR Code 元件

test/
├── unit/
│   ├── input_service_test.dart
│   └── session_manager_test.dart
├── integration/
│   └── local_http_server_test.dart
└── features/
    └── settings/
        └── input_screen_test.dart
```

---

## 7. 依賴套件

```yaml
# pubspec.yaml
dependencies:
  # HTTP Server (Flutter 內建)
  shelf: ^1.4.0
  shelf_router: ^1.1.0

  # 網路相關
  network_info_plus: ^5.0.0

  # QR Code
  qr_flutter: ^4.1.0

dev_dependencies:
  mockito: ^5.4.0
  build_runner: ^2.4.0
```

---

## 8. 測試策略

### 8.1 TDD 测试分层

```
Unit Tests (80%+)
├── InputService 邏輯測試
│   ├── startServer() / stopServer()
│   ├── getQrCodeUrl() 生成
│   ├── currentInput 更新
│   └── inputStream 廣播
├── SessionManager 測試
│   ├── session 創建/過期
│   └── session ID 生成
└── LocalHttpServer 路由測試

Integration Tests
├── Server 啟動/停止
├── HTTP POST → 輸入串流
└── QR Code URL 正確性

BDD Tests (Gherkin)
├── 手機成功輸入文字到 TV.feature
├── TV 正確關閉 Server.feature
├── 無 WiFi 時正確降級.feature
└── 輸入超時自動關閉.feature
```

### 8.2 BDD Scenario 範例

```gherkin
Feature: 統一輸入系統

  Scenario: 手機成功輸入文字到 TV
    Given TV 顯示 QR Code
    When 手機掃描並輸入 "test123"
    Then TV 畫面立即顯示 "test123"

  Scenario: TV 正確關閉 Server
    Given 輸入完成
    When 使用者點擊 "完成"
    Then Local HTTP Server 正確關閉

  Scenario: Port 被佔用時自動切換
    Given Port 8080 被佔用
    When 啟動 InputService
    Then Server 使用 Port 8081
```

---

## 9. 實作順序

| Phase | 內容 | 優先級 |
|-------|------|--------|
| 1 | `SessionManager` + `LocalHttpServer` 核心 | P0 |
| 2 | `InputService` 包裝層 | P0 |
| 3 | `QrInputWidget` QR 顯示 | P0 |
| 4 | `InputScreen` TV 畫面 | P0 |
| 5 | 單元測試 (TDD) | P1 |
| 6 | 整合測試 | P1 |
| 7 | BDD 測試 | P1 |
| 8 | 降級邏輯（無 WiFi） | P2 |

---

## 10. 未來擴展

- **多語言支援**：HTML 輸入頁面支援多語言
- **輸入歷史**：記住最近使用的手機，簡化連線
- **安全性**：加入 PIN 驗證，防止隔壁鄰居輸入

---

*文件版本: v1.0 — 統一輸入系統設計規格*