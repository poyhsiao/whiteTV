import 'package:flutter/material.dart';
import 'package:white_tv/features/live/data/models/m3u_channel.dart';

class ChannelTile extends StatelessWidget {
  final M3uChannel channel;
  final VoidCallback onTap;
  final bool isFocused;

  const ChannelTile({
    super.key,
    required this.channel,
    required this.onTap,
    this.isFocused = false,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isFocused ? Colors.blue.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isFocused
                ? Border.all(color: Colors.blue, width: 2)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (channel.logoUrl != null)
                Image.network(
                  channel.logoUrl!,
                  width: 48,
                  height: 48,
                  errorBuilder: (_, __, ___) => const Icon(Icons.tv, size: 48),
                )
              else
                const Icon(Icons.tv, size: 48),
              const SizedBox(height: 4),
              Text(
                channel.name,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (channel.groupTitle != null) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    channel.groupTitle!,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}