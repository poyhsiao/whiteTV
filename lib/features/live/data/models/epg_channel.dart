import 'package:white_tv/features/live/data/models/epg_program.dart';

class EpgChannel {
  final String id;
  final String name;
  final String? logoUrl;
  final List<EpgProgram> programs;

  const EpgChannel({
    required this.id,
    required this.name,
    this.logoUrl,
    this.programs = const [],
  });

  EpgChannel copyWith({
    String? id,
    String? name,
    String? logoUrl,
    List<EpgProgram>? programs,
  }) {
    return EpgChannel(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      programs: programs ?? this.programs,
    );
  }

  EpgChannel addProgram(EpgProgram program) {
    return copyWith(programs: [...programs, program]);
  }

  bool get programsAreSortedByStartTime {
    for (int i = 0; i < programs.length - 1; i++) {
      if (programs[i].startTime.isAfter(programs[i + 1].startTime)) {
        return false;
      }
    }
    return true;
  }

  EpgProgram? get currentProgram {
    for (final program in programs) {
      if (program.isCurrentlyActive) {
        return program;
      }
    }
    return null;
  }

  List<EpgProgram> programsForDay(DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return programs.where((p) {
      return p.startTime.isAfter(dayStart) && p.startTime.isBefore(dayEnd);
    }).toList();
  }
}