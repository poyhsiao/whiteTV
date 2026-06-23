### Task 2: Settings 頁新增時移緩衝時長設定 UI

**Files:**
- Modify: `lib/features/settings/presentation/screens/settings_screen.dart`

**Interfaces:**
- Consumes: `settingsStoreProvider.timeshiftBufferDuration`
- Produces: `settingsStoreProvider.notifier.updateTimeshiftBufferDuration(minutes)`

- [ ] **Step 1: 找 Settings 頁中直播相關設定的位置**

執行: `grep -n "直播" lib/features/settings/presentation/screens/settings_screen.dart`

- [ ] **Step 2: 在直播設定區塊新增 RadioListTile**

```dart
RadioListTile<int>(
  title: const Text('15 分鐘'),
  value: 15,
  groupValue: settings.timeshiftBufferDuration,
  onChanged: (v) => ref.read(settingsStoreProvider.notifier).updateTimeshiftBufferDuration(v!),
),
RadioListTile<int>(
  title: const Text('30 分鐘'),
  value: 30,
  groupValue: settings.timeshiftBufferDuration,
  onChanged: (v) => ref.read(settingsStoreProvider.notifier).updateTimeshiftBufferDuration(v!),
),
RadioListTile<int>(
  title: const Text('60 分鐘'),
  value: 60,
  groupValue: settings.timeshiftBufferDuration,
  onChanged: (v) => ref.read(settingsStoreProvider.notifier).updateTimeshiftBufferDuration(v!),
),
```

- [ ] **Step 3: Run flutter analyze**

Run: `flutter analyze lib/features/settings/presentation/screens/settings_screen.dart`

- [ ] **Step 4: Commit**

```bash
git add lib/features/settings/presentation/screens/settings_screen.dart
git commit -m "feat(settings): add timeshift buffer duration RadioListTile"
```

---

