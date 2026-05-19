# LunaTV API 完整參考文檔

**來源**: https://github.com/SzeMeng76/LunaTV  
**版本**: v6.6.0  
**更新日期**: 2026-05-19

---

## 1. API 概述

### 1.1 Base URL

```
http://lunatv-server:3000/api/
```

### 1.2 認證方式

| 方式 | 說明 |
|------|------|
| **Cookie** | 預設，透過登入取得並保存 |
| **Token** | 可選，TVBox token 適用於不支援 cookie 的客戶端 |

### 1.3 請求格式

所有 API 返回 JSON 格式。部分 API 需要認證（透過 cookie）。

---

## 2. 影視 API（VOD）

### 2.1 搜尋

```
GET /api/search?q={query}
```

**需要認證**: 是

**參數**:
| 參數 | 類型 | 說明 |
|------|------|------|
| `q` | string | 搜尋關鍵詞 |

**響應**:
```json
{
  "results": [
    {
      "id": "12345",
      "title": "影片標題",
      "poster": "https://...",
      "year": "2024",
      "source": "lovedan",
      "source_name": "量子資源",
      "type": "movie",
      "remarks": "HD"
    }
  ]
}
```

### 2.2 詳情

```
GET /api/detail?id={id}&source={sourceCode}&title={title}
```

**需要認證**: 是

**參數**:
| 參數 | 類型 | 說明 |
|------|------|------|
| `id` | string | 影片 ID |
| `source` | string | 來源標識 |
| `title` | string | 標題（可選） |

**響應**:
```json
{
  "id": "12345",
  "title": "影片標題",
  "poster": "https://...",
  "desc": "劇情簡介...",
  "year": "2024",
  "area": "地區",
  "director": "導演",
  "actor": "演員",
  "type": "movie",
  "episodes": [
    {
      "index": 1,
      "label": "第1集",
      "urls": [
        {
          "name": "量子資源",
          "url": "https://..."
        }
      ]
    }
  ]
}
```

### 2.3 分類列表

```
GET /api/douban/categories
```

**需要認證**: 否

**響應**:
```json
{
  "categories": [
    { "type_id": 1, "type_name": "電影" },
    { "type_id": 2, "type_name": "電視劇" },
    { "type_id": 3, "type_name": "綜藝" },
    { "type_id": 4, "type_name": "動漫" }
  ]
}
```

### 2.4 首頁推薦

```
GET /api/douban/route
```

**需要認證**: 否

---

## 3. TVBox API

### 3.1 標準模式

```
GET /api/tvbox?format=json
```

**需要認證**: 可選（建議）

**參數**:
| 參數 | 說明 |
|------|------|
| `format` | `json` 或 `base64` |
| `mode` | `standard`（默認）, `safe`（精簡）, `fast`（快速）, `yingshicang`（影視倉） |
| `token` | TVBox token（可選） |
| `adult` | `1` 或 `0`，是否顯示成人內容 |

**響應**:
```json
{
  "spider": "https://...",
  "wallpaper": "https://...",
  "sites": [
    {
      "key": "lovedan",
      "name": "量子資源",
      "type": 1,
      "api": "https://lovedan.net/api.php",
      "searchable": 1,
      "quickSearch": 1,
      "filterable": 1
    }
  ],
  "lives": [
    {
      "name": "央視",
      "type": 1,
      "url": "https://...",
      "epg": "https://..."
    }
  ],
  "flags": ["BD", "HD", "SD"],
  "parses": []
}
```

### 3.2 直播源

```
GET /api/tvbox?format=json&mode=live
```

**響應**:
```json
{
  "lives": [
    {
      "name": "頻道名稱",
      "type": 1,
      "url": "https://.../live.m3u8",
      "epg": "https://.../epg.xml",
      "logo": "https://..."
    }
  ]
}
```

### 3.3 來源測試

```
GET /api/source-test
```

**響應**:
```json
{
  "sources": [
    {
      "key": "lovedan",
      "name": "量子資源",
      "available": true,
      "latency": 120
    }
  ]
}
```

---

## 4. IPTV 直播 API

### 4.1 直播列表

```
GET /api/iptv/list
```

**需要認證**: 否

**響應**:
```json
{
  "channels": [
    {
      "name": "CCTV-1",
      "logo": "https://...",
      "url": "https://.../live.m3u8"
    }
  ]
}
```

### 4.2 EPG 節目表

```
GET /api/iptv/epg
```

**需要認證**: 否

**響應**:
```json
{
  "channels": [
    {
      "name": "CCTV-1",
      "programs": [
        {
          "start": "2024-01-01T00:00:00Z",
          "end": "2024-01-01T01:00:00Z",
          "title": "新聞聯播"
        }
      ]
    }
  ]
}
```

---

## 5. 使用者 API（需要認證）

### 5.1 收藏列表

```
GET /api/favorites
```

**需要認證**: 是（cookie）

**響應**:
```json
{
  "favorites": {
    "lovedan+12345": {
      "title": "影片標題",
      "cover": "https://...",
      "source_name": "量子資源",
      "total_episodes": 24,
      "year": "2024",
      "search_title": "搜尋標題",
      "save_time": 1704067200000,
      "origin": "vod",
      "type": "tv",
      "remarks": "更新至12集"
    }
  }
}
```

### 5.2 添加收藏

```
POST /api/favorites
```

**Body**:
```json
{
  "key": "lovedan+12345",
  "favorite": {
    "title": "影片標題",
    "cover": "https://...",
    "source_name": "量子資源",
    "total_episodes": 24,
    "year": "2024",
    "search_title": "搜尋標題"
  }
}
```

### 5.3 刪除收藏

```
DELETE /api/favorites?key={source+id}
```

### 5.4 搜尋歷史

```
GET /api/searchhistory
```

**需要認證**: 是

**響應**:
```json
{
  "history": ["關鍵詞1", "關鍵詞2"]
}
```

### 5.5 使用者統計

```
GET /api/user/my-stats
```

**需要認證**: 是

**響應**:
```json
{
  "stats": {
    "totalFavorites": 50,
    "totalWatchTime": 3600,
    "continueWatch": [
      {
        "title": "影片標題",
        "source_name": "量子資源",
        "cover": "https://...",
        "year": "2024",
        "index": 5,
        "total_episodes": 24,
        "play_time": 1800,
        "total_time": 3600,
        "save_time": 1704067200000
      }
    ]
  }
}
```

---

## 6. 其他 API

### 6.1 短劇

```
GET /api/shortdrama/list
GET /api/shortdrama/search?q={query}
GET /api/shortdrama/detail?id={id}
```

### 6.2 AI 推薦

```
GET /api/ai-recommend
```

### 6.3 YouTube

```
GET /api/youtube/search?q={query}
GET /api/youtube/popular
```

### 6.4 Emby

```
GET /api/emby/list
GET /api/emby/detail?id={id}
```

---

## 7. 響應格式總結

### 7.1 成功響應

```json
{
  "code": 0,
  "data": { ... }
}
```

### 7.2 錯誤響應

```json
{
  "code": 401,
  "error": "Unauthorized"
}
```

### 7.3 分頁響應

```json
{
  "page": 1,
  "limit": 20,
  "total": 100,
  "data": [ ... ]
}
```

---

## 8. 錯誤碼

| 錯誤碼 | 說明 |
|--------|------|
| 0 | 成功 |
| 400 | 參數錯誤 |
| 401 | 未授權（需要登入） |
| 403 | 被封禁 |
| 404 | 資源不存在 |
| 429 | 請求過於頻繁 |
| 500 | 服務器錯誤 |

---

## 9. 認證流程

### 9.1 登入

```
POST /api/auth/login
Body: { "username": "xxx", "password": "xxx" }
```

**響應**: Set-Cookie header

### 9.2 後續請求

在請求中攜帶 cookie：
```
Cookie: auth=<token>
```

---

## 10. Client 實作注意事項

### 10.1 儲存認證

```dart
// 儲存登入 cookie
await flutterSecureStorage.write(key: 'auth_cookie', value: cookie);

// 請求時附加 cookie
final response = await dio.get(
  '$baseUrl/api/search',
  options: Options(headers: {'Cookie': cookie}),
);
```

### 10.2 來源速度測試

```dart
Future<int> testSourceLatency(String url) async {
  final stopwatch = Stopwatch()..start();
  try {
    await Dio().head(url);
    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  } catch {
    return 999999; // 不可用
  }
}
```

### 10.3 快取策略

| API | 快取時間 |
|-----|----------|
| `/api/tvbox` | 2 小時 |
| `/api/search` | 短暫或不快取 |
| `/api/favorites` | 不快取（用戶數據） |
| `/api/iptv/*` | 30 分鐘 |

---

*文檔基於 LunaTV v6.6.0 原始碼分析*
