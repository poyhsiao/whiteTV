import 'package:flutter/material.dart';
import 'package:white_tv/features/live/data/models/epg_program.dart';

class EpgProgramTile extends StatelessWidget {
  final EpgProgram program;
  final VoidCallback onTap;
  final bool isActive;

  const EpgProgramTile({
    super.key,
    required this.program,
    required this.onTap,
    this.isActive = false,
  });

  String _formatTimeRange() {
    final start =
        '${program.startTime.hour.toString().padLeft(2, '0')}:${program.startTime.minute.toString().padLeft(2, '0')}';
    final end =
        '${program.endTime.hour.toString().padLeft(2, '0')}:${program.endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.withValues(alpha: 0.2) : Colors.grey[850],
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? Border.all(color: Colors.blue, width: 2)
              : Border.all(color: Colors.grey[700]!, width: 1),
        ),
        child: Row(
          children: [
            // Time column
            SizedBox(
              width: 80,
              child: Text(
                _formatTimeRange(),
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.white : Colors.grey[400],
                ),
              ),
            ),
            // Program info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                  if (program.category != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        program.category!,
                        style: const TextStyle(
                            fontSize: 10, color: Colors.white70),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isActive)
              const Icon(Icons.play_arrow, color: Colors.blue, size: 20),
          ],
        ),
      ),
    );
  }
}