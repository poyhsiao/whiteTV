### Task 3: 實作 TimeshiftManagerImpl.startClientBuffer()

**Files:**
- Modify: `lib/features/live/domain/repositories/timeshift_manager.dart`
- Create: `test/features/live/domain/repositories/timeshift_manager_test.dart`

**Interfaces:**
- Consumes: `channelId`, `Duration`, `streamUrl`
- Produces: `startClientBuffer()` 创建本地 TS 分段檔案

- [ ] **Step 1: 寫失敗測試**

```dart
group('startClientBuffer', () {
  late TimeshiftManagerImpl manager;
  late Directory tempDir;

  setUp(() async {
    manager = TimeshiftManagerImpl();
    tempDir = await Directory.systemTemp.createTemp('timeshift_test_');
  });

  tearDown(() async {
    await manager.stopClientBuffer();
    await tempDir.delete(recursive: true);
  });

  test('開始錄製後產生 TS 檔案', () async {
    await manager.startClientBuffer('channel_1', const Duration(minutes: 30));
    await Future.delayed(const Duration(seconds: 2));
    final files = await tempDir.list().toList();
    expect(files.any((f) => f.path.endsWith('.ts')), isTrue);
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/live/domain/repositories/timeshift_manager_test.dart`
Expected: FAIL

- [ ] **Step 3: 實作 startClientBuffer**

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

File? _bufferFile;
IOSink? _bufferSink;
Timer? _segmentTimer;
String? _currentChannelId;
DateTime? _recordingStartTime;

@override
Future<void> startClientBuffer(String channelId, Duration duration) async {
  _currentChannelId = channelId;
  _recordingStartTime = DateTime.now();
  
  final tempDir = await getTemporaryDirectory();
  _bufferFile = File('${tempDir.path}/timeshift_${channelId}_${DateTime.now().millisecondsSinceEpoch}.ts');
  _bufferSink = _bufferFile!.openWrite();
  
  _segmentTimer = Timer.periodic(const Duration(seconds: 30), (_) {
    await _createNewSegment(channelId, duration);
  });
}

Future<void> _createNewSegment(String channelId, Duration maxDuration) async {
  await _bufferSink?.close();
  
  final tempDir = await getTemporaryDirectory();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  _bufferFile = File('${tempDir.path}/timeshift_${channelId}_$timestamp.ts');
  _bufferSink = _bufferFile!.openWrite();
  
  await _cleanupOldSegments(channelId, maxDuration);
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/live/domain/repositories/timeshift_manager_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/live/domain/repositories/timeshift_manager.dart test/features/live/domain/repositories/timeshift_manager_test.dart
git commit -m "feat(timeshift): implement startClientBuffer"
```

---

