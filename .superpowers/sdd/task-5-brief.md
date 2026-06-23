### Task 5: 實作緩衝上限自動淘汰邏輯

**Files:**
- Modify: `lib/features/live/domain/repositories/timeshift_manager.dart`

- [ ] **Step 1: 寫失敗測試**

```dart
test('達到上限時淘汰舊段落', () async {
  await manager.startClientBuffer('channel_1', const Duration(minutes: 1));
  await Future.delayed(const Duration(minutes: 2));
  
  final tempDir = await Directory.systemTemp.list().toList();
  final tsFiles = tempDir.where((f) => f.path.contains('timeshift_channel_1')).toList();
  expect(tsFiles.length, lessThanOrEqualTo(3));
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/live/domain/repositories/timeshift_manager_test.dart`
Expected: FAIL

- [ ] **Step 3: 實作 _cleanupOldSegments**

```dart
Future<void> _cleanupOldSegments(String channelId, Duration maxDuration) async {
  final tempDir = await getTemporaryDirectory();
  final files = await tempDir.list().toList();
  final tsFiles = files
      .where((f) => f.path.contains('timeshift_$channelId') && f.path.endsWith('.ts'))
      .toList();
  
  tsFiles.sort((a, b) => a.path.compareTo(b.path));
  
  final maxSegments = (maxDuration.inSeconds / 30).ceil();
  
  if (tsFiles.length > maxSegments) {
    final toDelete = tsFiles.take(tsFiles.length - maxSegments);
    for (final file in toDelete) {
      await file.delete();
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/live/domain/repositories/timeshift_manager_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/live/domain/repositories/timeshift_manager.dart
git commit -m "feat(timeshift): implement segment cleanup for buffer limit"
```

---

