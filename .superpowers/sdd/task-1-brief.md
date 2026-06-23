### Task 1: 新增 SettingsStore.timeshiftBufferDuration 欄位

**Files:**
- Modify: `lib/features/settings/settings_store.dart`
- Modify: `lib/features/settings/services/settings_storage_service.dart`
- Create: `test/features/settings/settings_store_test.dart`

**Interfaces:**
- Consumes: `SettingsStorageService`
- Produces: `settings.timeshiftBufferDuration` (int, minutes: 15/30/60)

- [ ] **Step 1: 寫失敗測試**

```dart
test('timeshiftBufferDuration 預設為 30 分鐘', () {
  final store = SettingsStore(FakeSettingsStorageService());
  expect(store.state.timeshiftBufferDuration, 30);
});

test('updateTimeshiftBufferDuration 更新狀態和儲存', () async {
  final storage = FakeSettingsStorageService();
  final store = SettingsStore(storage);
  await store.updateTimeshiftBufferDuration(60);
  expect(store.state.timeshiftBufferDuration, 60);
  expect(await storage.getTimeshiftBufferDuration(), 60);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/settings/settings_store_test.dart`
Expected: FAIL - `timeshiftBufferDuration` not found

- [ ] **Step 3: 新增 SettingsState 欄位**

在 `SettingsState` class 新增：`int timeshiftBufferDuration = 30;`
更新 `copyWith` 新增 `int? timeshiftBufferDuration` 參數。

- [ ] **Step 4: 新增 SettingsStorageService 介面方法**

```dart
abstract interface class SettingsStorageService {
  // ... existing methods
  Future<int> getTimeshiftBufferDuration();
  Future<void> saveTimeshiftBufferDuration(int minutes);
}
```

- [ ] **Step 5: 實作 FakeSettingsStorageService**

```dart
int _timeshiftBufferDuration = 30;

@override
Future<int> getTimeshiftBufferDuration() async => _timeshiftBufferDuration;

@override
Future<void> saveTimeshiftBufferDuration(int minutes) async {
  _timeshiftBufferDuration = minutes;
}
```

- [ ] **Step 6: 新增 SettingsStore.updateTimeshiftBufferDuration**

```dart
Future<void> updateTimeshiftBufferDuration(int minutes) async {
  await _storage.saveTimeshiftBufferDuration(minutes);
  state = state.copyWith(timeshiftBufferDuration: minutes);
}
```

- [ ] **Step 7: Run test to verify it passes**

Run: `flutter test test/features/settings/settings_store_test.dart`
Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add lib/features/settings/settings_store.dart lib/features/settings/services/settings_storage_service.dart test/features/settings/settings_store_test.dart
git commit -m "feat(settings): add timeshiftBufferDuration to SettingsStore"
```

---

