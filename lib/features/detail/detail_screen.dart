import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/core/device/device_utils.dart';
import 'package:white_tv/core/theme/colors.dart';
import 'package:white_tv/core/theme/glass_card.dart';
import 'package:white_tv/core/theme/typography.dart';
import 'package:white_tv/features/detail/detail_store.dart';

/// 詳情頁
/// 參照: docs/spec/UI_UX.md Section 10

class DetailScreen extends ConsumerStatefulWidget {
  final String videoId;

  const DetailScreen({super.key, required this.videoId});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(detailStoreProvider.notifier).loadDetail(widget.videoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(detailStoreProvider);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Scaffold(
        body: Center(
          child: Text('Error: ${state.error}', style: AppTypography.body),
        ),
      );
    }

    final detail = state.detail;
    if (detail == null) {
      return const Scaffold(
        body: Center(child: Text('No data')),
      );
    }

    return Scaffold(
      body: DeviceUtils.isTV(context)
          ? _buildTVLayout(context, detail, state)
          : _buildMobileLayout(context, detail, state),
    );
  }

  Widget _buildTVLayout(
      BuildContext context, VideoDetail detail, DetailState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Poster
          SizedBox(
            width: 300,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: detail.posterUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: AppColors.cardBackground),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.cardBackground,
                  child: const Icon(Icons.movie, size: 64),
                ),
              ),
            ),
          ),
          const SizedBox(width: 32),
          // Right: Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detail.title, style: AppTypography.headline),
                const SizedBox(height: 8),
                Text(detail.description ?? '', style: AppTypography.body),
                const SizedBox(height: 16),
                _buildSourceSelector(state),
                const SizedBox(height: 16),
                _buildEpisodeList(detail, state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, VideoDetail detail, DetailState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: detail.posterUrl ?? '',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detail.title, style: AppTypography.title),
                const SizedBox(height: 8),
                Text(detail.description ?? '', style: AppTypography.caption),
                const SizedBox(height: 16),
                _buildSourceSelector(state),
                const SizedBox(height: 16),
                _buildEpisodeList(detail, state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceSelector(DetailState state) {
    if (state.detail == null) return const SizedBox();
    final sources = state.detail!.sources as List<VideoSource>;

    return Wrap(
      spacing: 8,
      children: sources.map<Widget>((source) {
        final isSelected = state.selectedSource == source;
        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: GestureDetector(
            onTap: () {
              ref.read(detailStoreProvider.notifier).selectSource(source);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${source.name} (${source.latency}ms)',
                style: AppTypography.caption.copyWith(
                  color:
                      isSelected ? Colors.black : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEpisodeList(VideoDetail detail, DetailState state) {
    final episodes = detail.episodes as List<Episode>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Episodes', style: AppTypography.subtitle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: episodes.map<Widget>((episode) {
            final isSelected = state.selectedEpisode == episode;
            return GlassCard(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () {
                  ref.read(detailStoreProvider.notifier).selectEpisode(episode);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'EP ${episode.number}',
                    style: AppTypography.caption.copyWith(
                      color:
                          isSelected ? Colors.black : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}