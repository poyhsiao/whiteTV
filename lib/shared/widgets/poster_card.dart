import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:white_tv/core/theme/glass_card.dart';
import 'package:white_tv/core/theme/typography.dart';

/// 影視海報卡片
/// 參照: docs/spec/UI_UX.md Section 3.3

class PosterCard extends StatelessWidget {
  final String title;
  final String? posterUrl;
  final VoidCallback? onTap;
  final bool showFocus;
  final double width;
  final double height;

  const PosterCard({
    super.key,
    required this.title,
    this.posterUrl,
    this.onTap,
    this.showFocus = false,
    this.width = 140,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final card = GlassCard(
      borderRadius: 12,
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (posterUrl != null)
              CachedNetworkImage(
                imageUrl: posterUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.movie, color: Colors.grey),
                ),
              )
            else
              Container(
                color: Colors.grey[800],
                child: const Icon(Icons.movie, color: Colors.grey, size: 40),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Text(
                  title,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (showFocus)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}