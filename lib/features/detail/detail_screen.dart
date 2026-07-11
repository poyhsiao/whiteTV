// ignore_for_file: use_build_context_synchronously
// (showDialog returns before widget tree is disposed; mounted guards are in place)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/core/device/device_utils.dart';
import 'package:white_tv/core/services/parental_control_service.dart';
import 'package:white_tv/core/theme/colors.dart';
import 'package:white_tv/core/theme/glass_card.dart';
import 'package:white_tv/core/theme/typography.dart';
import 'package:white_tv/features/detail/detail_store.dart';
import 'package:white_tv/features/downloads/downloads_store.dart';
import 'package:white_tv/features/history/models/media_type.dart';
import 'package:white_tv/shared/widgets/pin_dialog.dart';
import 'package:white_tv/shared/widgets/poster_card.dart';

bool isAdultContent(VideoDetail? detail) {
  if (detail?.category == null) return false;
  const adultKeywords = ['成人', '18+', '限制級', 'R18', 'adult'];
  return adultKeywords.any((kw) => detail!.category!.contains(kw));
}

/// 詳情頁
/// 參照: docs/spec/UI_UX.md Section 10

class DetailScreen extends ConsumerStatefulWidget {
  final String videoId;

  const DetailScreen({super.key, required this.videoId});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  // TV D-pad navigation for episodes
  final FocusNode _episodeFocusNode = FocusNode();
  int _selectedEpisodeIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(detailStoreProvider.notifier).loadDetail(widget.videoId);
    });
  }

  @override
  void dispose() {
    _episodeFocusNode.dispose();
    super.dispose();
  }

  void _handleEpisodeKeyEvent(VideoDetail detail, KeyEvent event, List<Episode> episodes) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowRight) {
      if (_selectedEpisodeIndex < episodes.length - 1) {
        setState(() => _selectedEpisodeIndex++);
        _selectCurrentEpisode(detail, episodes);
      }
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      if (_selectedEpisodeIndex > 0) {
        setState(() => _selectedEpisodeIndex--);
        _selectCurrentEpisode(detail, episodes);
      }
    } else if (key == LogicalKeyboardKey.select) {
      if (episodes.isNotEmpty) {
        _onEpisodeTap(detail, episodes[_selectedEpisodeIndex]);
      }
    }
  }

  void _selectCurrentEpisode(VideoDetail detail, List<Episode> episodes) {
    if (episodes.isNotEmpty && _selectedEpisodeIndex < episodes.length) {
      ref.read(detailStoreProvider.notifier).selectEpisode(episodes[_selectedEpisodeIndex]);
    }
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

  Future<void> _onEpisodeTap(VideoDetail detail, Episode episode) async {
    ref.read(detailStoreProvider.notifier).selectEpisode(episode);

    if (!mounted) return;

    if (isAdultContent(detail)) {
      final service = ref.read(parentalControlServiceProvider);
      final state = await service.getState();
      if (state.enabled && !state.isLocked) {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final pin = await showDialog<String>(
          context: context,
          builder: (_) => const PinDialog(title: '請輸入家長鎖PIN碼'),
        );
        if (pin == null || !mounted) return;
        final valid = await service.verifyPin(pin);
        if (!valid) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('PIN碼錯誤')),
          );
          return;
        }
      }
    }

    if (mounted) {
      context.go('/player/${widget.videoId}/${episode.id}');
    }
  }

  void _download(BuildContext context, WidgetRef ref, VideoDetail detail, VideoSource source) {
    ref.read(downloadsStoreProvider.notifier).startDownload(
      videoId: detail.id,
      url: source.url,
      title: detail.title,
      posterUrl: detail.posterUrl,
      sourceName: source.name,
      mediaType: detail.category?.contains('tv') ?? false
          ? MediaType.series
          : MediaType.movie,
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
                _buildTVEpisodeSelector(detail, state),
                const SizedBox(height: 16),
                ElevatedButton(
                  key: const Key('play_button'),
                  onPressed: state.selectedEpisode != null
                      ? () => _onEpisodeTap(detail, state.selectedEpisode!)
                      : null,
                  child: const Text('播放'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  key: const Key('download_button_tv'),
                  onPressed: state.selectedSource == null
                      ? null
                      : () => _download(context, ref, detail, state.selectedSource!),
                  icon: const Icon(Icons.download),
                  label: const Text('下載'),
                ),
                if (state.relatedVideos.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildRelatedSection(state),
                ],
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        key: const Key('play_button'),
                        onPressed: state.selectedEpisode != null
                            ? () => _onEpisodeTap(detail, state.selectedEpisode!)
                            : null,
                        child: const Text('播放'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('download_button_mobile'),
                        onPressed: state.selectedSource == null
                            ? null
                            : () => _download(context, ref, detail, state.selectedSource!),
                        icon: const Icon(Icons.download),
                        label: const Text('下載'),
                      ),
                    ),
                  ],
                ),
                if (state.relatedVideos.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildRelatedSection(state),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedSection(DetailState state) {
    // UI_UX §10.1: 詳情頁底部「相關推薦」橫向滾動
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('相關推薦', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: state.relatedVideos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final video = state.relatedVideos[index];
              return PosterCard(
                title: video.title,
                posterUrl: video.posterUrl,
                onTap: () => context.push('/detail/${video.id}'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSourceSelector(DetailState state) {
    if (state.detail == null) return const SizedBox();
    final isTV = DeviceUtils.isTV(context);
    return isTV
        ? _buildTVSourceSelector(state)
        : _buildMobileSourceSelector(state);
  }

  Widget _buildTVSourceSelector(DetailState state) {
    final sources = state.detail!.sources;
    return SizedBox(
      key: const Key('tv_source_list'),
      height: 200,
      child: ListView.separated(
        itemCount: sources.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final source = sources[index];
          final isSelected = state.selectedSource == source;
          final statusEmoji = switch (source.status) {
            SourceStatus.available => '🟢',
            SourceStatus.testing => '🟡',
            SourceStatus.unavailable => '🔴',
          };
          final episodeCount = state.detail!.episodes.length;
          return GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: GestureDetector(
              onTap: source.isAvailable
                  ? () => ref.read(detailStoreProvider.notifier).selectSource(source)
                  : null,
              child: Row(
                children: [
                  Text(statusEmoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(source.name, style: AppTypography.body),
                  const SizedBox(width: 8),
                  Text('${source.latency}ms', style: AppTypography.caption),
                  const SizedBox(width: 8),
                  Text('$episodeCount集', style: AppTypography.caption),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Text('[自動]', style: AppTypography.caption.copyWith(
                        color: AppColors.accent)),
                    const Spacer(),
                    const Text('← 當前',
                        style: TextStyle(color: AppColors.accent, fontSize: 12)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileSourceSelector(DetailState state) {
    final sources = state.detail!.sources;
    return Wrap(
      key: const Key('mobile_source_selector'),
      spacing: 8,
      children: sources.map<Widget>((source) {
        final isSelected = state.selectedSource == source;
        final statusEmoji = switch (source.status) {
          SourceStatus.available => '🟢',
          SourceStatus.testing => '🟡',
          SourceStatus.unavailable => '🔴',
        };
        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: GestureDetector(
            onTap: source.isAvailable
                ? () => ref.read(detailStoreProvider.notifier).selectSource(source)
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$statusEmoji ${source.name} (${source.latency}ms)',
                style: AppTypography.caption.copyWith(
                  color: isSelected ? Colors.black : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEpisodeList(VideoDetail detail, DetailState state) {
    final episodes = detail.episodes;

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
                onTap: () => _onEpisodeTap(detail, episode),
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

  // TV D-pad episode selector with left/right navigation
  Widget _buildTVEpisodeSelector(VideoDetail detail, DetailState state) {
    final episodes = detail.episodes;
    if (episodes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Episodes', style: AppTypography.subtitle),
        const SizedBox(height: 8),
        Focus(
          focusNode: _episodeFocusNode,
          onKeyEvent: (node, event) {
            _handleEpisodeKeyEvent(detail, event, episodes);
            return KeyEventResult.handled;
          },
          child: SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: episodes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final episode = episodes[index];
                final isSelected = state.selectedEpisode == episode ||
                    (_selectedEpisodeIndex == index && state.selectedEpisode == null);

                // Auto-focus on current episode mount
                if (index == _selectedEpisodeIndex && !_episodeFocusNode.hasFocus) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _episodeFocusNode.requestFocus();
                  });
                }

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedEpisodeIndex = index);
                    _onEpisodeTap(detail, episode);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: AppColors.accent, width: 2)
                          : null,
                    ),
                    child: Text(
                      'EP ${episode.number}',
                      style: AppTypography.body.copyWith(
                        color: isSelected ? Colors.black : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Episode count info
        Text(
          '${_selectedEpisodeIndex + 1} / ${episodes.length}',
          style: AppTypography.caption,
        ),
      ],
    );
  }
}
