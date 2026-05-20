import 'package:flutter/material.dart';
import 'package:white_tv/features/search/search_state.dart';

class CategoryFilter extends StatelessWidget {
  final SearchCategory selectedCategory;
  final ValueChanged<SearchCategory> onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const _labels = {
    SearchCategory.all: '全部',
    SearchCategory.movie: '电影',
    SearchCategory.series: '剧集',
    SearchCategory.anime: '动漫',
    SearchCategory.variety: '综艺',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SearchCategory.values.map((category) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_labels[category]!),
              selected: category == selectedCategory,
              onSelected: (_) => onCategorySelected(category),
            ),
          );
        }).toList(),
      ),
    );
  }
}