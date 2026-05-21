import 'api_client.dart';
import 'models.dart';
import '../../features/search/search_state.dart';

/// Mock API Client - 用於開發/測試/離線驗證
/// 回傳模擬資料，不依賴網路

class MockClient implements ApiClient {
  static const _delay = Duration(milliseconds: 300);

  final List<Category> _categories = const [
    Category(id: 'movie', name: '電影'),
    Category(id: 'drama', name: '電視劇'),
    Category(id: 'anime', name: '動漫'),
    Category(id: 'variety', name: '綜藝'),
  ];

  final Map<String, List<Video>> _videosByCategory = {
    'movie': [
      const Video(
        id: 'movie-1',
        title: '星際穿越',
        posterUrl: 'https://picsum.photos/seed/movie1/300/450',
        description: '一部關於星際旅行的科幻電影',
        categoryId: 'movie',
        type: 'movie',
      ),
      const Video(
        id: 'movie-2',
        title: '盗梦空间',
        posterUrl: 'https://picsum.photos/seed/movie2/300/450',
        description: '關於夢境與現實的懸疑電影',
        categoryId: 'movie',
        type: 'movie',
      ),
    ],
    'drama': [
      const Video(
        id: 'drama-1',
        title: '魷魚遊戲',
        posterUrl: 'https://picsum.photos/seed/drama1/300/450',
        description: '一場神秘的生死遊戲',
        categoryId: 'drama',
        type: 'drama',
      ),
    ],
    'anime': [
      const Video(
        id: 'anime-1',
        title: '鬼滅之刃',
        posterUrl: 'https://picsum.photos/seed/anime1/300/450',
        description: '鬼殺隊的故事',
        categoryId: 'anime',
        type: 'anime',
      ),
    ],
    'variety': [
      const Video(
        id: 'variety-1',
        title: '奔跑吧兄弟',
        posterUrl: 'https://picsum.photos/seed/variety1/300/450',
        description: '大型戶外競技真人秀',
        categoryId: 'variety',
        type: 'variety',
      ),
    ],
  };

  @override
  Future<Map<String, String>?> login(String username, String password) async {
    await Future.delayed(_delay);
    if (username.isNotEmpty && password.isNotEmpty) {
      return {
        'cookie': 'mock-cookie-${DateTime.now().millisecondsSinceEpoch}',
        'username': username,
      };
    }
    return null;
  }

  @override
  Future<List<Category>> getCategories() async {
    await Future.delayed(_delay);
    return _categories;
  }

  @override
  Future<List<Video>> getVideosByCategory(String categoryId) async {
    await Future.delayed(_delay);
    return _videosByCategory[categoryId] ?? [];
  }

  @override
  Future<VideoDetail> getVideoDetail(String videoId) async {
    await Future.delayed(_delay);
    for (final videos in _videosByCategory.values) {
      for (final video in videos) {
        if (video.id == videoId) {
          return VideoDetail(
            id: video.id,
            title: video.title,
            posterUrl: video.posterUrl,
            description: video.description,
            episodes: _generateEpisodes(videoId, 12),
            sources: _generateSources(videoId),
          );
        }
      }
    }
    throw Exception('Video not found: $videoId');
  }

  @override
  Future<List<VideoSource>> getSources(String videoId) async {
    await Future.delayed(_delay);
    return _generateSources(videoId);
  }

  @override
  Future<int> testSourceLatency(String sourceUrl) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 50 + (sourceUrl.hashCode % 200);
  }

  List<Episode> _generateEpisodes(String videoId, int count) {
    return List.generate(
      count,
      (i) => Episode(
        id: '$videoId-ep-${i + 1}',
        number: i + 1,
        title: '第 ${i + 1} 集',
      ),
    );
  }

  List<VideoSource> _generateSources(String videoId) {
    return [
      VideoSource(
        id: '${videoId}_source_1',
        name: '量子資源',
        url: 'https://example.com/stream/$videoId/1',
        latency: 120,
        isAvailable: true,
      ),
      VideoSource(
        id: '${videoId}_source_2',
        name: '非凡資源',
        url: 'https://example.com/stream/$videoId/2',
        latency: 85,
        isAvailable: true,
      ),
      VideoSource(
        id: '${videoId}_source_3',
        name: '雲播資源',
        url: 'https://example.com/stream/$videoId/3',
        latency: 200,
        isAvailable: true,
      ),
    ];
  }

  @override
  Future<List<int>> search(String query, {SearchCategory? category}) async {
    await Future.delayed(_delay);
    // Sanitize search query - trim whitespace and limit length
    final sanitizedQuery = query.trim();
    if (sanitizedQuery.isEmpty || sanitizedQuery.length > 200) return [];

    // Return mock video IDs that match the query
    final allVideos = _videosByCategory.values.expand((v) => v).toList();
    final filtered = allVideos.where((v) =>
        v.title.toLowerCase().contains(sanitizedQuery.toLowerCase()) &&
        (category == null ||
            category == SearchCategory.all ||
            v.categoryId == category.apiValue));
    return filtered.map((v) => v.id.hashCode).toList();
  }
}
