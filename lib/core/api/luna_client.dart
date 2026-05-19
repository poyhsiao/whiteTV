import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_client.dart';
import 'models.dart';

/// LunaTV API Client - 真實 API 串接
/// Base URL: https://moon2.kimhsiao.com

class LunaClient implements ApiClient {
  final Dio _dio;
  final String _baseUrl;

  LunaClient({Dio? dio})
      : _dio = dio ?? Dio(),
        _baseUrl = dotenv.env['LUNATV_API_URL'] ?? 'https://moon2.kimhsiao.com' {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  @override
  Future<List<Category>> getCategories() async {
    final response = await _dio.get('/api/categories');
    final List<dynamic> data = response.data['categories'] ?? [];
    return data.map((json) => Category.fromJson(json)).toList();
  }

  @override
  Future<List<Video>> getVideosByCategory(String categoryId) async {
    final response = await _dio.get('/api/list', queryParameters: {
      'type': categoryId,
    });
    final List<dynamic> data = response.data['list'] ?? [];
    return data.map((json) => Video.fromJson(json)).toList();
  }

  @override
  Future<VideoDetail> getVideoDetail(String videoId) async {
    final response = await _dio.get('/api/detail/$videoId');
    return VideoDetail.fromJson(response.data);
  }

  @override
  Future<List<VideoSource>> getSources(String videoId) async {
    final response = await _dio.get('/api/sources/$videoId');
    final List<dynamic> data = response.data['sources'] ?? [];
    return data.map((json) => VideoSource.fromJson(json)).toList();
  }

  @override
  Future<int> testSourceLatency(String sourceUrl) async {
    final stopwatch = Stopwatch()..start();
    try {
      await _dio.head(sourceUrl);
      stopwatch.stop();
      return stopwatch.elapsedMilliseconds;
    } catch (_) {
      return -1;
    }
  }
}