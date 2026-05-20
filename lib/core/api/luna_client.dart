import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_client.dart';
import 'models.dart';
import '../../features/search/search_state.dart';

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
  Future<Map<String, String>?> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/api/login',
        data: {'username': username, 'password': password},
      );
      if (response.data['cookie'] != null) {
        return {
          'cookie': response.data['cookie'] as String,
          'username': username,
        };
      }
      return null;
    } on DioException {
      return null;
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    final response = await _dio.get('/api/categories');
    final List<dynamic> data = response.data['categories'] ?? [];
    return data.map((json) => Category.fromJson(json)).toList();
  }

  @override
  Future<List<Video>> getVideosByCategory(String categoryId) async {
    final response = await _dio.get(
      '/api/list',
      queryParameters: {'type': categoryId},
    );
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

  @override
  Future<List<int>> search(String query, {SearchCategory? category}) async {
    try {
      final response = await _dio.get(
        '/api/search',
        queryParameters: {
          'q': query,
          if (category != null && category != SearchCategory.all)
            'category': category.apiValue,
        },
      );
      final List<dynamic> data = response.data['results'] ?? [];
      return data.map((json) => json['id'] as int).toList();
    } on DioException {
      return [];
    }
  }
}
