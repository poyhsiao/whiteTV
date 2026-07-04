// Sprint 5.1 — FavoritesRemoteService 真實 mock Dio 測試
// TDD 紅階段: 驗證 service 應有 fromDio factory 注入 Dio for testing
// 規範: Sprint 4 限制:production code 不可注入 Dio,改寫為可注入

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';
import 'package:white_tv/features/favorites/services/favorites_remote_service.dart';

class _MockAdapter implements HttpClientAdapter {
  final List<({String method, String path, dynamic data})> capturedRequests =
      [];
  ResponseBody Function(RequestOptions options)? reply;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    capturedRequests.add((
      method: options.method,
      path: options.path,
      data: options.data,
    ));
    if (reply != null) return reply!(options);
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }
}

FavoriteItem _fav(String id) => FavoriteItem(
  id: id,
  title: 'title-$id',
  posterUrl: 'http://x/$id.jpg',
  type: 'movie',
  addedAt: DateTime(2026, 1, 1),
);

void main() {
  group('FavoritesRemoteService.fromDio (Sprint 5.1)', () {
    late Dio dio;
    late _MockAdapter adapter;

    setUp(() {
      adapter = _MockAdapter();
      dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
      dio.httpClientAdapter = adapter;
    });

    test('fromDio 工廠: fetchFavorites 解析 list 欄位為 FavoriteItem', () async {
      adapter.reply = (options) => ResponseBody.fromString(
        '{"list": [{"id": "v1", "title": "星際", "poster": "p.jpg", "type": "movie", "available": true, "addedAt": "2026-01-01T00:00:00.000"}]}',
        200,
        headers: {
          'content-type': ['application/json'],
        },
      );

      // TDD 紅: fromDio factory 尚未存在 → 編譯錯誤
      final service = FavoritesRemoteService.fromDio(dio);
      final result = await service.fetchFavorites();

      expect(result, hasLength(1));
      expect(result.first.id, equals('v1'));
      expect(result.first.title, equals('星際'));
    });

    test('fromDio 工廠: addFavorite POST 帶正確 body', () async {
      final service = FavoritesRemoteService.fromDio(dio);

      final ok = await service.addFavorite(_fav('v1'));

      expect(ok, isTrue);
      expect(adapter.capturedRequests, hasLength(1));
      final captured = adapter.capturedRequests.first;
      expect(captured.method, equals('POST'));
      expect(captured.path, equals('/favorites'));
      expect(captured.data['id'], equals('v1'));
    });

    test('fromDio 工廠: removeFavorite DELETE 帶 id', () async {
      final service = FavoritesRemoteService.fromDio(dio);

      final ok = await service.removeFavorite('v42');

      expect(ok, isTrue);
      expect(adapter.capturedRequests.first.method, equals('DELETE'));
      expect(adapter.capturedRequests.first.path, equals('/favorites/v42'));
    });

    test('fromDio 工廠: syncToServer POST items 序列化', () async {
      final service = FavoritesRemoteService.fromDio(dio);

      final ok = await service.syncToServer([_fav('a'), _fav('b')]);

      expect(ok, isTrue);
      final captured = adapter.capturedRequests.first;
      expect(captured.method, equals('POST'));
      expect(captured.path, equals('/favorites/sync'));
      final items = captured.data['items'] as List;
      expect(items, hasLength(2));
      expect(items[0]['id'], equals('a'));
    });

    test('既有 baseUrl 建構子仍可用 (向後相容)', () {
      expect(
        () => FavoritesRemoteService(baseUrl: 'http://test.local/api'),
        returnsNormally,
      );
    });
  });
}
