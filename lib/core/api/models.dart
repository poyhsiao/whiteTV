/// API 共用模型
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
      id: json['id'] as String,
      name: json['name'] as String,
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

  const Video({
    required this.id,
    required this.title,
    this.posterUrl,
    this.description,
    required this.categoryId,
    required this.type,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as String,
      title: json['title'] as String,
      posterUrl: json['poster_url'] as String?,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String,
      type: json['type'] as String,
    );
  }
}

class VideoDetail {
  final String id;
  final String title;
  final String? posterUrl;
  final String? description;
  final List<Episode> episodes;
  final List<VideoSource> sources;

  const VideoDetail({
    required this.id,
    required this.title,
    this.posterUrl,
    this.description,
    this.episodes = const [],
    this.sources = const [],
  });

  factory VideoDetail.fromJson(Map<String, dynamic> json) {
    return VideoDetail(
      id: json['id'] as String,
      title: json['title'] as String,
      posterUrl: json['poster_url'] as String?,
      description: json['description'] as String?,
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