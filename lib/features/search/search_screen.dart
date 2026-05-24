import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/search/search_state.dart';
import 'package:white_tv/features/search/search_store.dart';
import 'package:white_tv/features/search/widgets/voice_input_button.dart';

/// SearchScreen - 搜尋頁面
class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchStoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('搜尋'),
      ),
      body: Column(
        children: [
          // Search input area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
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
              onChanged: (query) {
                ref.read(searchStoreProvider.notifier).search(query);
              },
            ),
          ),

          // Category filter
          SizedBox(
            height: 48,
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
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(searchStoreProvider.notifier).setCategory(category);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Search results placeholder
          Expanded(
            child: searchState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : searchState.query.isEmpty
                    ? const Center(child: Text('輸入關鍵字搜尋'))
                    : searchState.results.isEmpty
                        ? const Center(child: Text('無搜尋結果'))
                        : const Center(child: Text('搜尋結果')),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(SearchCategory category) {
    switch (category) {
      case SearchCategory.all:
        return '全部';
      case SearchCategory.movie:
        return '電影';
      case SearchCategory.series:
        return '劇集';
      case SearchCategory.anime:
        return '動漫';
      case SearchCategory.variety:
        return '綜藝';
    }
  }
}
