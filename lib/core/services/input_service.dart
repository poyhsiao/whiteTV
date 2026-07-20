import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

typedef InputHandler = void Function(String text);
typedef InputCompleteCallback = void Function(String text);

class InputService {
  HttpServer? _server;
  String? _ipAddress;
  int? _port;
  String? _sessionToken;

  String _currentInput = '';
  InputCompleteCallback? _onInputComplete;

  String? get currentIp => _ipAddress;
  int? get currentPort => _port;

  bool get isRunning => _server != null;
  String get currentInput => _currentInput;
  InputCompleteCallback? get onInputComplete => _onInputComplete;

  /// Generate a secure session token (same pattern as LocalHttpServer)
  String _generateToken() {
    final random = Random.secure();
    return List.generate(16, (_) => random.nextInt(36).toRadixString(16)).join();
  }

  /// Constant-time string comparison to prevent timing attacks
  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Validate request token against stored session token
  Response? _validateToken(Request request) {
    if (_sessionToken == null) return Response.forbidden('{"error": "server not initialized"}');
    final authHeader = request.headers['authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response.forbidden('{"error": "missing authorization"}');
    }
    final token = authHeader.substring(7);
    // Constant-time comparison to prevent timing attacks
    if (!_constantTimeEquals(token, _sessionToken!)) {
      return Response.forbidden('{"error": "invalid token"}');
    }
    return null;
  }

  Future<bool> startServer({int port = 8080}) async {
    if (_server != null) return true;

    try {
      _ipAddress = '0.0.0.0';
      _port = port;
      _sessionToken = _generateToken();

      final router = Router();

      router.get('/', (request) {
        return Response.ok(
          _getHtmlPage(_sessionToken!),
          headers: {'Content-Type': 'text/html'},
        );
      });

      router.post('/input', (Request request) async {
        final tokenError = _validateToken(request);
        if (tokenError != null) return tokenError;

        final body = await request.readAsString();
        final text = _extractText(body);
        if (text.isEmpty) {
          _currentInput = '';
        } else {
          _currentInput += text;
        }
        return Response.ok('{"success": true}');
      });

      router.post('/clear', (Request request) {
        final tokenError = _validateToken(request);
        if (tokenError != null) return tokenError;

        _currentInput = '';
        return Response.ok('{"success": true}');
      });

      final handler = const Pipeline()
          .addMiddleware(logRequests())
          .addHandler(router.call);

      _server = await shelf_io.serve(handler, _ipAddress!, _port!);
      return true;
    } catch (_) {
      return false;
    }
  }

  String _extractText(String body) {
    // Limit body size to 4KB to prevent memory exhaustion
    if (body.length > 4096) return '';
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['text'] is String) {
        return decoded['text'] as String;
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  Future<void> stopServer() async {
    if (_server == null) return;
    await _server!.close(force: true);
    _server = null;
    _ipAddress = null;
    _port = null;
    _sessionToken = null;
  }

  String getQrCodeUrl() {
    if (_ipAddress == null || _port == null) {
      return '';
    }
    return 'http://$_ipAddress:$_port/';
  }

  Stream<String> get inputStream {
    return Stream.periodic(Duration(milliseconds: 100))
        .map((_) => _currentInput)
        .distinct();
  }

  void clearInput() {
    _currentInput = '';
  }

  void setOnInputComplete(InputCompleteCallback callback) {
    _onInputComplete = callback;
  }

  /// Get the HTML page with embedded session token
  String _getHtmlPage(String token) => '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>whiteTV Input</title>
  <meta name="token" content="$token">
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; padding: 20px; background: #1a1a1a; color: #fff; }
    input { width: 100%; padding: 15px; font-size: 18px; border-radius: 8px; border: none; margin: 10px 0; box-sizing: border-box; }
    .btn { padding: 15px 30px; font-size: 18px; border-radius: 8px; border: none; cursor: pointer; margin: 5px; }
    .send { background: #ffb347; color: #000; }
    .clear { background: #666; color: #fff; }
  </style>
</head>
<body>
  <h2>whiteTV Input</h2>
  <input type="text" id="inputField" placeholder="Enter text..." autofocus>
  <button class="btn send" onclick="send()">Send</button>
  <button class="btn clear" onclick="clearInput()">Clear</button>
  <script>
    const token = document.querySelector('meta[name="token"]').getAttribute('content');
    function send() {
      const text = document.getElementById('inputField').value;
      if (!text) return;
      fetch('/input', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token
        },
        body: JSON.stringify({text: text})
      }).then(function() {
        document.getElementById('inputField').value = '';
      });
    }
    function clearInput() {
      fetch('/clear', {
        method: 'POST',
        headers: { 'Authorization': 'Bearer ' + token }
      });
      document.getElementById('inputField').value = '';
    }
    document.getElementById('inputField').addEventListener('keydown', function(e) {
      if (e.key === 'Enter') send();
    });
  </script>
</body>
</html>
''';
}