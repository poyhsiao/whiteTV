// lib/features/recommend/data/models/ai_recommendation.dart

enum RecommendationSource {
  ai,
  history,
  popular,
  search,
}

class AIRecommendation {
  final String id;
  final String title;
  final String? posterUrl;
  final String? description;
  final String source;
  final String sourceName;
  final String? reason;
  final RecommendationSource sourceType;
  final String? year;
  final String? type;
  final String? doubanId;
  final int? episodeTotal;
  final String? categoryId; // for local recommendation filtering

  const AIRecommendation({
    required this.id,
    required this.title,
    this.posterUrl,
    this.description,
    required this.source,
    required this.sourceName,
    this.reason,
    required this.sourceType,
    this.year,
    this.type,
    this.doubanId,
    this.episodeTotal,
    this.categoryId,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      posterUrl: json['poster'] as String? ?? json['poster_url'] as String?,
      description: json['desc'] as String? ?? json['description'] as String?,
      source: json['source'] as String? ?? 'unknown',
      sourceName: json['source_name'] as String? ?? json['sourceName'] as String? ?? '未知來源',
      reason: json['reason'] as String?,
      sourceType: _parseSourceType(json['source_type'] as String?),
      year: (json['year'] ?? json['release_year'])?.toString(),
      type: json['type'] as String? ?? json['type_name'] as String?,
      doubanId: json['douban_id']?.toString(),
      episodeTotal: json['total_episodes'] as int? ?? json['episodeTotal'] as int?,
      categoryId: json['category_id'] as String?,
    );
  }

  static RecommendationSource _parseSourceType(String? value) {
    switch (value) {
      case 'ai':
        return RecommendationSource.ai;
      case 'history':
        return RecommendationSource.history;
      case 'popular':
        return RecommendationSource.popular;
      case 'search':
        return RecommendationSource.search;
      default:
        return RecommendationSource.ai;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'poster_url': posterUrl,
        'description': description,
        'source': source,
        'source_name': sourceName,
        'reason': reason,
        'source_type': sourceType.name,
        'year': year,
        'type': type,
        'douban_id': doubanId,
        'total_episodes': episodeTotal,
        'category_id': categoryId,
      };
}