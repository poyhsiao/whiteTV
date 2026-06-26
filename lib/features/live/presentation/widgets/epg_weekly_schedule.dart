// UI_UX §9.5: EPG 一週節目表
// 顯示單一頻道一週節目，可切換日期
import 'package:flutter/material.dart';
import 'package:white_tv/features/live/data/models/epg_program.dart';

class EpgWeeklySchedule extends StatefulWidget {
  final List<EpgProgram> programs;
  final String channelName;

  const EpgWeeklySchedule({
    super.key,
    required this.programs,
    required this.channelName,
  });

  @override
  State<EpgWeeklySchedule> createState() => _EpgWeeklyScheduleState();
}

class _EpgWeeklyScheduleState extends State<EpgWeeklySchedule> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final dayPrograms = widget.programs.where((p) {
      return p.startTime.year == _selectedDate.year &&
          p.startTime.month == _selectedDate.month &&
          p.startTime.day == _selectedDate.day;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() {
                  _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                }),
              ),
              Text(
                '${_selectedDate.year}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() {
                  _selectedDate = _selectedDate.add(const Duration(days: 1));
                }),
              ),
              const Spacer(),
              Text(widget.channelName, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        Expanded(
          child: dayPrograms.isEmpty
              ? const Center(child: Text('當日無節目表'))
              : ListView.builder(
                  itemCount: dayPrograms.length,
                  itemBuilder: (context, index) {
                    final p = dayPrograms[index];
                    return ListTile(
                      leading: Text(
                        '${p.startTime.hour.toString().padLeft(2, '0')}:${p.startTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      title: Text(p.title),
                      subtitle: p.description != null ? Text(p.description!) : null,
                      trailing: Text(
                        '${p.duration.inMinutes} 分鐘',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}