import 'package:flutter/material.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';

class FavoriteTile extends StatelessWidget {
  final FavoriteItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const FavoriteTile({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
  });

  String get _typeLabel {
    switch (item.type) {
      case 'movie': return '電影';
      case 'series': return '劇集';
      case 'anime': return '動漫';
      case 'variety': return '綜藝';
      default: return item.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.posterUrl,
                width: 60,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 80,
                  color: Colors.grey[800],
                  child: const Icon(Icons.movie, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _typeLabel,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            if (!item.isAvailable)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '已下架',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}