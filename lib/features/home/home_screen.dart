import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:white_tv/core/device/device_type.dart';
import 'package:white_tv/core/device/device_utils.dart';
import 'package:white_tv/core/theme/typography.dart';
import 'package:white_tv/features/history/widgets/recent_watch_section.dart';
import 'package:white_tv/features/home/home_store.dart';
import 'package:white_tv/features/recommend/presentation/widgets/recommendation_carousel.dart';
import 'package:white_tv/shared/widgets/poster_card.dart';
import 'package:white_tv/shared/widgets/skeleton_loader.dart';

/// 首頁
/// 參照: docs/spec/UI_UX.md Section 3

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(homeStoreProvider.notifier).loadHome();
      ref.read(homeStoreProvider.notifier).loadAIRecommendations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeStoreProvider);
    final deviceType = DeviceUtils.getDeviceType(context);

    if (state.isLoading) {
      return const Scaffold(body: HomeSkeleton());
    }

    if (state.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('載入失敗: ${state.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(homeStoreProvider.notifier).loadHome(),
                child: const Text('重新整理'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: deviceType == DeviceType.tv
            ? _buildTVLayout(state)
            : _buildMobileLayout(state),
      ),
    );
  }

  Widget _buildTVLayout(HomeState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('whiteTV', style: AppTypography.headline),
          ),
          RecentWatchSection(
            records: state.recentHistory,
            onTap: (record) => _navigateToDetail(record.videoId),
            showProgress: true,
          ),
          if (state.aiRecommendations.isNotEmpty) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: RecommendationCarousel(
                title: '為你推薦',
                recommendations: state.aiRecommendations,
                onRefresh: () => ref.read(homeStoreProvider.notifier).loadAIRecommendations(),
                onRecommendationTap: (recommendation) {
                  _navigateToDetail(recommendation.id);
                },
              ),
            ),
          ],
          ...state.categories.map((category) {
            final videos = state.videosByCategory[category.id] ?? [];
            return _buildCategoryRow(category.name, videos, isTV: true);
          }),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(HomeState state) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('whiteTV', style: AppTypography.headline),
        ),
        RecentWatchSection(
          records: state.recentHistory,
          onTap: (record) => _navigateToDetail(record.videoId),
        ),
        if (state.aiRecommendations.isNotEmpty) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RecommendationCarousel(
              title: '為你推薦',
              recommendations: state.aiRecommendations,
              onRefresh: () => ref.read(homeStoreProvider.notifier).loadAIRecommendations(),
              onRecommendationTap: (recommendation) {
                _navigateToDetail(recommendation.id);
              },
            ),
          ),
        ],
        ...state.categories.map((category) {
          final videos = state.videosByCategory[category.id] ?? [];
          return _buildCategoryGrid(category.name, videos);
        }),
      ],
    );
  }

  Widget _buildCategoryRow(String title, List videos, {required bool isTV}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title, style: AppTypography.title),
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: videos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final video = videos[index];
              return PosterCard(
                title: video.title,
                posterUrl: video.posterUrl,
                onTap: () => _navigateToDetail(video.id),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCategoryGrid(String title, List videos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title, style: AppTypography.title),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return PosterCard(
              title: video.title,
              posterUrl: video.posterUrl,
              width: double.infinity,
              height: double.infinity,
              onTap: () => _navigateToDetail(video.id),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _navigateToDetail(String videoId) {
    context.push('/detail/$videoId');
  }
}
