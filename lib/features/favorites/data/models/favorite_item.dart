class FavoriteItem {
  final String id;
  final String title;
  final String posterUrl;
  final String type;
  final bool isAvailable;
  final DateTime addedAt;

  const FavoriteItem({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.type,
    this.isAvailable = true,
    required this.addedAt,
  });

  FavoriteItem copyWith({
    String? id,
    String? title,
    String? posterUrl,
    String? type,
    bool? isAvailable,
    DateTime? addedAt,
  }) {
    return FavoriteItem(
      id: id ?? this.id,
      title: title ?? this.title,
      posterUrl: posterUrl ?? this.posterUrl,
      type: type ?? this.type,
      isAvailable: isAvailable ?? this.isAvailable,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}