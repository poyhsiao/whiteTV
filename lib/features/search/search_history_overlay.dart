import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/search/search_store.dart';
import 'package:white_tv/features/search/widgets/history_card.dart';

/// SearchHistoryOverlay - 毛玻璃搜尋歷史覆蓋層
class SearchHistoryOverlay extends ConsumerWidget {
  const SearchHistoryOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.read(searchStoreProvider.notifier);
    final state = ref.watch(searchStoreProvider);

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: store.closeHistoryOverlay,
        child: Container(
          color: const Color(0xD9000000),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Column(
              children: [
                // Header with title and actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '搜尋記錄',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          // Voice input button
                          IconButton(
                            key: const Key('voice_input'),
                            icon: const Icon(Icons.mic, color: Colors.white70),
                            onPressed: () {
                              // Voice input functionality handled by SearchScreen
                            },
                          ),
                          // Clear all button
                          if (state.searchHistory.isNotEmpty)
                            TextButton(
                              key: const Key('clear_all'),
                              onPressed: () => _showClearConfirmDialog(context, store),
                              child: const Text(
                                '清除全部',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // History list or empty state
                Expanded(
                  child: state.searchHistory.isEmpty
                      ? const Center(
                          child: Text(
                            '尚無搜尋記錄',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.searchHistory.length,
                          itemBuilder: (context, index) {
                            final query = state.searchHistory[index];
                            return HistoryCard(
                              key: ValueKey(query),
                              query: query,
                              onTap: () => store.searchFromHistory(query),
                              onDelete: () => store.deleteHistoryItem(query),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showClearConfirmDialog(BuildContext context, SearchStore store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('confirm_dialog'),
        title: const Text('清除所有搜尋記錄？'),
        content: const Text('此操作無法撤銷'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            key: const Key('confirm_clear'),
            onPressed: () {
              store.clearAllHistory();
              Navigator.pop(context);
            },
            child: const Text('確認'),
          ),
        ],
      ),
    );
  }
}
