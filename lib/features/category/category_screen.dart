import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/device/device_utils.dart';
import 'package:white_tv/core/device/device_type.dart';
import 'package:white_tv/features/category/category_constants.dart';
import 'package:white_tv/features/category/category_content_state.dart';
import 'package:white_tv/features/category/category_content_store.dart';
import 'package:white_tv/shared/widgets/poster_card.dart';

/// 分類內容瀏覽頁
/// 參照：docs/spec/UI_UX.md Section 7
class CategoryScreen extends ConsumerStatefulWidget {
  final String categoryId;

  const CategoryScreen({super.key, required this.categoryId});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(categoryContentStoreProvider.notifier).loadContent();
    });
  }

  String _categoryName(String id) {
    return switch (id) {
      'movie' => '電影',
      'drama' => '電視劇',
      'anime' => '動漫',
      'variety' => '綜藝',
      'youtube' => 'YouTube',
      _ => id,
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryContentStoreProvider);
    final deviceType = DeviceUtils.getDeviceType(context);

    return Scaffold(
      appBar: AppBar(title: Text(_categoryName(state.categoryId))),
      body: _buildBody(state, deviceType),
    );
  }

  Widget _buildBody(CategoryContentState state, DeviceType deviceType) {
    if (state.isLoading && state.videos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('載入失敗：${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(categoryContentStoreProvider.notifier).refresh(),
              child: const Text('重新整理'),
            ),
          ],
        ),
      );
    }

    if (state.videos.isEmpty) {
      return const Center(child: Text('暫無內容'));
    }

    if (deviceType == DeviceType.tv) {
      return _buildTVLayout(state);
    }
    return _buildMobileLayout(state);
  }

  Widget _buildTVLayout(CategoryContentState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 二級分類 （TV 模式：水平捲動 chips）
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: CategoryConstants.subCategories.map((key) {
                final isSelected = state.subCategory == key ||
                    (key == 'all' && state.subCategory == null);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(CategoryConstants.subCategoryLabel(key)),
                    selected: isSelected,
                    onSelected: key == 'all'
                        ? (_) => ref
                            .read(categoryContentStoreProvider.notifier)
                            .setSubCategory(null)
                        : (_) => ref
                            .read(categoryContentStoreProvider.notifier)
                            .setSubCategory(key),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // 地區、年份、排序行
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip('全部地區', Icons.public),
              const SizedBox(width: 12),
              _buildFilterChip('全部年份', Icons.date_range),
              const SizedBox(width: 12),
              _buildSortDropdown(state),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 內容網格
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: state.videos.length,
            itemBuilder: (context, index) {
              final video = state.videos[index];
              return PosterCard(
                title: video.title,
                posterUrl: video.posterUrl,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(CategoryContentState state) {
    return CustomScrollView(
      slivers: [
        // 可折疊篩選區
        _mobileFilterSection(
          title: '二級分類',
          items: CategoryConstants.subCategories,
          isSelected: (key) => state.subCategory == key || (key == 'all' && state.subCategory == null),
          label: CategoryConstants.subCategoryLabel,
          onSelect: (key) => ref.read(categoryContentStoreProvider.notifier).setSubCategory(key == 'all' ? null : key),
        ),
        _mobileFilterSection(
          title: '地區',
          items: CategoryConstants.regions,
          isSelected: (key) => state.region == key || (key == 'all' && state.region == null),
          label: CategoryConstants.regionLabel,
          onSelect: (key) => ref.read(categoryContentStoreProvider.notifier).setRegion(key == 'all' ? null : key),
        ),
        _mobileFilterSection(
          title: '年份',
          items: CategoryConstants.years,
          isSelected: (key) => state.year == key || (key == 'all' && state.year == null),
          label: CategoryConstants.yearLabel,
          onSelect: (key) => ref.read(categoryContentStoreProvider.notifier).setYear(key == 'all' ? null : key),
        ),
        SliverToBoxAdapter(
          child: ExpansionTile(
            title: Text('排序：${state.sortOption.label}'),
            children: CategoryConstants.sortOptions.map((option) {
              final isSelected = state.sortOption == option;
              return ListTile(
                title: Text(option.label),
                trailing:
                    isSelected ? const Icon(Icons.check) : null,
                onTap: () => ref
                    .read(categoryContentStoreProvider.notifier)
                    .setSortOption(option),
              );
            }).toList(),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        // 內容網格
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final video = state.videos[index];
                return PosterCard(
                title: video.title,
                posterUrl: video.posterUrl,
              );
              },
              childCount: state.videos.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () {},
    );
  }

  Widget _mobileFilterSection({
    required String title,
    required List<String> items,
    required bool Function(String key) isSelected,
    required String Function(String key) label,
    required void Function(String key) onSelect,
  }) {
    return SliverToBoxAdapter(
      child: ExpansionTile(
        title: Text(title),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: items.map((key) {
                return ChoiceChip(
                  label: Text(label(key)),
                  selected: isSelected(key),
                  onSelected: (_) => onSelect(key),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortDropdown(CategoryContentState state) {
    return DropdownButton<SortOption>(
      value: state.sortOption,
      underline: const SizedBox(),
      items: CategoryConstants.sortOptions
          .map((o) => DropdownMenuItem(value: o, child: Text(o.label)))
          .toList(),
      onChanged: (option) {
        if (option != null) {
          ref
              .read(categoryContentStoreProvider.notifier)
              .setSortOption(option);
        }
      },
    );
  }
}
