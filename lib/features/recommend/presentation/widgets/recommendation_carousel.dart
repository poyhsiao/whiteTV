import 'package:flutter/material.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/recommend/presentation/widgets/recommendation_card.dart';

class RecommendationCarousel extends StatelessWidget {
  final String title;
  final List<AIRecommendation> recommendations;
  final VoidCallback? onRefresh;
  final void Function(AIRecommendation)? onRecommendationTap;

  const RecommendationCarousel({
    super.key,
    required this.title,
    required this.recommendations,
    this.onRefresh,
    this.onRecommendationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (onRefresh != null)
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                  onPressed: onRefresh,
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Carousel
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => onRecommendationTap?.call(recommendation),
                  child: RecommendationCard(
                    recommendation: recommendation,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
