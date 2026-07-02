import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:white_tv/core/theme/colors.dart';
import 'package:white_tv/shared/widgets/empty_state.dart';

/// YouTube 播放器頁面
/// 負責播放 YouTube 影片，支援 fullscreen 和基本播放控制
class YoutubePlayerScreen extends ConsumerStatefulWidget {
  final String videoId;
  final String? videoTitle;
  final String? youtubeUrl;

  const YoutubePlayerScreen({
    super.key,
    required this.videoId,
    this.videoTitle,
    this.youtubeUrl,
  });

  @override
  ConsumerState<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends ConsumerState<YoutubePlayerScreen> {
  YoutubePlayerController? _controller;
  bool _isFullscreen = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initYoutubePlayer();
  }

  Future<void> _initYoutubePlayer() async {
    final videoId = _extractYoutubeVideoId(widget.youtubeUrl ?? widget.videoId);

    if (videoId == null || videoId.isEmpty) {
      setState(() {
        _errorMessage = '無效的 YouTube 影片 ID';
      });
      return;
    }

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        strictRelatedVideos: false,
      ),
    );

    _controller!.listen((state) {
      // Player state listener - controls managed by YouTube iframe
    });

    if (mounted) {
      setState(() {});
    }
  }

  String? _extractYoutubeVideoId(String input) {
    if (input.length == 11 && !input.contains('/')) {
      return input;
    }
    try {
      final uri = Uri.parse(input);
      if (uri.queryParameters.containsKey('v')) {
        return uri.queryParameters['v'];
      }
      if (uri.host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }
      if (uri.host.contains('youtube.com')) {
        final segments = uri.pathSegments;
        if (segments.contains('embed') && segments.length > 1) {
          return segments[segments.indexOf('embed') + 1];
        }
        if (segments.contains('v') && segments.length > 1) {
          return segments[segments.indexOf('v') + 1];
        }
      }
    } catch (_) {}
    return input;
  }

  @override
  void dispose() {
    _controller?.close();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.videoTitle ?? 'YouTube'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: EmptyStateWidget(
            icon: Icons.error_outline,
            title: '播放失敗',
            subtitle: _errorMessage,
            actionLabel: '返回',
            onAction: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }

    if (_controller == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.videoTitle ?? 'YouTube'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.accent,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: YoutubePlayer(
                controller: _controller!,
                aspectRatio: 16 / 9,
              ),
            ),
            if (!_isFullscreen)
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            Positioned(
              bottom: 16,
              right: 16,
              child: IconButton(
                icon: Icon(
                  _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: _toggleFullscreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
