/// API 共用模型
library;
/// 參照: docs/spec/ARCHITECTURE.md Section 3.2 LunaTV API 格式

class Category {
  final String id;
  final String name;
  final String? posterUrl;

  const Category({
    required this.id,
    required this.name,
    this.posterUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      posterUrl: json['poster_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'poster_url': posterUrl,
      };
}

class Video {
  final String id;
  final String title;
  final String? posterUrl;
  final String? description;
  final String categoryId;
  final String type;
  final String? year;

  const Video({
    required this.id,
    required this.title,
    this.posterUrl,
    this.description,
    required this.categoryId,
    required this.type,
    this.year,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      posterUrl: json['poster_url'] as String?,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      year: json['year'] as String?,
    );
  }
}

class VideoDetail {
  final String id;
  final String title;
  final String? posterUrl;
  final String? description;
  final String? category;
  final List<Episode> episodes;
  final List<VideoSource> sources;

  const VideoDetail({
    required this.id,
    required this.title,
    this.posterUrl,
    this.description,
    this.category,
    this.episodes = const [],
    this.sources = const [],
  });

  factory VideoDetail.fromJson(Map<String, dynamic> json) {
    return VideoDetail(
      id: json['id'] as String,
      title: json['title'] as String,
      posterUrl: json['poster_url'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      sources: (json['sources'] as List<dynamic>?)
              ?.map((e) => VideoSource.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Episode {
  final String id;
  final int number;
  final String? title;

  const Episode({
    required this.id,
    required this.number,
    this.title,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] as String,
      number: json['number'] as int,
      title: json['title'] as String?,
    );
  }
}

class VideoSource {
  final String id;
  final String name;
  final String url;
  final int latency;
  final bool isAvailable;

  const VideoSource({
    required this.id,
    required this.name,
    required this.url,
    this.latency = 0,
    this.isAvailable = true,
  });

  factory VideoSource.fromJson(Map<String, dynamic> json) {
    return VideoSource(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      latency: json['latency'] as int? ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }
}

enum SourceStatus { available, testing, unavailable }

extension SourceStatusX on VideoSource {
  SourceStatus get status {
    if (!isAvailable) return SourceStatus.unavailable;
    if (latency == 0) return SourceStatus.testing;
    return SourceStatus.available;
  }
}

class PlaybackError {
  final String message;
  final bool isTimeout;

  const PlaybackError({required this.message, this.isTimeout = false});
}

class YoutubeVideo {
  final String id;
  final String title;
  final String? thumbnailUrl;
  final String? thumbnail; // alias for thumbnailUrl (player_store compatibility)
  final String? channelTitle;
  final String? duration;
  final int? viewCount;
  final String? publishedAt;
  final String? url; // stream URL for player_store
  final String? categoryId; // for category-based filtering

  const YoutubeVideo({
    required this.id,
    required this.title,
    this.thumbnailUrl,
    this.thumbnail,
    this.channelTitle,
    this.duration,
    this.viewCount,
    this.publishedAt,
    this.url,
    this.categoryId,
  });

  factory YoutubeVideo.fromJson(Map<String, dynamic> json) {
    return YoutubeVideo(
      id: json['video_id'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      thumbnail: json['thumbnail'] as String? ?? json['thumbnail_url'] as String?,
      channelTitle: json['channel_title'] as String?,
      duration: json['duration'] as String?,
      viewCount: json['view_count'] as int?,
      publishedAt: json['published_at'] as String?,
      url: json['url'] as String?,
      categoryId: json['category_id'] as String?,
    );
  }

  YoutubeVideo copyWith({
    String? id,
    String? title,
    String? thumbnailUrl,
    String? thumbnail,
    String? channelTitle,
    String? duration,
    int? viewCount,
    String? publishedAt,
    String? url,
    String? categoryId,
  }) {
    return YoutubeVideo(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      thumbnail: thumbnail ?? this.thumbnail,
      channelTitle: channelTitle ?? this.channelTitle,
      duration: duration ?? this.duration,
      viewCount: viewCount ?? this.viewCount,
      publishedAt: publishedAt ?? this.publishedAt,
      url: url ?? this.url,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

class YoutubeCategory {
  final String id;
  final String name;
  final String? thumbnailUrl;

  const YoutubeCategory({
    required this.id,
    required this.name,
    this.thumbnailUrl,
  });

  factory YoutubeCategory.fromJson(Map<String, dynamic> json) {
    return YoutubeCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }
}