// test/core/api/luna_client_test.dart
// LunaClient unit tests — use Answer+throw for errors
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:white_tv/core/api/luna_client.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late LunaClient client;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(Options());
  });

  setUp(() {
    mockDio = MockDio();
    when(() => mockDio.options).thenReturn(BaseOptions());
    when(() => mockDio.interceptors).thenReturn(Interceptors());
    client = LunaClient(dio: mockDio, baseUrl: 'https://test.example.com');
  });

  // ---------------------------------------------------------------------------
  // getCategories
  // ---------------------------------------------------------------------------
  group('getCategories', () {
    test('returns categories on 200', () async {
      when(() => mockDio.get('/api/categories')).thenAnswer((_) async =>
        Response(data: {'categories': [
          {'id': 'movie', 'name': '電影'},
          {'id': 'drama', 'name': '電視劇'},
        ]}, statusCode: 200, requestOptions: RequestOptions(path: '/api/categories')));
      expect((await client.getCategories()).length, 2);
    });

    test('returns empty on DioException', () async {
      when(() => mockDio.get('/api/categories')).thenAnswer(
        (_) async => throw DioException(requestOptions: RequestOptions(path: '/api/categories')));
      expect(await client.getCategories(), isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // getHotMovies — stubs both hot path and fallback path
  // ---------------------------------------------------------------------------
  group('getHotMovies', () {
    test('parses from /api/list with hot params', () async {
      when(() => mockDio.get('/api/list', queryParameters: {'type': 'movie', 'sort': 'hot', 'limit': 5}))
        .thenAnswer((_) async => Response(
          data: {'list': [
            {'id': 'v1', 'title': '熱門電影', 'category_id': 'movie', 'type': 'movie', 'poster_url': 'http://x.com/p.jpg'},
          ]}, statusCode: 200, requestOptions: RequestOptions(path: '/api/list')));
      when(() => mockDio.get('/api/list', queryParameters: {'type': 'movie'}))
        .thenAnswer((_) async => Response(
          data: {'list': []}, statusCode: 200, requestOptions: RequestOptions(path: '/api/list')));
      expect((await client.getHotMovies(limit: 5))[0].title, '熱門電影');
    });

    test('returns empty on DioException', () async {
      // Stub BOTH possible paths: hot path and fallback path
      when(() => mockDio.get('/api/list', queryParameters: {'type': 'movie', 'sort': 'hot', 'limit': 20}))
        .thenAnswer((_) async => throw DioException(requestOptions: RequestOptions(path: '/api/list')));
      when(() => mockDio.get('/api/list', queryParameters: {'type': 'movie'}))
        .thenAnswer((_) async => throw DioException(requestOptions: RequestOptions(path: '/api/list')));
      expect(await client.getHotMovies(), isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // getVideoDetail
  // ---------------------------------------------------------------------------
  group('getVideoDetail', () {
    test('parses detail from 200', () async {
      when(() => mockDio.get('/api/detail/abc')).thenAnswer((_) async =>
        Response(data: {'id': 'abc', 'title': '星際穿越', 'category': 'movie', 'poster_url': 'http://x.com/poster.jpg'},
          statusCode: 200, requestOptions: RequestOptions(path: '/api/detail/abc')));
      expect((await client.getVideoDetail('abc')).id, 'abc');
    });

    test('returns empty detail on 404 (graceful degradation)', () async {
      when(() => mockDio.get('/api/detail/notfound')).thenAnswer(
        (_) async => throw DioException(
          requestOptions: RequestOptions(path: '/api/detail/notfound'),
          response: Response(statusCode: 404, requestOptions: RequestOptions(path: '/api/detail/notfound'))));
      final detail = await client.getVideoDetail('notfound');
      expect(detail.id, '');
      expect(detail.title, '');
    });
  });

  // ---------------------------------------------------------------------------
  // getSources
  // ---------------------------------------------------------------------------
  group('getSources', () {
    test('parses sources from 200', () async {
      when(() => mockDio.get('/api/sources/abc')).thenAnswer((_) async =>
        Response(data: {'sources': [
          {'id': 's1', 'name': '量子資源', 'url': 'https://x.com/s1', 'latency': 120},
        ]}, statusCode: 200, requestOptions: RequestOptions(path: '/api/sources/abc')));
      expect((await client.getSources('abc'))[0].name, '量子資源');
    });

    test('returns empty on DioException', () async {
      when(() => mockDio.get('/api/sources/abc')).thenAnswer(
        (_) async => throw DioException(requestOptions: RequestOptions(path: '/api/sources/abc')));
      expect(await client.getSources('abc'), isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // testSourceLatency
  // ---------------------------------------------------------------------------
  group('testSourceLatency', () {
    test('returns ms on success', () async {
      when(() => mockDio.head(any(), options: any(named: 'options'))).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 10));
        return Response(data: null, statusCode: 200, requestOptions: RequestOptions(path: 'https://x.com'));
      });
      expect(await client.testSourceLatency('https://x.com'), greaterThanOrEqualTo(0));
    });

    test('returns -1 on exception', () async {
      when(() => mockDio.head(any(), options: any(named: 'options'))).thenAnswer(
        (_) async => throw DioException(requestOptions: RequestOptions(path: 'https://x.com'), type: DioExceptionType.connectionTimeout));
      expect(await client.testSourceLatency('https://x.com'), -1);
    });
  });

  // ---------------------------------------------------------------------------
  // search
  // ---------------------------------------------------------------------------
  group('search', () {
    test('parses videos from 200', () async {
      when(() => mockDio.get('/api/search', queryParameters: {'q': '星際'}))
        .thenAnswer((_) async => Response(
          data: {'results': [
            {'id': 'v1', 'title': '星際穿越', 'category_id': 'movie', 'type': 'movie', 'poster_url': 'http://x.com/p.jpg'},
          ]}, statusCode: 200, requestOptions: RequestOptions(path: '/api/search')));
      expect((await client.search('星際'))[0].title, '星際穿越');
    });

    test('returns empty on DioException', () async {
      when(() => mockDio.get('/api/search', queryParameters: any(named: 'queryParameters'))).thenAnswer(
        (_) async => throw DioException(requestOptions: RequestOptions(path: '/api/search')));
      expect(await client.search('test'), isEmpty);
    });

    test('returns empty for whitespace query', () async {
      expect(await client.search('   '), isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // getUserStats
  // ---------------------------------------------------------------------------
  group('getUserStats', () {
    test('parses from 200', () async {
      when(() => mockDio.get('/api/user/stats')).thenAnswer((_) async =>
        Response(data: {'favoriteCount': 5}, statusCode: 200, requestOptions: RequestOptions(path: '/api/user/stats')));
      expect((await client.getUserStats())['favoriteCount'], 5);
    });

    test('returns empty map on DioException', () async {
      when(() => mockDio.get('/api/user/stats')).thenAnswer(
        (_) async => throw DioException(requestOptions: RequestOptions(path: '/api/user/stats')));
      expect(await client.getUserStats(), isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // getIptvChannels
  // ---------------------------------------------------------------------------
  group('getIptvChannels', () {
    test('parses channels from 200', () async {
      when(() => mockDio.get('/api/iptv/channels')).thenAnswer((_) async =>
        Response(data: {'channels': [
          {'id': 'ch1', 'name': 'CCTV-1', 'logo': 'http://x.com/l.png', 'url': 'http://x.com/ch1.m3u8', 'group': 'CCTV'},
        ]}, statusCode: 200, requestOptions: RequestOptions(path: '/api/iptv/channels')));
      expect((await client.getIptvChannels())[0].name, 'CCTV-1');
    });

    test('returns empty on DioException', () async {
      when(() => mockDio.get('/api/iptv/channels')).thenAnswer(
        (_) async => throw DioException(requestOptions: RequestOptions(path: '/api/iptv/channels')));
      expect(await client.getIptvChannels(), isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // getAIRecommendations
  // ---------------------------------------------------------------------------
  group('getAIRecommendations', () {
    test('parses from 200', () async {
      when(() => mockDio.get('/api/ai-recommend')).thenAnswer((_) async =>
        Response(data: {'recommendations': [
          {'id': 'r1', 'title': '推薦電影', 'source': 'luna', 'source_name': 'Luna', 'source_type': 'ai'},
        ]}, statusCode: 200, requestOptions: RequestOptions(path: '/api/ai-recommend')));
      expect((await client.getAIRecommendations())[0].title, '推薦電影');
    });

    test('returns empty when total is 0', () async {
      when(() => mockDio.get('/api/ai-recommend')).thenAnswer((_) async =>
        Response(data: {'total': 0, 'recommendations': []}, statusCode: 200, requestOptions: RequestOptions(path: '/api/ai-recommend')));
      expect(await client.getAIRecommendations(), isEmpty);
    });

    test('returns empty on DioException', () async {
      when(() => mockDio.get('/api/ai-recommend')).thenAnswer(
        (_) async => throw DioException(requestOptions: RequestOptions(path: '/api/ai-recommend')));
      expect(await client.getAIRecommendations(), isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // getYoutubeRecommend
  // ---------------------------------------------------------------------------
  group('getYoutubeRecommend', () {
    test('parses from 200', () async {
      when(() => mockDio.get('/api/youtube/recommend')).thenAnswer((_) async =>
        Response(data: {'videos': [{'video_id': 'yt1', 'title': 'YouTube 推薦'}]},
          statusCode: 200, requestOptions: RequestOptions(path: '/api/youtube/recommend')));
      expect((await client.getYoutubeRecommend())[0].title, 'YouTube 推薦');
    });

    test('returns empty on DioException', () async {
      when(() => mockDio.get('/api/youtube/recommend')).thenAnswer(
        (_) async => throw DioException(requestOptions: RequestOptions(path: '/api/youtube/recommend')));
      expect(await client.getYoutubeRecommend(), isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // getYoutubeCategories
  // ---------------------------------------------------------------------------
  group('getYoutubeCategories', () {
    test('parses from 200', () async {
      when(() => mockDio.get('/api/youtube/categories')).thenAnswer((_) async =>
        Response(data: {'categories': [{'id': 'music', 'name': '音樂'}]},
          statusCode: 200, requestOptions: RequestOptions(path: '/api/youtube/categories')));
      expect((await client.getYoutubeCategories())[0].name, '音樂');
    });

    test('returns empty on DioException', () async {
      when(() => mockDio.get('/api/youtube/categories')).thenAnswer(
        (_) async => throw DioException(requestOptions: RequestOptions(path: '/api/youtube/categories')));
      expect(await client.getYoutubeCategories(), isEmpty);
    });
  });
}
