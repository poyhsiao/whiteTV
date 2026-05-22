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