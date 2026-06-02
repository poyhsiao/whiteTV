import 'package:flutter/material.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/shared/widgets/poster_card.dart';
import 'package:white_tv/shared/widgets/empty_state.dart';

/// Search results grid widget
class SearchResults extends StatelessWidget {
  final List<Video> results;
  final bool isLoading;
  final void Function(Video video)? onResultSelected;

  const SearchResults({
    super.key,
    required this.results,
    required this.isLoading,
    this.onResultSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (results.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.search_off,
        title: 'No results found',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final video = results[index];
        return PosterCard(
          title: video.title,
          posterUrl: video.posterUrl,
          onTap: () => onResultSelected?.call(video),
        );
      },
    );
  }
}