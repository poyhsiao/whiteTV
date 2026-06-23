class YoutubeVideo {
  final String id;
  final String title;
  final String thumbnail;
  final String duration;
  final String url;

  const YoutubeVideo({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.duration,
    required this.url,
  });

  factory YoutubeVideo.fromJson(Map<String, dynamic> json) {
    return YoutubeVideo(
      id: json['id'] as String,
      title: json['title'] as String,
      thumbnail: json['thumbnail'] as String,
      duration: json['duration'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'duration': duration,
      'url': url,
    };
  }

  YoutubeVideo copyWith({
    String? id,
    String? title,
    String? thumbnail,
    String? duration,
    String? url,
  }) {
    return YoutubeVideo(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
      url: url ?? this.url,
    );
  }
}

class YoutubeCategory {
  final String id;
  final String name;
  final int videoCount;

  const YoutubeCategory({
    required this.id,
    required this.name,
    required this.videoCount,
  });

  factory YoutubeCategory.fromJson(Map<String, dynamic> json) {
    return YoutubeCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      videoCount: json['videoCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'videoCount': videoCount,
    };
  }
}
