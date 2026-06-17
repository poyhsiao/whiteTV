import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:white_tv/core/device/device_type.dart';
import 'package:white_tv/core/theme/typography.dart';
import 'package:white_tv/features/history/widgets/recent_watch_section.dart';
import 'package:white_tv/features/home/home_store.dart';
import 'package:white_tv/shared/widgets/desktop_dock_navigation.dart';
import 'package:white_tv/shared/widgets/poster_card.dart';
import 'package:white_tv/shared/widgets/skeleton_loader.dart';

/// Desktop 首頁佈局
/// 支援 window management, responsive layout, full screen mode
///
/// 參照: docs/superpowers/specs/2026-05-25-ios-macos-design.md
class HomeScreenDesktop extends ConsumerStatefulWidget {
  const HomeScreenDesktop({super.key});

  @override
  ConsumerState<HomeScreenDesktop> createState() => _HomeScreenDesktopState();
}

class _HomeScreenDesktopState extends ConsumerState<HomeScreenDesktop> {
  bool _isFullScreen = false;
  int _selectedDockIndex = 0;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    Future.microtask(() => ref.read(homeStoreProvider.notifier).loadHome());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() => _isFullScreen = !_isFullScreen);
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.f11) {
      _toggleFullScreen();
    }
  }

  void _onDockItemSelected(int index) {
    setState(() => _selectedDockIndex = index);
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/favorites');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeStoreProvider);

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

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        body: Column(
          children: [
            if (!_isFullScreen) _buildAppBar(),
            Expanded(
              child: _buildContent(state),
            ),
            if (!_isFullScreen)
              DesktopDockNavigation(
                deviceType: DeviceType.desktop,
                items: const [
                  DockNavigationItem(icon: Icons.home, label: '首頁', route: '/'),
                  DockNavigationItem(icon: Icons.search, label: '搜尋', route: '/search'),
                  DockNavigationItem(icon: Icons.favorite, label: '我的收藏', route: '/favorites'),
                  DockNavigationItem(icon: Icons.settings, label: '設定', route: '/settings'),
                ],
                selectedIndex: _selectedDockIndex,
                onItemSelected: _onDockItemSelected,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Text('whiteTV', style: AppTypography.headline),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
            tooltip: '搜尋',
          ),
          IconButton(
            icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
            onPressed: _toggleFullScreen,
            tooltip: _isFullScreen ? '退出全螢幕' : '全螢幕',
          ),
        ],
      ),
    );
  }

  Widget _buildContent(HomeState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive layout based on available width
        final width = constraints.maxWidth;
        final crossAxisCount = _getGridCrossAxisCount(width);
        final isWideLayout = width >= 1400;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.recentHistory.isNotEmpty) ...[
                RecentWatchSection(
                  records: state.recentHistory,
                  onTap: (record) => _navigateToDetail(record.videoId),
                  showProgress: true,
                ),
                const SizedBox(height: 24),
              ],
              ...state.categories.map((category) {
                final videos = state.videosByCategory[category.id] ?? [];
                return _buildCategorySection(
                  category.name,
                  videos,
                  crossAxisCount: crossAxisCount,
                  isWideLayout: isWideLayout,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  int _getGridCrossAxisCount(double width) {
    if (width >= 1600) return 6;
    if (width >= 1200) return 5;
    if (width >= 900) return 4;
    return 3;
  }

  Widget _buildCategorySection(
    String title,
    List videos, {
    required int crossAxisCount,
    required bool isWideLayout,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(title, style: AppTypography.title),
        ),
        if (isWideLayout)
          _buildWideLayoutGrid(videos, crossAxisCount)
        else
          _buildStandardLayoutRow(videos),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildWideLayoutGrid(List videos, int crossAxisCount) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: videos.length.clamp(0, crossAxisCount * 2),
      itemBuilder: (context, index) {
        final video = videos[index];
        return PosterCard(
          title: video.title,
          posterUrl: video.posterUrl,
          onTap: () => _navigateToDetail(video.id),
        );
      },
    );
  }

  Widget _buildStandardLayoutRow(List videos) {
    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: videos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final video = videos[index];
          return PosterCard(
            title: video.title,
            posterUrl: video.posterUrl,
            onTap: () => _navigateToDetail(video.id),
          );
        },
      ),
    );
  }

  void _navigateToDetail(String videoId) {
    context.push('/detail/$videoId');
  }
}

/// Window constraints helper for desktop window management
class WindowConstraints {
  WindowConstraints._();

  static const double minWidth = 800;
  static const double minHeight = 600;
  static const double maxWidth = 3840;
  static const double maxHeight = 2160;

  static Size constrain(Size size) {
    return Size(
      size.width.clamp(minWidth, maxWidth),
      size.height.clamp(minHeight, maxHeight),
    );
  }
}