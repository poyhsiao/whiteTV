// lib/features/history/models/media_type.dart

/// Media type enumeration for play history classification.
enum MediaType {
  movie('movie'),
  series('series'),
  anime('anime'),
  variety('variety');

  const MediaType(this.value);
  final String value;

  static MediaType fromString(String value) {
    return MediaType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MediaType.movie,
    );
  }
}