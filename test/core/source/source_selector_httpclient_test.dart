// Sprint 8.2 — SourceSelector HttpClient factory
// Verifies SourceSelector accepts an HttpClient factory so tests can avoid
// touching dart:io's real HttpClient.

import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/core/source/source_selector.dart';

/// In-memory HttpClient stub that records headUrl calls and returns a
/// pre-programmed response.
class _StubHttpClient implements HttpClient {
  final List<Uri> headCalls = [];
  final int responseMillis;
  final bool shouldThrow;

  _StubHttpClient({this.responseMillis = 50, this.shouldThrow = false});

  @override
  Duration? connectionTimeout = const Duration(seconds: 5);

  @override
  Future<HttpClientRequest> headUrl(Uri url) async {
    headCalls.add(url);
    if (shouldThrow) {
      throw const SocketException('stub network down');
    }
    return _StubRequest(responseMillis);
  }

  @override
  noSuchMethod(Invocation invocation) {
    final name = invocation.memberName.toString();
    if (name == 'Symbol("close")') return null;
    if (name == 'Symbol("connectionTimeout")') return connectionTimeout;
    if (name == 'Symbol("connectionTimeout=")') return null;
    throw UnimplementedError('StubHttpClient.${invocation.memberName}');
  }
}

class _StubRequest implements HttpClientRequest {
  _StubRequest(this.responseMillis);
  final int responseMillis;

  @override
  Future<HttpClientResponse> close() async {
    await Future<void>.delayed(Duration(milliseconds: responseMillis));
    return _StubResponse();
  }

  @override
  noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('StubRequest.${invocation.memberName}');
}

class _StubResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('StubResponse.${invocation.memberName}');
}

void main() {
  group('SourceSelector HttpClient injection', () {
    test('testSingleSource uses injected HttpClient factory', () async {
      final stub = _StubHttpClient(responseMillis: 30);
      final selector = SourceSelector(httpClientFactory: () => stub);

      final source = VideoSource(
        id: 's1',
        name: 'stub',
        url: 'https://example.test/stream.m3u8',
      );

      final result = await selector.testSingleSource(source);

      expect(stub.headCalls, hasLength(1));
      expect(stub.headCalls.single.toString(), 'https://example.test/stream.m3u8');
      expect(result.isAvailable, isTrue);
      expect(result.latency, greaterThanOrEqualTo(30));
    });

    test('testSingleSource marks source unavailable when HttpClient throws', () async {
      final stub = _StubHttpClient(shouldThrow: true);
      final selector = SourceSelector(httpClientFactory: () => stub);

      final source = VideoSource(
        id: 's2',
        name: 'down',
        url: 'https://broken.test/stream.m3u8',
      );

      final result = await selector.testSingleSource(source);

      expect(result.isAvailable, isFalse);
      expect(result.latency, 9999);
    });

    test('default ctor still uses dart:io HttpClient (backward compatible)', () {
      final selector = SourceSelector();
      // Just verify the ctor didn't throw; behavior is exercised elsewhere.
      expect(selector, isA<SourceSelector>());
    });
  });
}