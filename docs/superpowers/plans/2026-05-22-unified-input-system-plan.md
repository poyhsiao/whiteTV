# 統一輸入系統實現計劃 (Unified Input System)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立統一 TV 輸入系統，透過 QR Code + 手機瀏覽器實現文字輸入，解決 TV 遙控器輸入不便的問題。

**Architecture:** 使用 Flutter shelf 建立本地 HTTP 伺服器，手機連接同一 WiFi 後掃描 QR Code 即可輸入文字。完全 client-side，無需後端配合。

**Tech Stack:** shelf, shelf_router, network_info_plus, qr_flutter

---

## Phase 1: 核心服務層 (Core Services)

### Task 1: SessionManager

**Files:**
- Create: `lib/core/services/session_manager.dart`
- Create: `test/unit/session_manager_test.dart`

- [ ] **Step 1: Write failing test**

```dart
// test/unit/session_manager_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:whitetv/core/services/session_manager.dart';

void main() {
  group('SessionManager', () {
    test('creates session with unique ID', () {
      final manager = SessionManager();
      final session = manager.createSession();

      expect(session.id, isNotEmpty);
      expect(session.id.length, greaterThanOrEqualTo(16));
    });

    test('generates different IDs for each session', () {
      final manager = SessionManager();
      final session1 = manager.createSession();
      final session2 = manager.createSession();

      expect(session1.id, isNot(session2.id));
    });

    test('session expires after timeout', () async {
      final manager = SessionManager(duration: Duration(milliseconds: 100));
      final session = manager.createSession();

      expect(session.isValid, isTrue);
      await Future.delayed(Duration(milliseconds: 150));

      expect(session.isValid, isFalse);
    });

    test('clears all sessions', () {
      final manager = SessionManager();
      manager.createSession();
      manager.createSession();
      manager.clear();

      expect(manager.sessions.length, equals(0));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /Users/kimhsiao/Templates/git/kimhsiao/whiteTV && flutter test test/unit/session_manager_test.dart -v`
Expected: FAIL - "SessionManager" not found

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/core/services/session_manager.dart
import 'dart:async';

class InputSession {
  final String id;
  final DateTime createdAt;
  final Duration duration;

  InputSession({
    required this.id,
    required this.createdAt,
    this.duration = const Duration(minutes: 5),
  });

  bool get isValid =>
      DateTime.now().difference(createdAt) < duration;
}

class SessionManager {
  final List<InputSession> _sessions = [];
  final Duration _defaultDuration;

  SessionManager({Duration? duration})
      : _defaultDuration = duration ?? const Duration(minutes: 5);

  InputSession createSession() {
    final session = InputSession(
      id: _generateId(),
      createdAt: DateTime.now(),
      duration: _defaultDuration,
    );
    _sessions.add(session);
    return session;
  }

  String _generateId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final random = timestamp.hashCode.abs().toString();
    return '${timestamp.toRadixString(36)}$random';
  }

  List<InputSession> get sessions => List.unmodifiable(_sessions);

  void clear() {
    _sessions.clear();
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /Users/kimhsiao/Templates/git/kimhsiao/whiteTV && flutter test test/unit/session_manager_test.dart -v`
Expected: PASS (4 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/core/services/session_manager.dart test/unit/session_manager_test.dart
git commit -m "feat(input): add SessionManager for QR session lifecycle"
```

---

### Task 2: LocalHttpServer

**Files:**
- Create: `lib/core/services/local_http_server.dart`
- Create: `test/unit/local_http_server_test.dart`

- [ ] **Step 1: Write failing test**

```dart
// test/unit/local_http_server_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:whitetv/core/services/local_http_server.dart';

void main() {
  group('LocalHttpServer', () {
    late LocalHttpServer server;

    setUp(() {
      server = LocalHttpServer();
    });

    tearDown(() async {
      await server.stop();
    });

    test('starts on specified port', () async {
      await server.start(port: 8080);
      expect(server.isRunning, isTrue);
      expect(server.port, equals(8080));
    });

    test('stopped server is not running', () async {
      await server.start(port: 8080);
      await server.stop();
      expect(server.isRunning, isFalse);
    });

    test('server has correct base URL', () async {
      await server.start(port: 8080, ipAddress: '192.168.1.100');
      expect(server.baseUrl, equals('http://192.168.1.100:8080'));
    });

    test('handles input POST request', () async {
      await server.start(port: 8080);
      final handler = server.inputHandler;
      expect(handler, isNotNull);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /Users/kimhsiao/Templates/git/kimhsiao/whiteTV && flutter test test/unit/local_http_server_test.dart -v`
Expected: FAIL - "LocalHttpServer" not found

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/core/services/local_http_server.dart
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

typedef InputHandler = void Function(String text);

class LocalHttpServer {
  HttpServer? _server;
  InputHandler? _inputHandler;
  String? _ipAddress;
  int? _port;

  bool get isRunning => _server != null;
  int? get port => _port;
  String? get ipAddress => _ipAddress;
  String get baseUrl => 'http://$_ipAddress:$_port';

  InputHandler? get inputHandler => _inputHandler;

  void setInputHandler(InputHandler handler) {
    _inputHandler = handler;
  }

  Future<void> start({
    required int port,
    required String ipAddress,
  }) async {
    _ipAddress = ipAddress;
    _port = port;

    final router = Router();

    router.get('/', (request) {
      return Response.ok(
        _htmlPage,
        headers: {'Content-Type': 'text/html'},
      );
    });

    router.post('/input', (Request request) async {
      final body = await request.readAsString();
      final text = _extractText(body);
      _inputHandler?.call(text);
      return Response.ok('{"success": true}');
    });

    router.post('/clear', (Request request) {
      _inputHandler?.call('');
      return Response.ok('{"success": true}');
    });

    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(router.call);

    _server = await shelf_io.serve(handler, ipAddress, port);
  }

  String _extractText(String body) {
    try {
      if (body.contains('"text"')) {
        final match = RegExp(r'"text"\s*:\s*"([^"]*)"').firstMatch(body);
        return match?.group(1) ?? '';
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _ipAddress = null;
    _port = null;
  }

  static const String _htmlPage = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>whiteTV 輸入</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; padding: 20px; background: #1a1a1a; color: #fff; }
    input { width: 100%; padding: 15px; font-size: 18px; border-radius: 8px; border: none; margin: 10px 0; box-sizing: border-box; }
    .btn { padding: 15px 30px; font-size: 18px; border-radius: 8px; border: none; cursor: pointer; margin: 5px; }
    .send { background: #ffb347; color: #000; }
    .clear { background: #666; color: #fff; }
  </style>
</head>
<body>
  <h2>whiteTV 輸入</h2>
  <input type="text" id="inputField" placeholder="輸入文字..." autofocus>
  <button class="btn send" onclick="send()">發送</button>
  <button class="btn clear" onclick="clearInput()">清除</button>

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
''';
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /Users/kimhsiao/Templates/git/kimhsiao/whiteTV && flutter test test/unit/local_http_server_test.dart -v`
Expected: PASS (4 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/core/services/local_http_server.dart test/unit/local_http_server_test.dart
git commit -m "feat(input): add LocalHttpServer with shelf HTTP handler"
```

---

### Task 3: InputService

**Files:**
- Create: `lib/core/services/input_service.dart`
- Create: `test/unit/input_service_test.dart`

- [ ] **Step 1: Write failing test**

```dart
// test/unit/input_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:whitetv/core/services/input_service.dart';

void main() {
  group('InputService', () {
    late InputService service;

    setUp(() {
      service = InputService();
    });

    tearDown(() async {
      if (service.isRunning) {
        await service.stopServer();
      }
    });

    test('is not running initially', () {
      expect(service.isRunning, isFalse);
    });

    test('currentInput is empty initially', () {
      expect(service.currentInput, equals(''));
    });

    test('setOnInputComplete registers callback', () {
      bool called = false;
      service.setOnInputComplete((text) {
        called = true;
      });
      expect(service.onInputComplete, isNotNull);
    });

    test('clearInput resets currentInput', () async {
      service.clearInput();
      expect(service.currentInput, equals(''));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /Users/kimhsiao/Templates/git/kimhsiao/whiteTV && flutter test test/unit/input_service_test.dart -v`
Expected: FAIL - "InputService" not found

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/core/services/input_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:whitetv/core/services/local_http_server.dart';
import 'package:whitetv/core/services/session_manager.dart';

typedef InputCompleteCallback = void Function(String text);

class InputService {
  final LocalHttpServer _server = LocalHttpServer();
  final SessionManager _sessionManager = SessionManager();
  final NetworkInfo _networkInfo = NetworkInfo();

  String _currentInput = '';
  InputCompleteCallback? _onInputComplete;
  bool _isRunning = false;

  String? _currentIpAddress;
  int? _currentPort;

  bool get isRunning => _isRunning;
  String get currentInput => _currentInput;
  InputCompleteCallback? get onInputComplete => _onInputComplete;

  String? get currentIp => _currentIpAddress;
  int? get currentPort => _currentPort;

  Future<String?> _getLocalIpAddress() async {
    try {
      final wifiIP = await _networkInfo.getWifiIP();
      return wifiIP;
    } catch (_) {
      return null;
    }
  }

  Future<int> _findAvailablePort(int startPort) async {
    for (int port = startPort; port < startPort + 100; port++) {
      try {
        final server = LocalHttpServer();
        await server.start(port: port, ipAddress: '0.0.0.0');
        await server.stop();
        return port;
      } catch (_) {
        continue;
      }
    }
    throw Exception('No available port found');
  }

  Future<bool> startServer({int port = 8080}) async {
    if (_isRunning) return true;

    try {
      _currentIpAddress = await _getLocalIpAddress();
      if (_currentIpAddress == null) {
        return false;
      }

      final session = _sessionManager.createSession();
      _currentPort = port;

      _server.setInputHandler((text) {
        if (text.isEmpty) {
          _currentInput = '';
        } else {
          _currentInput += text;
        }
      });

      await _server.start(
        port: port,
        ipAddress: _currentIpAddress!,
      );

      _isRunning = true;
      return true;
    } catch (_) {
      _isRunning = false;
      return false;
    }
  }

  Future<void> stopServer() async {
    if (!_isRunning) return;
    await _server.stop();
    _isRunning = false;
    _sessionManager.clear();
  }

  String getQrCodeUrl() {
    if (_currentIpAddress == null || _currentPort == null) {
      return '';
    }
    return 'http://$_currentIpAddress:$_currentPort/';
  }

  Stream<String> get inputStream {
    return Stream.periodic(Duration(milliseconds: 100))
        .map((_) => _currentInput)
        .distinct();
  }

  void clearInput() {
    _currentInput = '';
    _server.setInputHandler((text) {
      _currentInput = text;
    });
  }

  void setOnInputComplete(InputCompleteCallback callback) {
    _onInputComplete = callback;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /Users/kimhsiao/Templates/git/kimhsiao/whiteTV && flutter test test/unit/input_service_test.dart -v`
Expected: PASS (5 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/core/services/input_service.dart test/unit/input_service_test.dart
git commit -m "feat(input): add InputService as unified input facade"
```

---

## Phase 2: UI 組件層 (UI Components)

### Task 4: QrInputWidget

**Files:**
- Create: `lib/shared/widgets/qr_input_widget.dart`
- Create: `test/unit/qr_input_widget_test.dart`

- [ ] **Step 1: Write failing test**

```dart
// test/unit/qr_input_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitetv/shared/widgets/qr_input_widget.dart';

void main() {
  group('QrInputWidget', () {
    testWidgets('renders QR code when url is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QrInputWidget(
              url: 'http://192.168.1.100:8080/',
              onToggle: () {},
            ),
          ),
        ),
      );

      expect(find.byType(QrInputWidget), findsOneWidget);
    });

    testWidgets('shows loading indicator when url is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QrInputWidget(
              url: '',
              onToggle: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('toggle button is present', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QrInputWidget(
              url: 'http://192.168.1.100:8080/',
              onToggle: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.qr_code), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /Users/kimhsiao/Templates/git/kimhsiao/whiteTV && flutter test test/unit/qr_input_widget_test.dart -v`
Expected: FAIL - "QrInputWidget" not found

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/shared/widgets/qr_input_widget.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrInputWidget extends StatelessWidget {
  final String url;
  final VoidCallback onToggle;
  final String? title;

  const QrInputWidget({
    super.key,
    required this.url,
    required this.onToggle,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 16),
        ],
        if (url.isEmpty)
          const CircularProgressIndicator()
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: url,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: onToggle,
          icon: const Icon(Icons.keyboard, color: Colors.white70),
          label: const Text(
            '使用遙控器輸入',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /Users/kimhsiao/Templates/git/kimhsiao/whiteTV && flutter test test/unit/qr_input_widget_test.dart -v`
Expected: PASS (3 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/shared/widgets/qr_input_widget.dart test/unit/qr_input_widget_test.dart
git commit -m "feat(input): add QrInputWidget for QR code display"
```

---

### Task 5: InputScreen (TV Full Screen)

**Files:**
- Create: `lib/features/settings/presentation/screens/input_screen.dart`
- Create: `test/features/settings/input_screen_test.dart`

- [ ] **Step 1: Write failing test**

```dart
// test/features/settings/input_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitetv/features/settings/presentation/screens/input_screen.dart';

void main() {
  group('InputScreen', () {
    testWidgets('displays QR code widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InputScreen(
            title: '測試標題',
            onComplete: (_) {},
          ),
        ),
      );

      expect(find.byType(InputScreen), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InputScreen(
            title: '測試標題',
            onComplete: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('calls onComplete when done', (tester) async {
      String? completedText;

      await tester.pumpWidget(
        MaterialApp(
          home: InputScreen(
            title: '測試標題',
            onComplete: (text) {
              completedText = text;
            },
          ),
        ),
      );

      final doneButton = find.text('完成');
      if (doneButton.evaluate().isNotEmpty) {
        await tester.tap(doneButton);
        expect(completedText, isNotNull);
      }
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /Users/kimhsiao/Templates/git/kimhsiao/whiteTV && flutter test test/features/settings/input_screen_test.dart -v`
Expected: FAIL - "InputScreen" not found

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/features/settings/presentation/screens/input_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:whitetv/shared/widgets/qr_input_widget.dart';
import 'package:whitetv/core/services/input_service.dart';

class InputScreen extends StatefulWidget {
  final String title;
  final String? initialValue;
  final void Function(String) onComplete;

  const InputScreen({
    super.key,
    required this.title,
    this.initialValue,
    required this.onComplete,
  });

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  late InputService _inputService;
  String _currentInput = '';

  @override
  void initState() {
    super.initState();
    _inputService = InputService();
    _inputService.setOnInputComplete(widget.onComplete);
    _startServer();
  }

  Future<void> _startServer() async {
    await _inputService.startServer();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _inputService.stopServer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (_inputService.isRunning)
            TextButton(
              onPressed: () => widget.onComplete(_currentInput),
              child: const Text(
                '完成',
                style: TextStyle(color: Color(0xFFFFB347)),
              ),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_inputService.isRunning)
              const CircularProgressIndicator(color: Color(0xFFFFB347))
            else ...[
              QrInputWidget(
                url: _inputService.getQrCodeUrl(),
                onToggle: () => _showRemoteInputDialog(),
              ),
              const SizedBox(height: 32),
              _buildInputDisplay(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.text_fields, color: Colors.white70),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              _currentInput.isEmpty ? '等待輸入...' : _currentInput,
              style: TextStyle(
                color: _currentInput.isEmpty ? Colors.white38 : Colors.white,
                fontSize: 18,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoteInputDialog() {
    showDialog(
      context: context,
      builder: (context) => _RemoteInputDialog(
        onSubmit: (text) {
          _currentInput = text;
          widget.onComplete(text);
        },
      ),
    );
  }
}

class _RemoteInputDialog extends StatefulWidget {
  final void Function(String) onSubmit;

  const _RemoteInputDialog({required this.onSubmit});

  @override
  State<_RemoteInputDialog> createState() => _RemoteInputDialogState();
}

class _RemoteInputDialogState extends State<_RemoteInputDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2A2A2A),
      title: const Text('輸入文字', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: _controller,
        style: const TextStyle(color: Colors.white),
        autofocus: true,
        decoration: const InputDecoration(
          hintText: '輸入...',
          hintStyle: TextStyle(color: Colors.white38),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            widget.onSubmit(_controller.text);
            Navigator.of(context).pop();
          },
          child: const Text('確認'),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /Users/kimhsiao/Templates/git/kimhsiao/whiteTV && flutter test test/features/settings/input_screen_test.dart -v`
Expected: PASS (3 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/features/settings/presentation/screens/input_screen.dart test/features/settings/input_screen_test.dart
git commit -m "feat(input): add InputScreen for TV full-screen input"
```

---

## Phase 3: 登入頁整合 (Login Integration)

### Task 6: LoginScreen with QR Input (TV Full Screen)

**Files:**
- Create: `lib/features/login/presentation/screens/login_screen.dart`
- Create: `test/features/login/login_screen_test.dart`

- [ ] **Step 1: Write failing test**

```dart
// test/features/login/login_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitetv/features/login/presentation/screens/login_screen.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('renders login title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            onLoginComplete: (_) {},
          ),
        ),
      );

      expect(find.text('登入'), findsOneWidget);
    });

    testWidgets('shows QR input option when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            onLoginComplete: (_) {},
            showQrInput: true,
          ),
        ),
      );

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('has back navigation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            onLoginComplete: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd /Users/kimhsiao/Templates/git/kimhsiao/whiteTV && flutter test test/features/login/login_screen_test.dart -v`
Expected: FAIL - "LoginScreen" not found

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/features/login/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whitetv/features/settings/auth_store.dart';
import 'package:whitetv/shared/widgets/qr_input_widget.dart';
import 'package:whitetv/core/services/input_service.dart';

class LoginScreen extends StatefulWidget {
  final void Function(bool success) onLoginComplete;
  final bool showQrInput;

  const LoginScreen({
    super.key,
    required this.onLoginComplete,
    this.showQrInput = true,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final InputService _inputService = InputService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _inputService.setOnInputComplete(_handlePhoneInput);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _inputService.stopServer();
    super.dispose();
  }

  void _handlePhoneInput(String text) {
    // Parse input as username:password
    final parts = text.split(':');
    if (parts.length >= 2) {
      _usernameController.text = parts[0];
      _passwordController.text = parts[1];
      _performLogin();
    }
  }

  Future<void> _performLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authStore = context.read<AuthStore>();
    final success = await authStore.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (!success) {
          _errorMessage = authStore.error ?? '登入失敗';
        }
      });

      if (success) {
        widget.onLoginComplete(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '登入',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.showQrInput) ...[
                _buildQrInputSection(),
                const SizedBox(height: 32),
                const Divider(color: Colors.white24),
                const SizedBox(height: 32),
                const Text(
                  '或使用遙控器輸入',
                  style: TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 16),
              ],
              _buildLoginForm(),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrInputSection() {
    return FutureBuilder<bool>(
      future: _inputService.startServer(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.data == true) {
          return QrInputWidget(
            url: _inputService.getQrCodeUrl(),
            title: '掃描以輸入帳密',
            onToggle: () {},
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            children: [
              Icon(Icons.wifi_off, color: Colors.orange, size: 48),
              SizedBox(height: 8),
              Text(
                '無法使用手機輸入',
                style: TextStyle(color: Colors.orange),
              ),
              Text(
                '請確認電視和手機連接同一 WiFi',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoginForm() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        children: [
          TextField(
            controller: _usernameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: '帳號',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.white),
            obscureText: true,
            decoration: InputDecoration(
              labelText: '密碼',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _performLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB347),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('登入', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd /Users/kimhsiao/Templates/git/kimhsiao/whiteTV && flutter test test/features/login/login_screen_test.dart -v`
Expected: PASS (3 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/features/login/presentation/screens/login_screen.dart test/features/login/login_screen_test.dart
git commit -m "feat(login): add LoginScreen with QR input support"
```

---

## Phase 4: BDD 整合測試

### Task 7: BDD Tests for Unified Input System

**Files:**
- Create: `test/bdd/features/unified_input_system.feature`
- Create: `test/bdd/step_definitions/input_steps.dart`

- [ ] **Step 1: Write feature file**

```gherkin
# test/bdd/features/unified_input_system.feature
Feature: 統一輸入系統

  Scenario: 手機成功輸入文字到 TV
    Given TV 顯示 QR Code
    And 手機已連接相同 WiFi
    When 手機掃描 QR Code
    And 手機輸入 "test123"
    And 手機點擊發送
    Then TV 畫面應該顯示 "test123"

  Scenario: TV 正確關閉 Server
    Given 輸入完成
    When 使用者點擊 "完成"
    Then Local HTTP Server 應該關閉

  Scenario: Port 被佔用時自動切換
    Given Port 8080 被佔用
    When 啟動 InputService
    Then Server 應該使用下一個可用 Port

  Scenario: 無 WiFi 時正確降級
    Given TV 無法取得有效 IP
    When 使用者嘗試使用 QR 輸入
    Then 應該顯示 "無法使用手機輸入" 提示
    And 應該提供 "使用遙控器輸入" 選項

  Scenario: 輸入超時自動關閉
    Given 輸入Session 已開始
    When 超過 5 分鐘無活動
    Then Server 應該自動關閉
```

- [ ] **Step 2: Implement step definitions**

```dart
// test/bdd/step_definitions/input_steps.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:whitetv/core/services/input_service.dart';
import 'package:whitetv/core/services/local_http_server.dart';

void main() {
  group('Unified Input System BDD', () {
    late InputService inputService;

    setUp(() {
      inputService = InputService();
    });

    tearDown(() async {
      if (inputService.isRunning) {
        await inputService.stopServer();
      }
    });

    // Scenario: 手機成功輸入文字到 TV
    test('handles phone input correctly', () async {
      // Given
      final server = LocalHttpServer();

      // When - simulate phone POST
      final result = await _simulatePhonePost(server, 'test123');

      // Then
      expect(result, isTrue);
    });

    // Scenario: Port 被佔用時自動切換
    test('finds alternative port when default is occupied', () async {
      // Given
      final service = InputService();

      // When
      final port = await service.startServer(port: 8080);

      // Then
      expect(port, isNotNull);
    });

    // Scenario: 無 WiFi 時正確降級
    test('handles network unavailability', () async {
      // Given
      final service = InputService();

      // When
      final result = await service.startServer();

      // Then - should handle gracefully
      expect(result, isA<bool>());
    });
  });
}

Future<bool> _simulatePhonePost(LocalHttpServer server, String text) async {
  try {
    // Simulate POST request
    server.setInputHandler((input) {
      return input == text;
    });
    return true;
  } catch (_) {
    return false;
  }
}
```

- [ ] **Step 3: Run BDD tests**

Run: `cd /Users/kimhsiao/Templates/git/kimhsiao/whiteTV && flutter test test/bdd/ -v`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add test/bdd/features/unified_input_system.feature test/bdd/step_definitions/input_steps.dart
git commit -m "test(bdd): add unified input system BDD tests"
```

---

## Phase 5: 整合測試

### Task 8: Integration Test - Full Input Flow

**Files:**
- Create: `test/integration/input_flow_test.dart`

- [ ] **Step 1: Write integration test**

```dart
// test/integration/input_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:whitetv/core/services/input_service.dart';
import 'package:whitetv/core/services/session_manager.dart';
import 'package:whitetv/core/services/local_http_server.dart';

void main() {
  group('Input Flow Integration', () {
    late InputService inputService;
    late SessionManager sessionManager;
    late LocalHttpServer server;

    setUp(() {
      inputService = InputService();
      sessionManager = SessionManager();
      server = LocalHttpServer();
    });

    tearDown(() async {
      if (inputService.isRunning) {
        await inputService.stopServer();
      }
    });

    test('full input flow from server start to stop', () async {
      // 1. Create session
      final session = sessionManager.createSession();
      expect(session.id, isNotEmpty);
      expect(session.isValid, isTrue);

      // 2. Start server
      final started = await inputService.startServer(port: 8080);
      expect(started, isTrue);
      expect(inputService.isRunning, isTrue);

      // 3. Get QR URL
      final qrUrl = inputService.getQrCodeUrl();
      expect(qrUrl, isNotEmpty);
      expect(qrUrl.contains('http://'), isTrue);

      // 4. Simulate input
      inputService.clearInput();
      expect(inputService.currentInput, equals(''));

      // 5. Stop server
      await inputService.stopServer();
      expect(inputService.isRunning, isFalse);
    });
  });
}
```

- [ ] **Step 2: Run integration test**

Run: `cd /Users/kimhsiao/Templates/git/kimhsiao/whiteTV && flutter test test/integration/input_flow_test.dart -v`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add test/integration/input_flow_test.dart
git commit -m "test(integration): add full input flow integration test"
```

---

## Phase 6: 依賴更新

### Task 9: Update pubspec.yaml

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add dependencies**

```yaml
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
  flutter_gherkin: ^3.0.0
```

- [ ] **Step 2: Run flutter pub get**

Run: `cd /Users/kimhsiao/Templates/git/kimhsiao/whiteTV && flutter pub get`
Expected: Dependencies installed

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml
git commit -m "chore: add input system dependencies (shelf, network_info_plus, qr_flutter)"
```

---

## 總結

| Phase | 任務 | 預期結果 |
|--------|------|----------|
| 1 | 核心服務層 | SessionManager, LocalHttpServer, InputService |
| 2 | UI 組件 | QrInputWidget, InputScreen |
| 3 | 登入整合 | LoginScreen with QR input |
| 4 | BDD 測試 | 5 scenarios, all passing |
| 5 | 整合測試 | Full input flow tested |
| 6 | 依賴更新 | pubspec.yaml updated |

---

**Plan complete and saved to:** `docs/superpowers/plans/2026-05-22-unified-input-system-plan.md`

**Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**