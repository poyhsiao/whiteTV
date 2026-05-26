# TDD Test Coverage Enhancement - Phase 1: HomeStore + DetailStore

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enhance test coverage for HomeStore and DetailStore from ~4 tests each to 15+ tests each, following TDD workflow (RED → GREEN → IMPROVE).

**Architecture:** Two Store classes using Riverpod StateNotifier pattern:
- HomeStore (94 lines): Manages home screen state, categories, videos, recent history
- DetailStore (119 lines): Manages video detail state, source selection, episode selection

**Tech Stack:** flutter_test, Riverpod, MockClient

---

## File Structure

| File | Purpose |
|------|---------|
| `lib/features/home/home_store.dart` | HomeStore with loadHome(), setHistoryService() |
| `lib/features/detail/detail_store.dart` | DetailStore with loadDetail(), selectSource(), selectEpisode() |
| `test/features/home/home_store_test.dart` | HomeStore tests (existing 4, need expansion) |
| `test/features/detail/detail_store_test.dart` | DetailStore tests (existing 4, need expansion) |
| `test/core/api/mock_client.dart` | Mock client for API calls |

---

## Part A: HomeStore Test Enhancement

### Task A1: setHistoryService() - Inject HistoryService After Construction

**Files:**
- Modify: `test/features/home/home_store_test.dart`
- Modify: `lib/features/home/home_store.dart:50-52`

- [ ] **Step 1: Write the failing test**

```dart
test('setHistoryService should update internal reference', () {
  // Arrange
  final mockClient = MockClient();
  final store = HomeStore(mockClient);
  final fakeHistoryService = FakeHistoryService();

  // Act
  store.setHistoryService(fakeHistoryService);

  // Assert - verify the service was set (via behavior)
  // When loadHome is called, it should use the injected service
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/home/home_store_test.dart --name "setHistoryService"`
Expected: PASS (existing implementation already works)

- [ ] **Step 3: Add negative test - setHistoryService to null**

```dart
test('setHistoryService(null) should clear the service', () async {
  // Arrange
  final mockClient = MockClient();
  final fakeHistoryService = FakeHistoryService();
  final store = HomeStore(mockClient, fakeHistoryService);

  // Act
  store.setHistoryService(null);

  // Assert - loadHome should not throw even with null service
  await store.loadHome(); // Should complete without error
});
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/home/home_store_test.dart --name "setHistoryService"`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add test/features/home/home_store_test.dart
git commit -m "test(HomeStore): add setHistoryService test coverage"
```

---

### Task A2: loadHome() - Error Handling Edge Cases

**Files:**
- Modify: `test/features/home/home_store_test.dart`

- [ ] **Step 1: Write failing test - API failure handling**

```dart
test('loadHome should set error state on API failure', () async {
  // Arrange
  final mockClient = MockClient();
  mockClient.throwOnGetCategories(Exception('Network error'));
  final store = HomeStore(mockClient);

  // Act
  await store.loadHome();

  // Assert
  expect(store.state.error, isNotNull);
  expect(store.state.isLoading, false);
  expect(store.state.categories, isEmpty);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/home/home_store_test.dart --name "API failure"`
Expected: FAIL or needs MockClient modification

- [ ] **Step 3: Verify test passes with current implementation**

Run: `flutter test test/features/home/home_store_test.dart`
Expected: Check if error handling works

- [ ] **Step 4: Commit**

```bash
git add test/features/home/home_store_test.dart
git commit -m "test(HomeStore): add loadHome error handling tests"
```

---

### Task A3: loadHome() - Recent History Integration

**Files:**
- Modify: `test/features/home/home_store_test.dart`

- [ ] **Step 1: Write failing test - recentHistory loaded when service available**

```dart
test('loadHome should populate recentHistory when service provided', () async {
  // Arrange
  final mockClient = MockClient();
  final fakeHistoryService = FakeHistoryService();
  fakeHistoryService.addHistory(PlayHistory(
    videoId: 'video-1',
    title: 'Test Video',
    progress: 0.5,
    lastPlayedAt: DateTime.now(),
  ));
  final store = HomeStore(mockClient, fakeHistoryService);

  // Act
  await store.loadHome();

  // Assert
  expect(store.state.recentHistory, isNotEmpty);
  expect(store.state.recentHistory.length, 1);
});
```

- [ ] **Step 2: Write test - recentHistory empty when service unavailable**

```dart
test('loadHome should handle null historyService gracefully', () async {
  // Arrange
  final mockClient = MockClient();
  final store = HomeStore(mockClient); // no history service

  // Act
  await store.loadHome();

  // Assert
  expect(store.state.recentHistory, isEmpty);
  expect(store.state.categories, isNotEmpty); // categories still loaded
});
```

- [ ] **Step 3: Write test - recentHistory load error doesn't crash loadHome**

```dart
test('loadHome should continue even if history service throws', () async {
  // Arrange
  final mockClient = MockClient();
  final fakeHistoryService = FakeHistoryService();
  fakeHistoryService.throwOnGetHistory(Exception('History error'));
  final store = HomeStore(mockClient, fakeHistoryService);

  // Act
  await store.loadHome();

  // Assert - categories should still load
  expect(store.state.categories, isNotEmpty);
  expect(store.state.error, isNull); // history error is swallowed
});
```

- [ ] **Step 4: Run tests and verify**

Run: `flutter test test/features/home/home_store_test.dart --name "recentHistory\|historyService\|history throws"`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add test/features/home/home_store_test.dart
git commit -m "test(HomeStore): add recentHistory integration tests"
```

---

### Task A4: clearHome() State Reset

**Files:**
- Modify: `test/features/home/home_store_test.dart`
- Modify: `lib/features/home/home_store.dart` (add clearHome method if missing)

- [ ] **Step 1: Check if clearHome exists and write failing test**

```dart
test('clearHome should reset state to initial', () async {
  // Arrange
  final mockClient = MockClient();
  final store = HomeStore(mockClient);
  await store.loadHome(); // populate state

  // Act
  store.clearHome();

  // Assert
  expect(store.state.categories, isEmpty);
  expect(store.state.videosByCategory, isEmpty);
  expect(store.state.recentHistory, isEmpty);
  expect(store.state.isLoading, false);
  expect(store.state.error, isNull);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/home/home_store_test.dart --name "clearHome"`
Expected: FAIL (method may not exist)

- [ ] **Step 3: Implement minimal clearHome method**

Add to HomeStore class:
```dart
void clearHome() {
  state = const HomeState();
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/home/home_store_test.dart --name "clearHome"`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add test/features/home/home_store_test.dart lib/features/home/home_store.dart
git commit -m "feat(HomeStore): add clearHome method with test"
```

---

### Task A5: State CopyWith Immutability Tests

**Files:**
- Modify: `test/features/home/home_store_test.dart`

- [ ] **Step 1: Write failing test for copyWith immutability**

```dart
test('copyWith should not mutate original state', () async {
  // Arrange
  final mockClient = MockClient();
  final store = HomeStore(mockClient);
  await store.loadHome();
  final originalCategories = store.state.categories;

  // Act
  store.state.copyWith(categories: []);

  // Assert - original should be unchanged
  expect(store.state.categories, equals(originalCategories));
});
```

- [ ] **Step 2: Run test to verify it passes (copyWith already immutable)**

Run: `flutter test test/features/home/home_store_test.dart --name "copyWith"`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add test/features/home/home_store_test.dart
git commit -m "test(HomeStore): add copyWith immutability tests"
```

---

## Part B: DetailStore Test Enhancement

### Task B1: selectEpisode() - Episode Selection Logic

**Files:**
- Modify: `test/features/detail/detail_store_test.dart`

- [ ] **Step 1: Write failing test - valid episode selection**

```dart
test('selectEpisode should update selectedEpisode in state', () {
  // Arrange
  final mockClient = MockClient();
  final sourceSelector = FakeSourceSelector();
  final store = DetailStore(mockClient, sourceSelector, null);
  final episode = Episode(id: 'ep-1', title: 'Episode 1');

  // Act
  store.selectEpisode(episode);

  // Assert
  expect(store.state.selectedEpisode, equals(episode));
});
```

- [ ] **Step 2: Write failing test - select null episode**

```dart
test('selectEpisode(null) should clear selectedEpisode', () {
  // Arrange
  final mockClient = MockClient();
  final sourceSelector = FakeSourceSelector();
  final store = DetailStore(mockClient, sourceSelector, null);
  store.selectEpisode(Episode(id: 'ep-1', title: 'Episode 1'));

  // Act
  store.selectEpisode(null);

  // Assert
  expect(store.state.selectedEpisode, isNull);
});
```

- [ ] **Step 3: Run tests to verify they pass**

Run: `flutter test test/features/detail/detail_store_test.dart --name "selectEpisode"`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add test/features/detail/detail_store_test.dart
git commit -m "test(DetailStore): add selectEpisode test coverage"
```

---

### Task B2: selectSource() - Source Selection with SourceSelector Recording

**Files:**
- Modify: `test/features/detail/detail_store_test.dart`

- [ ] **Step 1: Write failing test - selectSource updates state**

```dart
test('selectSource should update selectedSource in state', () {
  // Arrange
  final mockClient = MockClient();
  final sourceSelector = FakeSourceSelector();
  final store = DetailStore(mockClient, sourceSelector, null);
  final source = VideoSource(id: 'source-1', name: 'Source 1', latency: 100);

  // Act
  store.selectSource(source);

  // Assert
  expect(store.state.selectedSource, equals(source));
});
```

- [ ] **Step 2: Write failing test - recordSourceResult with success**

```dart
test('recordSourceResult should call sourceSelector.recordResult', () {
  // Arrange
  final mockClient = MockClient();
  final sourceSelector = FakeSourceSelector();
  final store = DetailStore(mockClient, sourceSelector, null);
  store.selectSource(VideoSource(id: 'source-1', name: 'Test', latency: 50));

  // Act
  store.recordSourceResult(isSuccess: true, latency: 50);

  // Assert
  expect(sourceSelector.lastRecordedSourceId, equals('source-1'));
  expect(sourceSelector.lastRecordedSuccess, isTrue);
});
```

- [ ] **Step 3: Write failing test - recordSourceResult when no source selected**

```dart
test('recordSourceResult should not crash when no source selected', () {
  // Arrange
  final mockClient = MockClient();
  final sourceSelector = FakeSourceSelector();
  final store = DetailStore(mockClient, sourceSelector, null);
  // No source selected

  // Act & Assert - should not throw
  expect(
    () => store.recordSourceResult(isSuccess: false, latency: 0),
    returnsNormally,
  );
});
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/detail/detail_store_test.dart --name "selectSource\|recordSourceResult"`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add test/features/detail/detail_store_test.dart
git commit -m "test(DetailStore): add selectSource and recordSourceResult tests"
```

---

### Task B3: loadDetail() - Full Load Flow with Error Handling

**Files:**
- Modify: `test/features/detail/detail_store_test.dart`

- [ ] **Step 1: Write failing test - loadDetail with valid videoId**

```dart
test('loadDetail should populate detail, source, and episode', () async {
  // Arrange
  final mockClient = MockClient();
  final sourceSelector = FakeSourceSelector();
  final store = DetailStore(mockClient, sourceSelector, null);

  // Act
  await store.loadDetail('video-123');

  // Assert
  expect(store.state.detail, isNotNull);
  expect(store.state.selectedSource, isNotNull);
  expect(store.state.selectedEpisode, isNotNull); // first episode
  expect(store.state.isLoading, false);
  expect(store.state.error, isNull);
});
```

- [ ] **Step 2: Write failing test - loadDetail failure sets error state**

```dart
test('loadDetail should set error on API failure', () async {
  // Arrange
  final mockClient = MockClient();
  mockClient.throwOnGetVideoDetail(Exception('Not found'));
  final sourceSelector = FakeSourceSelector();
  final store = DetailStore(mockClient, sourceSelector, null);

  // Act
  await store.loadDetail('invalid-id');

  // Assert
  expect(store.state.error, isNotNull);
  expect(store.state.isLoading, false);
  expect(store.state.detail, isNull);
});
```

- [ ] **Step 3: Write failing test - loadDetail with empty episodes**

```dart
test('loadDetail should handle detail with no episodes', () async {
  // Arrange
  final mockClient = MockClient();
  final sourceSelector = FakeSourceSelector();
  final store = DetailStore(mockClient, sourceSelector, null);
  // MockClient returns detail with empty episodes

  // Act
  await store.loadDetail('movie-no-episodes');

  // Assert
  expect(store.state.detail, isNotNull);
  expect(store.state.selectedEpisode, isNull); // no episodes available
});
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/detail/detail_store_test.dart --name "loadDetail"`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add test/features/detail/detail_store_test.dart
git commit -m "test(DetailStore): add loadDetail full flow tests"
```

---

### Task B4: getProgressForMedia() - History Integration

**Files:**
- Modify: `test/features/detail/detail_store_test.dart`

- [ ] **Step 1: Write failing test - returns null when ref is null**

```dart
test('getProgressForMedia should return null when ref is null', () {
  // Arrange
  final mockClient = MockClient();
  final sourceSelector = FakeSourceSelector();
  final store = DetailStore(mockClient, sourceSelector, null); // no ref

  // Act
  final progress = store.getProgressForMedia('video-123');

  // Assert
  expect(progress, isNull);
});
```

- [ ] **Step 2: Write failing test - returns progress when available**

```dart
test('getProgressForMedia should return progress from historyStore', () {
  // Arrange
  final mockClient = MockClient();
  final sourceSelector = FakeSourceSelector();
  final fakeRef = FakeRef();
  final historyStore = HistoryStore(FakeHistoryService());
  historyStore.state.records.add(PlayHistory(
    videoId: 'video-123',
    title: 'Test',
    progress: 0.75,
    lastPlayedAt: DateTime.now(),
  ));
  fakeRef.stubHistoryStore(historyStore);

  final store = DetailStore(mockClient, sourceSelector, fakeRef);

  // Act
  final progress = store.getProgressForMedia('video-123');

  // Assert
  expect(progress, isNotNull);
  expect(progress!.videoId, equals('video-123'));
  expect(progress.progress, equals(0.75));
});
```

- [ ] **Step 3: Write failing test - returns null when media not in history**

```dart
test('getProgressForMedia should return null when media not in history', () {
  // Arrange
  final mockClient = MockClient();
  final sourceSelector = FakeSourceSelector();
  final fakeRef = FakeRef();
  final historyStore = HistoryStore(FakeHistoryService());
  fakeRef.stubHistoryStore(historyStore);

  final store = DetailStore(mockClient, sourceSelector, fakeRef);

  // Act
  final progress = store.getProgressForMedia('unknown-video');

  // Assert
  expect(progress, isNull);
});
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/detail/detail_store_test.dart --name "getProgressForMedia"`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add test/features/detail/detail_store_test.dart
git commit -m "test(DetailStore): add getProgressForMedia tests"
```

---

### Task B5: State CopyWith and Initial State Tests

**Files:**
- Modify: `test/features/detail/detail_store_test.dart`

- [ ] **Step 1: Write failing test - initial state has correct defaults**

```dart
test('initial state should have correct default values', () {
  // Arrange
  final mockClient = MockClient();
  final sourceSelector = FakeSourceSelector();
  final store = DetailStore(mockClient, sourceSelector, null);

  // Assert
  expect(store.state.detail, isNull);
  expect(store.state.selectedSource, isNull);
  expect(store.state.selectedEpisode, isNull);
  expect(store.state.isLoading, false);
  expect(store.state.error, isNull);
});
```

- [ ] **Step 2: Write failing test - copyWith preserves unchanged fields**

```dart
test('copyWith should preserve unchanged fields', () {
  // Arrange
  final mockClient = MockClient();
  final sourceSelector = FakeSourceSelector();
  final store = DetailStore(mockClient, sourceSelector, null);
  final originalState = store.state;

  // Act
  final newState = store.state.copyWith(isLoading: true);

  // Assert
  expect(newState.detail, equals(originalState.detail));
  expect(newState.selectedSource, equals(originalState.selectedSource));
  expect(newState.selectedEpisode, equals(originalState.selectedEpisode));
  expect(newState.isLoading, isTrue);
});
```

- [ ] **Step 3: Run tests to verify they pass**

Run: `flutter test test/features/detail/detail_store_test.dart --name "initial state\|copyWith should preserve"`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add test/features/detail/detail_store_test.dart
git commit -m "test(DetailStore): add state and copyWith tests"
```

---

## Verification

After completing all tasks:

- [ ] Run full test suite: `flutter test test/features/home/home_store_test.dart test/features/detail/detail_store_test.dart`
- [ ] Verify test count increased from ~4 to ~20+ per file
- [ ] Ensure all tests pass (GREEN)
- [ ] Run coverage: `flutter test --coverage`
- [ ] Verify coverage meets 80%+ threshold

---

## Execution Options

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**