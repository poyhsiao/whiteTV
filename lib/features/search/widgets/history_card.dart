import 'package:flutter/material.dart';

class HistoryCard extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const HistoryCard({
    super.key,
    required this.query,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(query)),
            IconButton(
              key: const Key('delete_btn'),
              icon: const Icon(Icons.close, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
