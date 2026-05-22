import 'dart:io';
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

  String _currentInput = '';
  InputCompleteCallback? _onInputComplete;

  String? get currentIp => _ipAddress;
  int? get currentPort => _port;

  bool get isRunning => _server != null;
  String get currentInput => _currentInput;
  InputCompleteCallback? get onInputComplete => _onInputComplete;

  Future<bool> startServer({int port = 8080}) async {
    if (_server != null) return true;

    try {
      _ipAddress = '0.0.0.0';
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
        if (text.isEmpty) {
          _currentInput = '';
        } else {
          _currentInput += text;
        }
        return Response.ok('{"success": true}');
      });

      router.post('/clear', (Request request) {
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

  Future<void> stopServer() async {
    if (_server == null) return;
    await _server!.close(force: true);
    _server = null;
    _ipAddress = null;
    _port = null;
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

  static const String _htmlPage = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>whiteTV Input</title>
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
    function send() {
      const text = document.getElementById('inputField').value;
      if (!text) return;
      fetch('/input', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({text: text})
      }).then(function() {
        document.getElementById('inputField').value = '';
      });
    }
    function clearInput() {
      fetch('/clear', {method: 'POST'});
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