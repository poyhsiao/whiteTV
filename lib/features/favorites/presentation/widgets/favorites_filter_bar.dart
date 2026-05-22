import 'package:flutter/material.dart';

class FavoritesFilterBar extends StatelessWidget {
  final String selectedType;
  final void Function(String type) onTypeSelected;

  const FavoritesFilterBar({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  static const _filters = [
    ('all', '全部'),
    ('movie', '電影'),
    ('series', '劇集'),
    ('anime', '動漫'),
    ('variety', '綜藝'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = selectedType == filter.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.$2),
              selected: isSelected,
              onSelected: (_) => onTypeSelected(filter.$1),
              selectedColor: Colors.amber.withValues(alpha: 0.3),
              checkmarkColor: Colors.amber,
              labelStyle: TextStyle(
                color: isSelected ? Colors.amber : Colors.white70,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}