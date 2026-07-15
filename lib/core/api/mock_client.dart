import 'api_client.dart';
import 'models.dart';
import '../../features/search/search_state.dart';
import '../../features/history/models/play_history.dart';
import '../../features/live/data/models/ipvt_channel.dart';
import '../../features/recommend/data/models/ai_recommendation.dart';

/// Mock API Client - 用於開發/測試/離線驗證
/// 回傳模擬資料，不依賴網路

class MockClient implements ApiClient {
  static const _delay = Duration(milliseconds: 300);

  // Error simulation flags — exposed for test convenience via [configureForError]
  bool shouldThrowGetCategories = false;
  bool shouldThrowGetVideos = false;
  String videoToThrowOn = '';

  MockClient({this.videoToThrowOn = ''});

  /// Configures error simulation flags for testing.
  /// Mutates and returns `this` for chaining.
  MockClient configureForError({
    bool throwOnGetCategories = false,
    bool throwOnGetVideos = false,
    String? videoToThrowOn,
  }) {
    shouldThrowGetCategories = throwOnGetCategories;
    shouldThrowGetVideos = throwOnGetVideos;
    if (videoToThrowOn != null) this.videoToThrowOn = videoToThrowOn;
    return this;
  }

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
    if (shouldThrowGetCategories) {
      throw Exception('Mock API: Failed to fetch categories');
    }
    return _categories;
  }

  @override
  Future<List<Video>> getVideosByCategory(String categoryId) async {
    await Future.delayed(_delay);
    if (shouldThrowGetVideos && (videoToThrowOn.isEmpty || videoToThrowOn == categoryId)) {
      throw Exception('Mock API: Failed to fetch videos for $categoryId');
    }
    return _videosByCategory[categoryId] ?? [];
  }

  @override
  Future<List<Video>> getHotMovies({int limit = 20}) async {
    // 取首個電影分類的影片，按順序回傳作為熱門（不加延遲避免 pumpAndSettle 卡住）
    final movieCategory = _categories.firstWhere(
      (c) => c.id.contains('movie') || c.name.contains('電影'),
      orElse: () => _categories.isNotEmpty ? _categories.first : const Category(id: '', name: ''),
    );
    if (movieCategory.id.isEmpty) return [];
    final videos = _videosByCategory[movieCategory.id] ?? [];
    return videos.take(limit).toList();
  }

  @override
  Future<List<Video>> getRelatedVideos(String videoId, {int limit = 12}) async {
    // 找到該影片所屬分類，回傳該分類其他影片作為相關（不加延遲避免測試卡住）
    String? videoCategoryId;
    for (final entry in _videosByCategory.entries) {
      if (entry.value.any((v) => v.id == videoId)) {
        videoCategoryId = entry.key;
        break;
      }
    }
    if (videoCategoryId == null) return [];
    final videos = _videosByCategory[videoCategoryId] ?? [];
    return videos.where((v) => v.id != videoId).take(limit).toList();
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
  Future<List<Video>> search(String query, {SearchCategory? category}) async {
    await Future.delayed(_delay);
    // Sanitize search query - trim whitespace and limit length
    final sanitizedQuery = query.trim();
    if (sanitizedQuery.isEmpty || sanitizedQuery.length > 200) return [];

    // Return mock video IDs that match the query
    final allVideos = _videosByCategory.values.expand((v) => v).toList();
    final filtered = allVideos.where(
      (v) =>
          v.title.toLowerCase().contains(sanitizedQuery.toLowerCase()) &&
          (category == null ||
              category == SearchCategory.all ||
              v.categoryId == category.apiValue),
    );
    return filtered.toList();
  }

  @override
  Future<Map<String, dynamic>> getUserStats() async {
    await Future.delayed(_delay);
    return {
      'stats': {'continueWatch': []},
    };
  }

  @override
  Future<void> syncSearchHistory(List<String> history) async {
    await Future.delayed(_delay);
    // Mock implementation - just acknowledge the call
  }

  @override
  Future<List<String>> getSearchHistory() async {
    await Future.delayed(_delay);
    return [];
  }

  @override
  Future<bool> savePlayHistory(PlayHistory record) async {
    await Future.delayed(_delay);
    return true;
  }

  // IPTV Mock Data — 10+ channels covering multiple groups
  final List<IptvChannel> _mockChannels = const [
    IptvChannel(id: 'cctv1', name: 'CCTV-1 綜合', logo: 'https://example.com/cctv1.png', url: 'https://example.com/cctv1.m3u8', group: 'CCTV'),
    IptvChannel(id: 'cctv2', name: 'CCTV-2 財經', logo: 'https://example.com/cctv2.png', url: 'https://example.com/cctv2.m3u8', group: 'CCTV'),
    IptvChannel(id: 'cctv5', name: 'CCTV-5 體育', logo: 'https://example.com/cctv5.png', url: 'https://example.com/cctv5.m3u8', group: 'CCTV'),
    IptvChannel(id: 'cctv6', name: 'CCTV-6 電影', logo: 'https://example.com/cctv6.png', url: 'https://example.com/cctv6.m3u8', group: 'CCTV'),
    IptvChannel(id: 'hunan', name: '湖南衛視', logo: 'https://example.com/hunan.png', url: 'https://example.com/hunan.m3u8', group: '綜藝'),
    IptvChannel(id: 'zhejiang', name: '浙江衛視', logo: 'https://example.com/zhejiang.png', url: 'https://example.com/zhejiang.m3u8', group: '綜藝'),
    IptvChannel(id: 'dragon', name: '鳳凰衛視', logo: 'https://example.com/dragon.png', url: 'https://example.com/dragon.m3u8', group: '新聞'),
    IptvChannel(id: 'bbc', name: 'BBC World', logo: 'https://example.com/bbc.png', url: 'https://example.com/bbc.m3u8', group: '國際'),
    IptvChannel(id: 'espn', name: 'ESPN Sports', logo: 'https://example.com/espn.png', url: 'https://example.com/espn.m3u8', group: 'Sports'),
    IptvChannel(id: 'disney', name: 'Disney Channel', logo: 'https://example.com/disney.png', url: 'https://example.com/disney.m3u8', group: '兒童'),
    IptvChannel(id: 'nhk', name: 'NHK World', logo: 'https://example.com/nhk.png', url: 'https://example.com/nhk.m3u8', group: '國際'),
    IptvChannel(id: 'tvbs', name: 'TVBS 新聞', logo: 'https://example.com/tvbs.png', url: 'https://example.com/tvbs.m3u8', group: '新聞'),
  ];

  @override
  Future<List<IptvChannel>> getIptvChannels() async {
    await Future.delayed(_delay);
    return _mockChannels;
  }

  @override
  Future<String?> getIptvM3U() async {
    await Future.delayed(_delay);
    final buffer = StringBuffer('#EXTM3U\n');
    for (final channel in _mockChannels) {
      buffer.writeln(
          '#EXTINF:-1 tvg-name="${channel.name}" tvg-logo="${channel.logo}" group-title="${channel.group}",${channel.name}');
      buffer.writeln(channel.url);
    }
    return buffer.toString();
  }

  @override
  Future<Map<String, dynamic>> getIptvEpg() async {
    await Future.delayed(_delay);
    return {};
  }

  @override
  Future<List<AIRecommendation>> getAIRecommendations() async {
    await Future.delayed(_delay);
    return [];
  }

  // Local recommendations base pool
  static final List<AIRecommendation> _localRecPool = [
    AIRecommendation(id: 'mock-1', title: '星際穿越', posterUrl: 'https://picsum.photos/seed/mock1/300/450', source: 'mtzy.me', sourceName: '🎬茅台资源', reason: '根據您的觀看偏好推薦', sourceType: RecommendationSource.history, year: '2014', type: 'movie', categoryId: 'sci-fi'),
    AIRecommendation(id: 'mock-2', title: '盜夢空間', posterUrl: 'https://picsum.photos/seed/mock2/300/450', source: 'mtzy.me', sourceName: '🎬茅台资源', reason: '同類型推薦', sourceType: RecommendationSource.history, year: '2010', type: 'movie', categoryId: 'sci-fi'),
    AIRecommendation(id: 'mock-3', title: '魷魚遊戲', posterUrl: 'https://picsum.photos/seed/mock3/300/450', source: 'mtzy.me', sourceName: '🎬茅台资源', reason: '熱門劇集推薦', sourceType: RecommendationSource.popular, year: '2021', type: 'drama', categoryId: 'thriller'),
    AIRecommendation(id: 'mock-4', title: '鬼滅之刃', posterUrl: 'https://picsum.photos/seed/mock4/300/450', source: 'mtzy.me', sourceName: '🎬茅台资源', reason: '動漫愛好者都在看', sourceType: RecommendationSource.history, year: '2019', type: 'anime', categoryId: 'action'),
    AIRecommendation(id: 'mock-5', title: '月薪嬌妻', posterUrl: 'https://picsum.photos/seed/mock5/300/450', source: 'mtzy.me', sourceName: '🎬茅台资源', reason: '浪漫喜劇推薦', sourceType: RecommendationSource.search, year: '2016', type: 'drama', categoryId: 'romance'),
  ];

  @override
  Future<List<AIRecommendation>> getLocalRecommendations({
    List<String>? watchHistory,
    List<String>? searchHistory,
    int limit = 20,
  }) async {
    await Future.delayed(_delay);
    // Simple keyword-based filtering from history/search
    final keywords = <String>[];
    if (watchHistory != null) keywords.addAll(watchHistory.take(5));
    if (searchHistory != null) keywords.addAll(searchHistory.take(5));

    if (keywords.isEmpty) return _localRecPool.take(limit).toList();

    final kw = keywords.map((e) => e.toLowerCase()).toSet();
    final filtered = _localRecPool.where((r) {
      final text = '${r.title} ${r.reason} ${r.type}'.toLowerCase();
      return kw.any((k) => text.contains(k));
    }).toList();

    // Fall back to pool if filter yields too few
    return (filtered.isEmpty ? _localRecPool : filtered).take(limit).toList();
  }

  // YouTube Mock Data — 10+ videos across categories
  final List<YoutubeVideo> _mockYoutubeVideos = const [
    YoutubeVideo(id: 'yt-1', title: '2024年度最佳音樂精選', thumbnailUrl: 'https://picsum.photos/seed/yt1/320/180', channelTitle: 'Music Hub', duration: '45:30', viewCount: 520000, publishedAt: '2024-12-01', categoryId: 'music'),
    YoutubeVideo(id: 'yt-2', title: '最新流行音樂 MV', thumbnailUrl: 'https://picsum.photos/seed/yt2/320/180', channelTitle: 'MTV Official', duration: '3:45', viewCount: 890000, publishedAt: '2024-12-05', categoryId: 'music'),
    YoutubeVideo(id: 'yt-3', title: '魔獸世界資料片評測', thumbnailUrl: 'https://picsum.photos/seed/yt3/320/180', channelTitle: 'Gaming Today', duration: '22:10', viewCount: 340000, publishedAt: '2024-11-28', categoryId: 'gaming'),
    YoutubeVideo(id: 'yt-4', title: 'PS6 發表會完整版', thumbnailUrl: 'https://picsum.photos/seed/yt4/320/180', channelTitle: 'GameSpot', duration: '58:20', viewCount: 1200000, publishedAt: '2024-11-20', categoryId: 'gaming'),
    YoutubeVideo(id: 'yt-5', title: '棟篤特工專訪', thumbnailUrl: 'https://picsum.photos/seed/yt5/320/180', channelTitle: 'HK Entertainment', duration: '35:15', viewCount: 210000, publishedAt: '2024-12-03', categoryId: 'entertainment'),
    YoutubeVideo(id: 'yt-6', title: '搞笑合集 2024', thumbnailUrl: 'https://picsum.photos/seed/yt6/320/180', channelTitle: 'Funny Videos', duration: '12:45', viewCount: 670000, publishedAt: '2024-12-06', categoryId: 'entertainment'),
    YoutubeVideo(id: 'yt-7', title: 'AI 發展趨勢 2025', thumbnailUrl: 'https://picsum.photos/seed/yt7/320/180', channelTitle: 'Tech Daily', duration: '18:30', viewCount: 450000, publishedAt: '2024-11-30', categoryId: 'tech'),
    YoutubeVideo(id: 'yt-8', title: 'iPhone 17 評測', thumbnailUrl: 'https://picsum.photos/seed/yt8/320/180', channelTitle: 'MKBHD', duration: '14:20', viewCount: 980000, publishedAt: '2024-12-04', categoryId: 'tech'),
    YoutubeVideo(id: 'yt-9', title: 'Swift 6 新功能教學', thumbnailUrl: 'https://picsum.photos/seed/yt9/320/180', channelTitle: 'Swift Dev', duration: '28:45', viewCount: 180000, publishedAt: '2024-11-25', categoryId: 'tech'),
    YoutubeVideo(id: 'yt-10', title: 'Flutter 4.0 發表', thumbnailUrl: 'https://picsum.photos/seed/yt10/320/180', channelTitle: 'Flutter Team', duration: '42:00', viewCount: 750000, publishedAt: '2024-12-01', categoryId: 'tech'),
    YoutubeVideo(id: 'yt-11', title: '獨立樂團現場演奏', thumbnailUrl: 'https://picsum.photos/seed/yt11/320/180', channelTitle: 'Indie Music', duration: '55:10', viewCount: 120000, publishedAt: '2024-11-15', categoryId: 'music'),
    YoutubeVideo(id: 'yt-12', title: 'RPG 遊戲推薦 2024', thumbnailUrl: 'https://picsum.photos/seed/yt12/320/180', channelTitle: 'RPG World', duration: '33:20', viewCount: 290000, publishedAt: '2024-11-22', categoryId: 'gaming'),
  ];

  final List<YoutubeCategory> _mockYoutubeCategories = const [
    YoutubeCategory(id: 'music', name: '音樂', thumbnailUrl: 'https://picsum.photos/seed/ytcat1/320/180'),
    YoutubeCategory(id: 'gaming', name: '遊戲', thumbnailUrl: 'https://picsum.photos/seed/ytcat2/320/180'),
    YoutubeCategory(id: 'entertainment', name: '娛樂', thumbnailUrl: 'https://picsum.photos/seed/ytcat3/320/180'),
    YoutubeCategory(id: 'tech', name: '科技', thumbnailUrl: 'https://picsum.photos/seed/ytcat4/320/180'),
  ];

  @override
  Future<List<YoutubeVideo>> getYoutubeRecommend() async {
    await Future.delayed(_delay);
    return _mockYoutubeVideos;
  }

  @override
  Future<List<YoutubeVideo>> getYoutubeList(String categoryId, {String? page}) async {
    await Future.delayed(_delay);
    // Real category-based filtering — each video has a categoryId field
    if (categoryId.isEmpty) return _mockYoutubeVideos;
    return _mockYoutubeVideos.where((v) => v.categoryId == categoryId).toList();
  }

  @override
  Future<List<YoutubeCategory>> getYoutubeCategories() async {
    await Future.delayed(_delay);
    return _mockYoutubeCategories;
  }
}
