import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

typedef InputHandler = void Function(String text);

class LocalHttpServer {
  HttpServer? _server;
  InputHandler? _inputHandler;
  String? _ipAddress;
  int? _port;
  String? _sessionToken;

  bool get isRunning => _server != null;
  int? get port => _port;
  String? get ipAddress => _ipAddress;
  String get baseUrl {
    if (_ipAddress == null || _port == null) {
      throw StateError('Server not running');
    }
    return 'http://$_ipAddress:$_port';
  }

  /// Nullable baseUrl for callers that need to handle unstarted state
  String? get baseUrlOrNull => _ipAddress != null && _port != null
      ? 'http://$_ipAddress:$_port'
      : null;

  InputHandler? get inputHandler => _inputHandler;

  void setInputHandler(InputHandler handler) {
    _inputHandler = handler;
  }

  Future<void> start({required int port, required String ipAddress}) async {
    _ipAddress = ipAddress;
    _port = port;
    final random = Random.secure();
    _sessionToken = List.generate(16, (_) => random.nextInt(36).toRadixString(36)).join();

    final router = Router();

    router.get('/', (Request request) {
      // CORS: restrict to same origin in production
      return Response.ok(
        _buildHtmlPage(_sessionToken!),
        headers: {'Content-Type': 'text/html'},
      );
    });

    router.post('/input', (Request request) async {
      // ponytail: validate token before accepting input
      if (!_validateToken(request)) {
        return Response.forbidden('{"error": "invalid token"}');
      }
      final body = await request.readAsString();
      final text = _extractText(body);
      _inputHandler?.call(text);
      return Response.ok('{"success": true}');
    });

    router.post('/clear', (Request request) {
      if (!_validateToken(request)) {
        return Response.forbidden('{"error": "invalid token"}');
      }
      _inputHandler?.call('');
      return Response.ok('{"success": true}');
    });

    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(router.call);

    _server = await shelf_io.serve(handler, ipAddress, port);
  }

  bool _validateToken(Request request) {
    // Validate token from Authorization header
    final auth = request.headers['Authorization'];
    if (auth == null) return false;
    final expected = 'Bearer $_sessionToken';
    // Constant-time comparison to prevent timing attacks
    if (auth.length != expected.length) return false;
    var result = 0;
    for (var i = 0; i < auth.length; i++) {
      result |= auth.codeUnitAt(i) ^ expected.codeUnitAt(i);
    }
    return result == 0;
  }

  String _extractText(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> && decoded['text'] is String) {
        final text = decoded['text'] as String;
        return text.replaceAll(RegExp(r'[\x00-\x1f\x7f]'), '');
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
    _sessionToken = null;
  }

  String _buildHtmlPage(String token) =>
      '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>whiteTV 輸入</title>
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
  <h2>whiteTV 輸入</h2>
  <input type="text" id="inputField" placeholder="輸入文字..." autofocus>
  <button class="btn send" onclick="send()">發送</button>
  <button class="btn clear" onclick="clearInput()">清除</button>

  <script>
    const token = document.querySelector('meta[name="token"]').getAttribute('content');
    function send() {
      const text = document.getElementById('inputField').value;
      if (text) {
        fetch('/input', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + token
          },
          body: JSON.stringify({ text })
        });
        document.getElementById('inputField').value = '';
      }
    }
    function clearInput() {
      fetch('/clear', {
        method: 'POST',
        headers: { 'Authorization': 'Bearer ' + token }
      });
      document.getElementById('inputField').value = '';
    }
  </script>
</body>
</html>
''';
}
