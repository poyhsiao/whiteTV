import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:white_tv/features/favorites/presentation/providers/favorites_store.dart';
import 'package:white_tv/features/favorites/presentation/widgets/favorite_tile.dart';
import 'package:white_tv/features/favorites/presentation/widgets/favorite_grid.dart';
import 'package:white_tv/features/favorites/presentation/widgets/favorites_filter_bar.dart';
import 'package:white_tv/shared/widgets/empty_state.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesStoreProvider);
    final store = ref.read(favoritesStoreProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        actions: [
          IconButton(
            icon: Icon(state.isGridView ? Icons.list : Icons.grid_view),
            onPressed: store.toggleView,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          FavoritesFilterBar(
            selectedType: state.filterType,
            onTypeSelected: store.setFilterType,
          ),
          const SizedBox(height: 8),
          if (state.isSyncing)
            const LinearProgressIndicator(),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(state.error!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: store.loadFavorites,
                              child: const Text('重試'),
                            ),
                          ],
                        ),
                      )
                    : state.filteredItems.isEmpty
                        ? EmptyStateWidget(
                            icon: Icons.favorite_border,
                            title: '還沒有收藏任何內容',
                            subtitle: '開始探索你喜歡的電影和節目',
                            actionLabel: '開始探索',
                            onAction: () => context.go('/'),
                          )
                        : state.isGridView
                            ? FavoriteGrid(
                                items: state.filteredItems,
                                onTap: (id) {},
                                onLongPress: (id) {
                                  _showDeleteDialog(context, store, id);
                                },
                              )
                            : ListView.builder(
                                itemCount: state.filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = state.filteredItems[index];
                                  return FavoriteTile(
                                    item: item,
                                    onTap: () {},
                                    onLongPress: () {
                                      _showDeleteDialog(context, store, item.id);
                                    },
                                  );
                                },
                              ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, FavoritesStore store, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('移除收藏'),
        content: const Text('確定要移除這個收藏嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              store.removeFavorite(id);
              Navigator.pop(context);
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }
}