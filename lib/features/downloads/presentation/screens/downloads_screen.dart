import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/device/device_type.dart';
import 'package:white_tv/core/device/device_utils.dart';
import 'package:white_tv/features/downloads/downloads_state.dart';
import 'package:white_tv/features/downloads/downloads_store.dart';
import 'package:white_tv/features/downloads/presentation/widgets/downloads_grid.dart';
import 'package:white_tv/shared/widgets/empty_state.dart';

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({super.key});

  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(downloadsStoreProvider.notifier).loadDownloads(),
    );
  }

  void _showDeleteConfirmation(String videoId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除下載'),
        content: const Text('確定要刪除這個下載嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(downloadsStoreProvider.notifier).deleteDownload(videoId);
            },
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(downloadsStoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的下載'),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(DownloadsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(downloadsStoreProvider.notifier).loadDownloads(),
              child: const Text('重試'),
            ),
          ],
        ),
      );
    }

    if (state.downloads.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.download_outlined,
        title: '沒有已下載的影片',
      );
    }

    final isTv = DeviceUtils.getDeviceType(context) == DeviceType.tv;

    return DownloadsGrid(
      downloads: state.downloads,
      onDelete: (videoId, title) => _showDeleteConfirmation(videoId, title),
      isTvLayout: isTv,
    );
  }
}
