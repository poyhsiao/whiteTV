import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/live/domain/models/live_state.dart';
import 'package:white_tv/features/live/presentation/providers/live_store.dart';
import 'package:white_tv/features/live/presentation/widgets/channel_tile.dart';

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load channels when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChannels();
    });
  }

  void _loadChannels() {
    // Demo M3U content - in production this would come from API or local storage
    const demoM3uContent = '''#EXTM3U
#EXTINF:-1 tvg-name="Channel 1" group-title="Sports",Channel 1
https://example.com/ch1.m3u8
#EXTINF:-1 tvg-name="Channel 2" group-title="News",Channel 2
https://example.com/ch2.m3u8
#EXTINF:-1 tvg-name="Channel 3" group-title="Entertainment",Channel 3
https://example.com/ch3.m3u8
''';
    ref.read(liveStoreProvider.notifier).loadChannels(demoM3uContent);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveStoreProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text('Live TV', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(LiveState state) {
    switch (state.status) {
      case LiveStatus.initial:
      case LiveStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        );
      case LiveStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'An error occurred',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadChannels,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      case LiveStatus.loaded:
      case LiveStatus.timeshift:
        return _buildChannelList(state);
    }
  }

  Widget _buildChannelList(LiveState state) {
    final channels = _searchQuery.isEmpty
        ? state.channels
        : ref.read(liveStoreProvider.notifier).searchChannels(_searchQuery);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${channels.length} channels',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];
              return ChannelTile(
                channel: channel,
                onTap: () {
                  ref.read(liveStoreProvider.notifier).selectChannel(channel);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Search Channels', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter channel name...',
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}