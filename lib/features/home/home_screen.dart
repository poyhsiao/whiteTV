import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:white_tv/core/device/device_type.dart';
import 'package:white_tv/core/device/device_utils.dart';
import 'package:white_tv/core/theme/colors.dart';
import 'package:white_tv/core/theme/typography.dart';
import 'package:white_tv/features/history/widgets/recent_watch_section.dart';
import 'package:white_tv/features/home/home_store.dart';
import 'package:white_tv/features/recommend/presentation/widgets/recommendation_carousel.dart';
import 'package:white_tv/shared/widgets/poster_card.dart';
import 'package:white_tv/features/settings/settings_store.dart';
import 'package:white_tv/shared/widgets/skeleton_loader.dart';
import 'package:white_tv/features/youtube/presentation/providers/youtube_store.dart';
import 'package:white_tv/features/youtube/presentation/widgets/youtube_section.dart';

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
      ref.read(youtubeStoreProvider.notifier).loadRecommend();
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
      key: const Key('home_screen'),
      body: SafeArea(
        child: deviceType == DeviceType.tv
            ? _buildTVLayout(state)
            : _buildMobileLayout(state),
      ),
    );
  }

  Widget _buildTVLayout(HomeState state) {
    final settings = ref.watch(settingsStoreProvider);
    final showRecentWatch = settings.homeBlocks['showRecentWatch'] ?? true;
    final showRecommend = settings.homeBlocks['showAIRecommend'] ?? true;
    final showCategories = settings.homeBlocks['showCategories'] ?? true;
    final showLive = settings.homeBlocks['showLive'] ?? false;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('whiteTV', style: AppTypography.headline),
          ),
          if (showRecentWatch)
            RecentWatchSection(
              records: state.recentHistory,
              onTap: (record) => _navigateToDetail(record.videoId),
              showProgress: true,
            ),
          if (showLive) ...[
            const SizedBox(height: 24),
            _buildLiveEntrySection(isTV: true),
          ],
          _buildYoutubeSection(),
          if (state.hotMovies.isNotEmpty)
            _buildCategoryRow('熱門電影', state.hotMovies, isTV: true),
          if (showRecommend && state.aiRecommendations.isNotEmpty) ...[
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
          if (showCategories)
            ...state.categories.map((category) {
              final videos = state.videosByCategory[category.id] ?? [];
              return _buildCategoryRow(category.name, videos, isTV: true);
            }),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(HomeState state) {
    final settings = ref.watch(settingsStoreProvider);
    final showRecentWatch = settings.homeBlocks['showRecentWatch'] ?? true;
    final showRecommend = settings.homeBlocks['showAIRecommend'] ?? true;
    final showCategories = settings.homeBlocks['showCategories'] ?? true;
    final showLive = settings.homeBlocks['showLive'] ?? false;

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('whiteTV', style: AppTypography.headline),
        ),
        if (showRecentWatch)
          RecentWatchSection(
            records: state.recentHistory,
            onTap: (record) => _navigateToDetail(record.videoId),
          ),
        if (showLive) ...[
          const SizedBox(height: 24),
          _buildLiveEntrySection(isTV: false),
        ],
        if (showRecommend && state.aiRecommendations.isNotEmpty) ...[
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
        if (state.hotMovies.isNotEmpty)
          _buildCategoryRow('熱門電影', state.hotMovies, isTV: false),
        if (showCategories)
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

  Widget _buildLiveEntrySection({required bool isTV}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        key: const Key('live_entry_section'),
        onTap: () => context.push('/live'),
        child: Container(
          height: isTV ? 100 : 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.live.withValues(alpha: 0.8),
                AppColors.accent.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                '📺 直播',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '進入直播',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYoutubeSection() {
    final youtubeState = ref.watch(youtubeStoreProvider);

    if (youtubeState.recommendVideos.isEmpty) {
      return const SizedBox.shrink();
    }

    return YoutubeSection(videos: youtubeState.recommendVideos);
  }


  void _navigateToDetail(String videoId) {
    context.push('/detail/$videoId');
  }
}
