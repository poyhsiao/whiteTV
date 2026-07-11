import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/search/search_history_overlay.dart';
import 'package:white_tv/features/search/search_state.dart';
import 'package:white_tv/features/search/search_store.dart';
import 'package:white_tv/features/search/widgets/voice_input_button.dart';
import 'package:white_tv/shared/widgets/empty_state.dart';
import 'package:white_tv/features/search/widgets/search_results.dart';

/// SearchScreen - 搜尋頁面
/// TV 遙控器麥克風鍵整合在 VoiceInputButton 內（UI_UX.md §16）
class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchStoreProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('搜尋')),
      body: Stack(
        children: [
          Column(
            children: [
              // Search input area
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  key: const Key('search_input'),
                  decoration: InputDecoration(
                    hintText: '輸入搜尋關鍵字...',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: VoiceInputButton(
                      onResult: (text) {
                        ref.read(searchStoreProvider.notifier).search(text);
                      },
                    ),
                  ),
                  onTap: () {
                    ref.read(searchStoreProvider.notifier).openHistoryOverlay();
                  },
                  onChanged: (query) {
                    ref.read(searchStoreProvider.notifier).search(query);
                  },
                ),
              ),

              // Category filter
              // 40dp 符合 TV UI touch-target 最小高度（UI_UX.md §8）
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: SearchCategory.values.map((category) {
                    final isSelected = searchState.activeCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_getCategoryLabel(category)),
                        selected: isSelected,
                        onSelected: (_) {
                          ref.read(searchStoreProvider.notifier)
                              .setCategory(category);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Search results
              Expanded(
                child: searchState.results.isEmpty && !searchState.isLoading
                    ? const EmptyStateWidget(
                        icon: Icons.search_off,
                        title: '找不到符合的內容',
                      )
                    : SearchResults(
                        results: searchState.results,
                        isLoading: searchState.isLoading,
                      ),
              ),
            ],
          ),

          // History overlay
          if (searchState.isHistoryOverlayOpen)
            const Positioned.fill(child: SearchHistoryOverlay()),
        ],
      ),
    );
  }

  String _getCategoryLabel(SearchCategory category) {
    if (category == SearchCategory.all) return '全部';
    if (category == SearchCategory.movie) return '電影';
    if (category == SearchCategory.series) return '劇集';
    if (category == SearchCategory.anime) return '動漫';
    if (category == SearchCategory.variety) return '綜藝';
    return category.apiValue; // 防御未知類別
  }
}
