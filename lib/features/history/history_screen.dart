import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/history/history_state.dart';
import 'package:white_tv/features/history/history_store.dart';
import 'package:white_tv/features/history/widgets/history_list.dart';

/// Main screen for displaying play history.
///
/// Displays a list of watched videos grouped by time periods
/// (today, yesterday, earlier) with delete functionality.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load history when screen initializes
    Future.microtask(
      () => ref.read(historyStoreProvider.notifier).loadHistory(),
    );
  }

  void _showDeleteConfirmation(String key, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除觀看記錄'),
        content: const Text('確定要刪除這筆記錄嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(historyStoreProvider.notifier).deleteRecord(key);
            },
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }

  void _onRecordTap(dynamic record) {
    context.go('/detail/${record.videoId}');
  }

  void _onRecordDelete(dynamic record) {
    _showDeleteConfirmation(record.key, record.title);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyStoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('觀看記錄'),
        actions: [
          if (state.isSyncing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(HistoryState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return HistoryList(
      records: state.records,
      onTap: _onRecordTap,
      onDelete: _onRecordDelete,
    );
  }
}
