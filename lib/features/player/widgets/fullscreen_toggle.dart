import 'package:flutter/material.dart';
import 'package:white_tv/core/theme/colors.dart';

/// Fullscreen toggle button widget
class FullscreenToggle extends StatelessWidget {
  final bool isFullscreen;
  final VoidCallback onToggle;

  const FullscreenToggle({
    super.key,
    required this.isFullscreen,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
        color: AppColors.textPrimary,
      ),
      onPressed: onToggle,
      tooltip: isFullscreen ? '退出全螢幕' : '全螢幕',
    );
  }
}
