# Favorites Sync Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 實現完整的收藏同步系統，使用 Remote-first 策略與 LunaTV API 整合

**Architecture:** 三層架構 - Presentation (Riverpod Store) → Domain (Service Facade) → Data (Remote + Local)
- 同步策略：Remote-first，先拉取 LunaTV 收藏，合併本地變更後上傳
- 未登入時禁用 UI，提示登入對話框

**Tech Stack:** Flutter Riverpod, Dio, SharedPreferences, BDD Testing

---

## Phase 1: 補全現有框架

### Task 1: 補全 FavoritesLocalService 實作

**Files:**
- Modify: `lib/features/favorites/services/favorites_local_service.dart`

- [ ] **Step 1: Write unit tests for FavoritesLocalService**

```dart
// test/features/favorites/services/favorites_local_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/favorites/services/favorites_local_service.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';

void main() {
  group('FavoritesLocalService', () {
    late FavoritesLocalService service;

    setUp(() {
      service = FavoritesLocalService();
    });

    test('save and retrieve favorites', () async {
      final item = FavoriteItem(
        id: '1',
        title: 'Test Movie',
        posterUrl: 'http://example.com/poster.jpg',
        type: 'movie',
        addedAt: DateTime(2026, 5, 29),
      );

      await service.save(item);
      final favorites = await service.getAll();

      expect(favorites.length, 1);
      expect(favorites.first.id, '1');
    });

    test('remove favorite by id', () async {
      final item = FavoriteItem(
        id: '1',
        title: 'Test Movie',
        posterUrl: 'http://example.com/poster.jpg',
        type: 'movie',
        addedAt: DateTime(2026, 5, 29),
      );

      await service.save(item);
      await service.remove('1');
      final favorites = await service.getAll();

      expect(favorites.isEmpty, true);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/favorites/services/favorites_local_service_test.dart`
Expected: FAIL - method not implemented

- [ ] **Step 3: Implement minimal FavoritesLocalService**

```dart
// lib/features/favorites/services/favorites_local_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';

class FavoritesLocalService {
  static const _key = 'favorites_items';

  Future<List<FavoriteItem>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList.map((json) => _fromJson(jsonDecode(json))).toList();
  }

  Future<void> save(FavoriteItem item) async {
    final items = await getAll();
    items.removeWhere((i) => i.id == item.id);
    items.add(item);
    await _saveAll(items);
  }

  Future<void> remove(String id) async {
    final items = await getAll();
    items.removeWhere((i) => i.id == id);
    await _saveAll(items);
  }

  Future<void> _saveAll(List<FavoriteItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((i) => jsonEncode(_toJson(i))).toList();
    await prefs.setStringList(_key, jsonList);
  }

  Map<String, dynamic> _toJson(FavoriteItem item) => {
    'id': item.id,
    'title': item.title,
    'posterUrl': item.posterUrl,
    'type': item.type,
    'isAvailable': item.isAvailable,
    'addedAt': item.addedAt.toIso8601String(),
  };

  FavoriteItem _fromJson(Map<String, dynamic> json) => FavoriteItem(
    id: json['id'] as String,
    title: json['title'] as String,
    posterUrl: json['posterUrl'] as String,
    type: json['type'] as String,
    isAvailable: json['isAvailable'] as bool? ?? true,
    addedAt: DateTime.parse(json['addedAt'] as String),
  );
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/favorites/services/favorites_local_service_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/favorites/services/favorites_local_service.dart test/features/favorites/services/favorites_local_service_test.dart
git commit -m "feat(favorites): implement FavoritesLocalService with SharedPreferences"
```

---

### Task 2: 補全 FavoritesRemoteService 實作 (LunaTV API)

**Files:**
- Modify: `lib/features/favorites/services/favorites_remote_service.dart`

- [ ] **Step 1: Write unit tests for FavoritesRemoteService**

```dart
// test/features/favorites/services/favorites_remote_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/favorites/services/favorites_remote_service.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';

void main() {
  group('FavoritesRemoteService', () {
    late FavoritesRemoteService service;

    setUp(() {
      service = FavoritesRemoteService(baseUrl: 'http://lunatv.example.com');
    });

    test('getFavorites returns list from API', () async {
      final favorites = await service.getFavorites();
      expect(favorites, isA<List<FavoriteItem>>());
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/favorites/services/favorites_remote_service_test.dart`
Expected: FAIL - API methods not implemented

- [ ] **Step 3: Implement FavoritesRemoteService with LunaTV API**

```dart
// lib/features/favorites/services/favorites_remote_service.dart

import 'package:dio/dio.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';

class FavoritesRemoteService {
  FavoritesRemoteService({required String baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
        ));

  final Dio _dio;

  Future<List<FavoriteItem>> getFavorites() async {
    final response = await _dio.get('/favorites');
    final List<dynamic> data = response.data['list'] ?? [];
    return data.map((json) => _fromJson(json)).toList();
  }

  Future<void> addFavorite(String id, String type) async {
    await _dio.post('/favorites', data: {'id': id, 'type': type});
  }

  Future<void> removeFavorite(String id) async {
    await _dio.delete('/favorites/$id');
  }

  Future<void> syncToServer(List<FavoriteItem> items) async {
    await _dio.post('/favorites/sync', data: {
      'items': items.map((i) => {
        'id': i.id,
        'type': i.type,
        'addedAt': i.addedAt.toIso8601String(),
      }).toList(),
    });
  }

  FavoriteItem _fromJson(Map<String, dynamic> json) => FavoriteItem(
    id: json['id'] as String,
    title: json['title'] as String,
    posterUrl: json['poster'] as String? ?? '',
    type: json['type'] as String? ?? 'movie',
    isAvailable: json['available'] as bool? ?? true,
    addedAt: json['addedAt'] != null
        ? DateTime.parse(json['addedAt'] as String)
        : DateTime.now(),
  );
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/favorites/services/favorites_remote_service_test.dart`
Expected: PASS (with mocked Dio)

- [ ] **Step 5: Commit**

```bash
git add lib/features/favorites/services/favorites_remote_service.dart test/features/favorites/services/favorites_remote_service_test.dart
git commit -m "feat(favorites): implement FavoritesRemoteService with LunaTV API"
```

---

### Task 3: 補全 FavoritesRepository 實作

**Files:**
- Create: `lib/features/favorites/data/repositories/favorites_repository_impl.dart`
- Modify: `lib/features/favorites/services/favorites_service.dart`

- [ ] **Step 1: Write unit tests for FavoritesRepository**

```dart
// test/features/favorites/repositories/favorites_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';
import 'package:white_tv/features/favorites/services/favorites_remote_service.dart';
import 'package:white_tv/features/favorites/services/favorites_local_service.dart';

void main() {
  group('FavoritesRepositoryImpl', () {
    late FavoritesRepositoryImpl repository;

    setUp(() {
      // Use fakes for testing
      final remote = FakeFavoritesRemoteService();
      final local = FakeFavoritesLocalService();
      repository = FavoritesRepositoryImpl(remote, local);
    });

    test('getAll returns merged favorites from remote and local', () async {
      final result = await repository.getAll();
      expect(result, isA<List<FavoriteItem>>());
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/favorites/repositories/favorites_repository_test.dart`
Expected: FAIL - repository not implemented

- [ ] **Step 3: Implement FavoritesRepositoryImpl (Remote-first)**

```dart
// lib/features/favorites/data/repositories/favorites_repository_impl.dart

import 'package:white_tv/features/favorites/data/models/favorite_item.dart';
import 'package:white_tv/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:white_tv/features/favorites/services/favorites_remote_service.dart';
import 'package:white_tv/features/favorites/services/favorites_local_service.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._remote, this._local);

  final FavoritesRemoteService _remote;
  final FavoritesLocalService _local;

  @override
  Future<List<FavoriteItem>> getAll() async {
    try {
      // Remote-first: fetch from LunaTV
      final remoteItems = await _remote.getFavorites();
      // Merge with local
      final localItems = await _local.getAll();
      final merged = _mergeItems(remoteItems, localItems);
      // Save merged to local
      await _local.saveAll(merged);
      return merged;
    } catch (e) {
      // Fallback to local if remote fails
      return _local.getAll();
    }
  }

  @override
  Future<void> add(FavoriteItem item) async {
    await _local.save(item);
    try {
      await _remote.addFavorite(item.id, item.type);
    } catch (_) {
      // Will sync later
    }
  }

  @override
  Future<void> remove(String id) async {
    await _local.remove(id);
    try {
      await _remote.removeFavorite(id);
    } catch (_) {
      // Will sync later
    }
  }

  @override
  Future<bool> isFavorite(String id) async {
    final items = await _local.getAll();
    return items.any((item) => item.id == id);
  }

  @override
  Future<void> sync() async {
    final localItems = await _local.getAll();
    await _remote.syncToServer(localItems);
  }

  List<FavoriteItem> _mergeItems(List<FavoriteItem> remote, List<FavoriteItem> local) {
    final Map<String, FavoriteItem> merged = {};
    for (final item in remote) {
      merged[item.id] = item;
    }
    for (final item in local) {
      if (!merged.containsKey(item.id)) {
        merged[item.id] = item;
      }
    }
    return merged.values.toList();
  }
}

extension on FavoritesLocalService {
  Future<void> saveAll(List<FavoriteItem> items) async {
    for (final item in items) {
      await save(item);
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/favorites/repositories/favorites_repository_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/favorites/data/repositories/favorites_repository_impl.dart test/features/favorites/repositories/favorites_repository_test.dart
git commit -m "feat(favorites): implement FavoritesRepositoryImpl with remote-first strategy"
```

---

## Phase 2: 補全 Store 實作

### Task 4: 補全 FavoritesStore 同步邏輯

**Files:**
- Modify: `lib/features/favorites/presentation/providers/favorites_store.dart`

- [ ] **Step 1: Write unit tests for FavoritesStore sync behavior**

```dart
// test/features/favorites/stores/favorites_store_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/favorites/presentation/providers/favorites_store.dart';
import 'package:white_tv/features/favorites/domain/models/favorites_state.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';

void main() {
  group('FavoritesStore', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.close());

    test('loadFavorites updates state with items', () async {
      final store = container.read(favoritesStoreProvider.notifier);

      await store.loadFavorites();

      final state = container.read(favoritesStoreProvider);
      expect(state.items, isNotEmpty);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/favorites/stores/favorites_store_test.dart`
Expected: FAIL - loadFavorites is placeholder

- [ ] **Step 3: Implement FavoritesStore with sync logic**

```dart
// lib/features/favorites/presentation/providers/favorites_store.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/favorites/domain/models/favorites_state.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';
import 'package:white_tv/features/favorites/services/favorites_service.dart';

class FavoritesStore extends Notifier<FavoritesState> {
  @override
  FavoritesState build() => const FavoritesState();

  FavoritesService get _service => _repositoryProvider(this);

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _service.getFavorites();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addFavorite(FavoriteItem item) async {
    await _service.addFavorite(item);
    await loadFavorites();
  }

  Future<void> removeFavorite(String id) async {
    await _service.removeFavorite(id);
    state = state.copyWith(
      items: state.items.where((i) => i.id != id).toList(),
    );
  }

  Future<void> syncWithServer() async {
    state = state.copyWith(isSyncing: true, clearError: true);
    try {
      await _service.syncWithServer();
      state = state.copyWith(isSyncing: false, lastSyncedAt: DateTime.now());
    } catch (e) {
      state = state.copyWith(error: e.toString(), isSyncing: false);
    }
  }

  void toggleView() {
    state = state.copyWith(isGridView: !state.isGridView);
  }

  void setFilterType(String type) {
    state = state.copyWith(filterType: type);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final favoritesStoreProvider = NotifierProvider<FavoritesStore, FavoritesState>(
  FavoritesStore.new,
);

// Repository provider for dependency injection
final _repositoryProvider = Provider((ref) {
  // This would be overridden in widget tree with actual implementation
  throw UnimplementedError('Repository not configured');
});
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/favorites/stores/favorites_store_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/favorites/presentation/providers/favorites_store.dart test/features/favorites/stores/favorites_store_test.dart
git commit -m "feat(favorites): implement FavoritesStore with sync logic"
```

---

## Phase 3: UI 整合

### Task 5: 新增收藏按鈕到播放器頁

**Files:**
- Modify: `lib/features/player/presentation/widgets/player_controls.dart` (or similar)

- [ ] **Step 1: Write widget test for favorite button**

```dart
// test/features/favorites/widgets/favorite_button_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/favorites/presentation/widgets/favorite_button.dart';

void main() {
  group('FavoriteButton', () {
    testWidgets('shows filled icon when item is favorite', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FavoriteButton(
              itemId: '1',
              isFavorite: true,
              onToggle: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/favorites/widgets/favorite_button_test.dart`
Expected: FAIL - FavoriteButton not implemented

- [ ] **Step 3: Implement FavoriteButton widget**

```dart
// lib/features/favorites/presentation/widgets/favorite_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/favorites/presentation/providers/favorites_store.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';
import 'package:white_tv/features/auth/presentation/providers/auth_store.dart';

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({
    super.key,
    required this.itemId,
    required this.title,
    required this.posterUrl,
    required this.type,
    this.isFavorite,
    this.onToggle,
  });

  final String itemId;
  final String title;
  final String posterUrl;
  final String type;
  final bool? isFavorite;
  final void Function(bool)? onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStoreProvider);
    final isLoggedIn = authState.isAuthenticated;

    return IconButton(
      icon: Icon(
        isFavorite == true ? Icons.favorite : Icons.favorite_border,
        color: isFavorite == true ? Colors.red : null,
      ),
      onPressed: isLoggedIn
          ? () {
              final store = ref.read(favoritesStoreProvider.notifier);
              if (isFavorite == true) {
                store.removeFavorite(itemId);
                onToggle?.call(false);
              } else {
                final item = FavoriteItem(
                  id: itemId,
                  title: title,
                  posterUrl: posterUrl,
                  type: type,
                  addedAt: DateTime.now(),
                );
                store.addFavorite(item);
                onToggle?.call(true);
              }
            }
          : () => _showLoginDialog(context),
    );
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('請先登入'),
        content: const Text('登入 LunaTV 後才能使用收藏功能'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login page
            },
            child: const Text('登入'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/favorites/widgets/favorite_button_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/favorites/presentation/widgets/favorite_button.dart test/features/favorites/widgets/favorite_button_test.dart
git commit -m "feat(favorites): add FavoriteButton widget with login prompt"
```

---

### Task 6: 新增收藏按鈕到詳情頁

**Files:**
- Modify: `lib/features/detail/presentation/screens/detail_screen.dart`

- [ ] **Step 1: Verify existing detail screen structure**

- [ ] **Step 2: Add FavoriteButton to detail screen toolbar**

```dart
// In detail_screen.dart toolbar actions:
actions: [
  FavoriteButton(
    itemId: video.id,
    title: video.title,
    posterUrl: video.posterUrl,
    type: video.type,
    isFavorite: _isFavorite,
    onToggle: (isFav) => setState(() => _isFavorite = isFav),
  ),
  // ... other actions
],
```

- [ ] **Step 3: Test the integration**

Run: `flutter test test/features/detail/`
Expected: All tests pass

- [ ] **Step 4: Commit**

```bash
git add lib/features/detail/presentation/screens/detail_screen.dart
git commit -m "feat(favorites): add FavoriteButton to detail screen"
```

---

## Phase 4: BDD 測試驗證

### Task 7: 執行完整 BDD 測試 suite

**Files:**
- Run: `test/features/favorites/favorites_bdd_test.dart`

- [ ] **Step 1: Run full BDD test suite**

Run: `flutter test test/features/favorites/favorites_bdd_test.dart`
Expected: All BDD scenarios pass

- [ ] **Step 2: Review and fix any failures**

- [ ] **Step 3: Commit passing tests**

---

## 檔案結構總結

```
lib/features/favorites/
├── data/
│   ├── models/
│   │   └── favorite_item.dart          ✅ 已存在
│   └── repositories/
│       └── favorites_repository_impl.dart  ✏️ 新增
├── domain/
│   ├── models/
│   │   └── favorites_state.dart        ✅ 已存在
│   └── repositories/
│       └── favorites_repository.dart   ✅ 已存在
├── presentation/
│   ├── providers/
│   │   └── favorites_store.dart        ✏️ 更新
│   ├── screens/
│   │   └── favorites_screen.dart       ✅ 已存在
│   └── widgets/
│       ├── favorite_button.dart        ✏️ 新增
│       ├── favorite_grid.dart         ✅ 已存在
│       ├── favorite_tile.dart          ✅ 已存在
│       └── favorites_filter_bar.dart   ✅ 已存在
└── services/
    ├── favorites_local_service.dart    ✏️ 更新
    ├── favorites_remote_service.dart   ✏️ 更新
    └── favorites_service.dart          ✏️ 更新

test/features/favorites/
├── models/
├── repositories/
├── services/
├── stores/
├── widgets/
└── favorites_bdd_test.dart            ✅ 已有
```

---

## 驗證標準

- [ ] 所有 Phase 1-4 任務完成
- [ ] BDD 測試全部通過
- [ ] TDD 單元測試覆蓋率達 80%+
- [ ] 未登入時收藏按鈕正確禁用並顯示登入提示
- [ ] 同步功能正常運作

---

**Plan complete and saved to** `docs/superpowers/plans/2026-05-29-favorites-sync-plan.md`

---

## Execution Options

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**