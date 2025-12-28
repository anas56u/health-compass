// lib/core/widgets/daily_tasks.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/feature/achievements/preesntation/cubits/hometask_cubit.dart';

class DailyTasksList extends StatelessWidget {
  final Map<String, bool> tasksStatus;

  const DailyTasksList({super.key, required this.tasksStatus});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tasks = [
      {
        'id': 'medication', // احتفظنا بالدواء
        'title': 'أخذ الدواء',
        'icon': Icons.medication,
        'color': Colors.blue,
      },
      {
        'id': 'vital_signs', // مهمة جديدة: القياسات الحيوية
        'title': 'قياس الضغط والسكري',
        'icon': Icons.monitor_heart,
        'color': Colors.redAccent,
      },
      {
        'id': 'morning_walk', // مهمة جديدة: المشي الصباحي (بدل العداد)
        'title': 'المشي صباحاً',
        'icon': Icons.directions_walk,
        'color': Colors.green,
      },
    ];

    return Column(
      children: tasks.map((task) {
        final taskId = task['id'];
        final isCompleted = tasksStatus[taskId] ?? false; 

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: task['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(task['icon'], color: task['color']),
            ),
            title: Text(
              task['title'],
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.grey : Colors.black,
              ),
            ),
            trailing: Checkbox(
              value: isCompleted,
              activeColor: const Color(0xFF009688),
              onChanged: (val) {
               
                context.read<HometaskCubit>().toggleTask(
                  taskId,
                  val ?? false,
                   
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}
