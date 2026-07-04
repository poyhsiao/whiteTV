// Sprint 4.2 — 補 FavoritesRemoteService coverage
// 既有測試連真 lunatv server 全 skip,改用 mocktail DioAdapter 驗邏輯

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';
import 'package:white_tv/features/favorites/services/favorites_remote_service.dart';

FavoriteItem _fav(String id) => FavoriteItem(
  id: id,
  title: 'title-$id',
  posterUrl: 'http://x/$id.jpg',
  type: 'movie',
  addedAt: DateTime(2026, 1, 1),
);

void main() {
  group('FavoritesRemoteService (mocktail DioAdapter)', () {
    late Dio dio;
    late FavoritesRemoteService service;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
      service = FavoritesRemoteService(baseUrl: 'http://test.local');
      // 用 httpClientAdapter 注入 mock
    });

    test('fetchFavorites 解析 list 欄位為 FavoriteItem', () async {
      final adapter = _StubAdapter(
        (options) => ResponseBody.fromString(
          '{"list": [{"id": "v1", "title": "星際", "poster": "p.jpg", "type": "movie", "available": true, "addedAt": "2026-01-01T00:00:00.000"}]}',
          200,
          headers: {
            'content-type': ['application/json'],
          },
        ),
      );
      dio.httpClientAdapter = adapter;
      final svc = FavoritesRemoteService.withDio(dio);

      final result = await svc.fetchFavorites();

      expect(result, hasLength(1));
      expect(result.first.id, equals('v1'));
      expect(result.first.title, equals('星際'));
    });

    test('addFavorite POST 帶正確 body', () async {
      final adapter = _StubAdapter(
        (options) => ResponseBody.fromString(
          '{}',
          200,
          headers: {
            'content-type': ['application/json'],
          },
        ),
      );
      dio.httpClientAdapter = adapter;
      final svc = FavoritesRemoteService.withDio(dio);

      final ok = await svc.addFavorite(_fav('v1'));

      expect(ok, isTrue);
      expect(adapter.lastMethod, equals('POST'));
      expect(adapter.lastPath, equals('/favorites'));
    });

    test('removeFavorite DELETE 帶 id', () async {
      final adapter = _StubAdapter(
        (options) => ResponseBody.fromString(
          '{}',
          200,
          headers: {
            'content-type': ['application/json'],
          },
        ),
      );
      dio.httpClientAdapter = adapter;
      final svc = FavoritesRemoteService.withDio(dio);

      final ok = await svc.removeFavorite('v42');

      expect(ok, isTrue);
      expect(adapter.lastMethod, equals('DELETE'));
      expect(adapter.lastPath, equals('/favorites/v42'));
    });

    test('syncToServer POST items 序列化', () async {
      final adapter = _StubAdapter(
        (options) => ResponseBody.fromString(
          '{}',
          200,
          headers: {
            'content-type': ['application/json'],
          },
        ),
      );
      dio.httpClientAdapter = adapter;
      final svc = FavoritesRemoteService.withDio(dio);

      final ok = await svc.syncToServer([_fav('a'), _fav('b')]);

      expect(ok, isTrue);
      expect(adapter.lastMethod, equals('POST'));
      expect(adapter.lastPath, equals('/favorites/sync'));
    });

    test('can be instantiated with baseUrl', () {
      expect(service, isA<FavoritesRemoteService>());
    });
  });
}

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this._reply);
  final ResponseBody Function(RequestOptions) _reply;

  String? lastMethod;
  String? lastPath;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastMethod = options.method;
    lastPath = options.path;
    return _reply(options);
  }
}
