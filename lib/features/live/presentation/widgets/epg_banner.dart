import 'package:flutter/material.dart';
import 'package:white_tv/features/live/data/models/epg_program.dart';

/// Banner showing current and next program info for a live channel.
/// Displayed at the top of the live player or channel list.
class EpgBanner extends StatelessWidget {
  const EpgBanner({
    super.key,
    this.currentProgram,
    this.nextProgram,
    this.onProgramTap,
  });

  final EpgProgram? currentProgram;
  final EpgProgram? nextProgram;
  final void Function(EpgProgram)? onProgramTap;

  @override
  Widget build(BuildContext context) {
    if (currentProgram == null && nextProgram == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (currentProgram != null) ...[
            _buildProgramInfo(currentProgram!, isCurrent: true),
            if (nextProgram != null)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, color: Colors.white54, size: 16),
              ),
          ],
          if (nextProgram != null)
            _buildProgramInfo(nextProgram!, isCurrent: false),
        ],
      ),
    );
  }

  Widget _buildProgramInfo(EpgProgram program, {required bool isCurrent}) {
    return Expanded(
      child: GestureDetector(
        onTap: onProgramTap != null ? () => onProgramTap!(program) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isCurrent ? '現在' : '接下來',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              program.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
