import 'package:flutter/material.dart';
import 'package:white_tv/features/live/data/models/epg_program.dart';
import 'package:white_tv/features/live/presentation/widgets/epg_program_tile.dart';

class EpgProgramList extends StatelessWidget {
  final List<EpgProgram> programs;
  final void Function(EpgProgram) onProgramTap;

  const EpgProgramList({
    super.key,
    required this.programs,
    required this.onProgramTap,
  });

  @override
  Widget build(BuildContext context) {
    if (programs.isEmpty) {
      return const Center(
        child: Text(
          'No programs available',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: programs.length,
      itemBuilder: (context, index) {
        final program = programs[index];
        final isActive = program.isCurrentlyActive;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: EpgProgramTile(
            program: program,
            isActive: isActive,
            onTap: () => onProgramTap(program),
          ),
        );
      },
    );
  }
}
