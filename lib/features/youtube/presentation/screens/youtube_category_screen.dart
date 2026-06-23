import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/features/youtube/presentation/providers/youtube_store.dart';

/// YouTube 分類頁
/// 顯示 YouTube 影片分類與列表

class YoutubeCategoryScreen extends ConsumerStatefulWidget {
  final String? categoryId;

  const YoutubeCategoryScreen({super.key, this.categoryId});

  @override
  ConsumerState<YoutubeCategoryScreen> createState() =>
      _YoutubeCategoryScreenState();
}

class _YoutubeCategoryScreenState extends ConsumerState<YoutubeCategoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(youtubeStoreProvider.notifier).loadCategories();
      if (widget.categoryId != null) {
        ref.read(youtubeStoreProvider.notifier).selectCategory(widget.categoryId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(youtubeStoreProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('YouTube')),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(YoutubeState state) {
    if (state.status == YoutubeStatus.loading && state.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == YoutubeStatus.error && state.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('載入失敗：${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(youtubeStoreProvider.notifier).loadCategories(),
              child: const Text('重新整理'),
            ),
          ],
        ),
      );
    }

    if (state.categories.isEmpty) {
      return const Center(child: Text('暫無內容'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分類導航行
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: state.categories.map((category) {
                final isSelected = state.selectedCategoryId == category.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category.name),
                    selected: isSelected,
                    onSelected: (_) => ref
                        .read(youtubeStoreProvider.notifier)
                        .selectCategory(category.id),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 影片網格
        Expanded(
          child: _buildVideoGrid(state),
        ),
      ],
    );
  }

  Widget _buildVideoGrid(YoutubeState state) {
    final videos = state.selectedCategoryId != null
        ? state.videosByCategory[state.selectedCategoryId] ?? []
        : <YoutubeVideo>[];

    if (videos.isEmpty) {
      return const Center(child: Text('請選擇分類'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return _YoutubeVideoCard(video: video);
      },
    );
  }
}

class _YoutubeVideoCard extends StatelessWidget {
  const _YoutubeVideoCard({required this.video});

  final YoutubeVideo video;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to YouTube player
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 48,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video.duration ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
