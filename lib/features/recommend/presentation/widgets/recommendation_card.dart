import 'package:flutter/material.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';

class RecommendationCard extends StatelessWidget {
  final AIRecommendation recommendation;
  final VoidCallback? onTap;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster
              recommendation.posterUrl != null
                  ? Image.network(
                      recommendation.posterUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),

              // Gradient overlay
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
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        recommendation.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Year
                      if (recommendation.year != null)
                        Text(
                          recommendation.year!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Source tag
              Positioned(
                top: 8,
                left: 8,
                child: _buildSourceTag(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceTag() {
    final (emoji, text) = switch (recommendation.sourceType) {
      RecommendationSource.ai => ('🤖', 'AI'),
      RecommendationSource.history => ('📺', '偏好'),
      RecommendationSource.popular => ('🔥', '熱門'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getTagColor().withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$emoji $text',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getTagColor() {
    return switch (recommendation.sourceType) {
      RecommendationSource.ai => const Color(0xFFB8860B), // 琥珀色
      RecommendationSource.history => const Color(0xFF4169E1), // 藍色
      RecommendationSource.popular => const Color(0xFFDC143C), // 紅色
    };
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(
          Icons.movie,
          color: Colors.white54,
          size: 40,
        ),
      ),
    );
  }
}
