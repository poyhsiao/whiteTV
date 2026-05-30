// lib/features/recommend/presentation/pages/ai_recommend_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/recommend/presentation/providers/ai_recommend_store.dart';
import 'package:white_tv/features/recommend/presentation/widgets/recommendation_carousel.dart';

class AIRecommendPage extends ConsumerWidget {
  const AIRecommendPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiRecommendStoreProvider);
    final store = ref.read(aiRecommendStoreProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text('AI 推薦'),
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text('Error: ${state.error}'))
              : _buildContent(state, store),
    );
  }

  Widget _buildContent(AIRecommendState state, AIRecommendStore store) {
    if (state.recommendations.isEmpty) {
      return const Center(
        child: Text(
          '暫無推薦內容',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    // Group recommendations by source type
    final aiRecommendations = state.recommendations
        .where((r) => r.sourceType == RecommendationSource.ai)
        .toList();
    final historyRecommendations = state.recommendations
        .where((r) => r.sourceType == RecommendationSource.history)
        .toList();
    final popularRecommendations = state.recommendations
        .where((r) => r.sourceType == RecommendationSource.popular)
        .toList();

    return RefreshIndicator(
      onRefresh: () => store.refreshRecommendations(),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Introduction
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '根據您的觀看記錄，我們為您精選了以下內容：',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // AI Recommendations
          if (aiRecommendations.isNotEmpty) ...[
            RecommendationCarousel(
              title: '🤖 AI 智能推薦',
              recommendations: aiRecommendations,
              onRefresh: () => store.refreshRecommendations(),
            ),
            const SizedBox(height: 24),
          ],

          // History Recommendations
          if (historyRecommendations.isNotEmpty) ...[
            RecommendationCarousel(
              title: '📺 根據您的偏好',
              recommendations: historyRecommendations,
              onRefresh: () => store.refreshRecommendations(),
            ),
            const SizedBox(height: 24),
          ],

          // Popular Recommendations
          if (popularRecommendations.isNotEmpty) ...[
            RecommendationCarousel(
              title: '🔥 熱門推薦',
              recommendations: popularRecommendations,
              onRefresh: () => store.refreshRecommendations(),
            ),
          ],
        ],
      ),
    );
  }
}