import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_client.dart';
import 'models.dart';
import '../../features/search/search_state.dart';
import '../../features/history/models/play_history.dart';
import '../../features/live/data/models/ipvt_channel.dart';
import '../../features/recommend/data/models/ai_recommendation.dart';

/// LunaTV API Client - 真實 API 串接
/// Base URL: https://moon2.kimhsiao.com

class LunaClient implements ApiClient {
  final Dio _dio;
  final String _baseUrl;

  static String _resolveBaseUrl() {
    try {
      final configuredUrl = dotenv.env['LUNATV_API_URL']?.trim();
      return configuredUrl == null || configuredUrl.isEmpty
          ? 'https://moon2.kimhsiao.com'
          : configuredUrl;
    } catch (_) {
      return 'https://moon2.kimhsiao.com';
    }
  }

  LunaClient({Dio? dio, String? baseUrl})
    : _dio = dio ?? Dio(),
      _baseUrl = baseUrl ?? _resolveBaseUrl() {
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
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse &&
          (e.response?.statusCode == 401 || e.response?.statusCode == 403)) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/api/categories');
      final List<dynamic> data = response.data['categories'] ?? [];
      return data.map((json) => Category.fromJson(json)).toList();
    } on DioException catch (_) {
      // Return empty on network errors; caller handles gracefully
      return [];
    }
  }

  @override
  Future<List<Video>> getVideosByCategory(String categoryId) async {
    try {
      final response = await _dio.get(
        '/api/list',
        queryParameters: {'type': categoryId},
      );
      final List<dynamic> data = response.data['list'] ?? [];
      return data.map((json) => Video.fromJson(json)).toList();
    } on DioException {
      return [];
    }
  }

  @override
  Future<List<Video>> getHotMovies({int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/api/list',
        queryParameters: {'type': 'movie', 'sort': 'hot', 'limit': limit},
      );
      final List<dynamic> data = response.data['list'] ?? [];
      return data.map((json) => Video.fromJson(json)).toList();
    } catch (_) {
      final movies = await getVideosByCategory('movie');
      return movies.take(limit).toList();
    }
  }

  @override
  Future<List<Video>> getRelatedVideos(String videoId, {int limit = 12}) async {
    // 先取詳情拿到分類，再用分類取相關影片
    try {
      final detail = await getVideoDetail(videoId);
      final categoryId = detail.category;
      if (categoryId == null || categoryId.isEmpty) return [];
      final all = await getVideosByCategory(categoryId);
      return all.where((v) => v.id != videoId).take(limit).toList();
    } catch (_) {
      // 取得相關推薦失敗時回傳空陣列，避免回傳不相關分類影片
      return [];
    }
  }

  @override
  Future<VideoDetail> getVideoDetail(String videoId) async {
    try {
      final response = await _dio.get('/api/detail/$videoId');
      return VideoDetail.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      // Return empty detail on network errors
      return const VideoDetail(id: '', title: '');
    }
  }

  @override
  Future<List<VideoSource>> getSources(String videoId) async {
    try {
      final response = await _dio.get('/api/sources/$videoId');
      final List<dynamic> data = response.data['sources'] ?? [];
      return data.map((json) => VideoSource.fromJson(json)).toList();
    } on DioException {
      return [];
    }
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
  Future<List<Video>> search(String query, {SearchCategory? category}) async {
    try {
      // Sanitize search query - trim whitespace and limit length
      final sanitizedQuery = query.trim();
      if (sanitizedQuery.isEmpty || sanitizedQuery.length > 200) {
        return [];
      }

      final response = await _dio.get(
        '/api/search',
        queryParameters: {
          'q': sanitizedQuery,
          if (category != null && category != SearchCategory.all)
            'category': category.apiValue,
        },
      );
      final List<dynamic> data = response.data['results'] ?? [];
      return data.map((json) => Video.fromJson(json)).toList();
    } on DioException {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await _dio.get('/api/user/stats');
      return response.data as Map<String, dynamic>;
    } on DioException {
      return {};
    }
  }

  @override
  Future<void> syncSearchHistory(List<String> history) async {
    try {
      await _dio.post('/api/user/search-history', data: {'history': history});
    } on DioException {
      // Silently fail - will retry on next network event
    }
  }

  @override
  Future<List<String>> getSearchHistory() async {
    try {
      final response = await _dio.get('/api/user/search-history');
      final List<dynamic> data = response.data['history'] ?? [];
      return data.cast<String>();
    } on DioException {
      return [];
    }
  }

  @override
  Future<bool> savePlayHistory(PlayHistory record) async {
    try {
      await _dio.post('/api/user/play-history', data: record.toJson());
      return true;
    } on DioException {
      return false;
    }
  }

  @override
  Future<List<IptvChannel>> getIptvChannels() async {
    try {
      final response = await _dio.get('/api/iptv/channels');
      final List<dynamic> data = response.data['channels'] ?? [];
      return data.map((json) => IptvChannel.fromJson(json)).toList();
    } on DioException {
      return [];
    }
  }

  @override
  Future<String?> getIptvM3U() async {
    try {
      final response = await _dio.get(
        '/api/iptv/list',
        options: Options(responseType: ResponseType.plain),
      );
      return response.data as String?;
    } on DioException {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> getIptvEpg() async {
    try {
      final response = await _dio.get('/api/iptv/epg');
      return response.data as Map<String, dynamic>;
    } on DioException {
      return {};
    }
  }

  @override
  Future<List<AIRecommendation>> getAIRecommendations() async {
    try {
      final response = await _dio.get('/api/ai-recommend');
      final data = response.data;

      // 處理預期格式
      if (data['recommendations'] != null &&
          (data['recommendations'] as List).isNotEmpty) {
        return (data['recommendations'] as List).map((e) {
          final json = Map<String, dynamic>.from(e as Map);
          json['source_type'] = 'ai';
          return AIRecommendation.fromJson(json);
        }).toList();
      }

      // 處理空值情況
      if (data['total'] == 0 ||
          (data['recommendations'] as List?)?.isEmpty == true) {
        return [];
      }

      return [];
    } on DioException {
      return [];
    }
  }

  @override
  Future<List<AIRecommendation>> getLocalRecommendations({
    List<String>? watchHistory,
    List<String>? searchHistory,
    int limit = 20,
  }) async {
    // 獲取用戶統計和搜尋歷史
    final stats = await getUserStats();
    final history = searchHistory ?? await getSearchHistory();

    // 從統計中提取觀看記錄
    final watchRecords = (stats['stats']?['recentRecords'] as List?) ?? [];
    final watchTypes = <String>{};
    final watchTitles = <String>[];

    for (final record in watchRecords) {
      if (record['type'] != null) watchTypes.add(record['type'] as String);
      if (record['title'] != null) watchTitles.add(record['title'] as String);
    }

    // 搜尋相關內容
    final query = history.isNotEmpty
        ? history.first
        : (watchTypes.isNotEmpty ? watchTypes.first : '電影');

    // Use search to get recommendations based on user preferences
    try {
      final searchResults = await search(query);

      // 轉換為 AIRecommendation
      return searchResults.take(limit).map((video) {
        return AIRecommendation(
          id: video.id,
          title: video.title,
          source: 'local',
          sourceName: '本地推薦',
          sourceType: RecommendationSource.history,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<YoutubeVideo>> getYoutubeRecommend() async {
    try {
      final response = await _dio.get('/api/youtube/recommend');
      final data = response.data as Map<String, dynamic>;
      return (data['videos'] as List?)
              ?.map((v) => YoutubeVideo.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [];
    } on DioException {
      return [];
    }
  }

  @override
  Future<List<YoutubeVideo>> getYoutubeList(
    String categoryId, {
    String? page,
  }) async {
    try {
      final response = await _dio.get(
        '/api/youtube/list',
        queryParameters: {
          'category': categoryId,
          if (page != null) 'page': page,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return (data['videos'] as List?)
              ?.map((v) => YoutubeVideo.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [];
    } on DioException {
      return [];
    }
  }

  @override
  Future<List<YoutubeCategory>> getYoutubeCategories() async {
    try {
      final response = await _dio.get('/api/youtube/categories');
      final data = response.data as Map<String, dynamic>;
      return (data['categories'] as List?)
              ?.map((c) => YoutubeCategory.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [];
    } on DioException {
      return [];
    }
  }
}
