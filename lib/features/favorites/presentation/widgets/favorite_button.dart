import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/favorites/presentation/providers/favorites_store.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({
    super.key,
    required this.itemId,
    required this.title,
    required this.posterUrl,
    required this.type,
    this.isFavorite,
    this.onToggle,
  });

  final String itemId;
  final String title;
  final String posterUrl;
  final String type;
  final bool? isFavorite;
  final void Function(bool)? onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesState = ref.watch(favoritesStoreProvider);

    // Determine if item is favorited from prop or store state
    final itemIsFavorite = isFavorite ?? favoritesState.items.any((i) => i.id == itemId);

    return IconButton(
      icon: Icon(
        itemIsFavorite ? Icons.favorite : Icons.favorite_border,
        color: itemIsFavorite ? Colors.red : null,
      ),
      onPressed: () => _handleToggle(context, ref, itemIsFavorite),
    );
  }

  Future<void> _handleToggle(BuildContext context, WidgetRef ref, bool currentlyFavorite) async {
    final store = ref.read(favoritesStoreProvider.notifier);

    if (currentlyFavorite) {
      store.removeFavorite(itemId);
      onToggle?.call(false);
    } else {
      final item = FavoriteItem(
        id: itemId,
        title: title,
        posterUrl: posterUrl,
        type: type,
        addedAt: DateTime.now(),
      );
      store.addFavorite(item);
      onToggle?.call(true);
    }
  }
}
