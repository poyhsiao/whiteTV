import 'package:flutter/material.dart';
import 'package:white_tv/core/theme/colors.dart';

/// Volume control widget with mute toggle and volume slider
class VolumeControl extends StatelessWidget {
  final double volume;
  final bool isMuted;
  final ValueChanged<double>? onVolumeChanged;
  final VoidCallback? onMuteToggled;

  const VolumeControl({
    super.key,
    required this.volume,
    required this.isMuted,
    this.onVolumeChanged,
    this.onMuteToggled,
  });

  @override
  Widget build(BuildContext context) {
    // Determine volume icon based on state
    IconData volumeIcon;
    if (isMuted) {
      volumeIcon = Icons.volume_off;
    } else if (volume >= 0.5) {
      volumeIcon = Icons.volume_up;
    } else {
      volumeIcon = Icons.volume_down;
    }

    // Display volume: 0.0 when muted, actual volume otherwise
    final displayVolume = isMuted ? 0.0 : volume;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mute toggle button
          IconButton(
            icon: Icon(volumeIcon, color: AppColors.textPrimary),
            onPressed: onMuteToggled,
          ),
          // Volume slider
          SizedBox(
            width: 100,
            child: Slider(
              value: displayVolume,
              onChanged: isMuted ? null : onVolumeChanged,
              activeColor: AppColors.accent,
              inactiveColor: AppColors.glassBorder,
            ),
          ),
          // Volume percentage display
          SizedBox(
            width: 40,
            child: Text(
              '${(displayVolume * 100).round()}%',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
