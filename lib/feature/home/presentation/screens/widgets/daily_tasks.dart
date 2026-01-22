// lib/core/widgets/daily_tasks.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/feature/achievements/preesntation/cubits/hometask_cubit.dart';

class DailyTasksList extends StatelessWidget {
  final Map<String, bool> tasksStatus;

  const DailyTasksList({super.key, required this.tasksStatus});

  @override
  Widget build(BuildContext context) {
    // قائمة المهام الثابتة (نفس المعرفات لضمان عمل المنطق)
    final List<Map<String, dynamic>> tasks = [
      {
        'id': 'medication',
        'title': 'أخذ الدواء',
        'subtitle': 'حبة واحدة بعد الطعام',
        'icon': Icons.medication_rounded,
        'color': const Color(0xFF3B82F6), // Blue
        'bgColor': const Color(0xFFEFF6FF),
      },
      {
        'id': 'vital_signs',
        'title': 'القياسات الحيوية',
        'subtitle': 'قياس الضغط والسكري',
        'icon': Icons.monitor_heart_rounded,
        'color': const Color(0xFFEF4444), // Red
        'bgColor': const Color(0xFFFEF2F2),
      },
      {
        'id': 'morning_walk',
        'title': 'المشي صباحاً',
        'subtitle': 'لمدة 30 دقيقة',
        'icon': Icons.directions_walk_rounded,
        'color': const Color(0xFF10B981), // Green
        'bgColor': const Color(0xFFECFDF5),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "مهامك اليوم",
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ...tasks.map((task) {
          final taskId = task['id'];
          final isCompleted = tasksStatus[taskId] ?? false;

          return _buildTaskCard(context, task, isCompleted);
        }).toList(),
      ],
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    Map<String, dynamic> task,
    bool isCompleted,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? Colors.grey.shade200 : Colors.transparent,
          width: 1,
        ),
        boxShadow: isCompleted
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // تفعيل المهمة عند الضغط على البطاقة كاملة
            context.read<HometaskCubit>().toggleTask(task['id'], !isCompleted);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // أيقونة المهمة
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.grey.shade200 : task['bgColor'],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    task['icon'],
                    color: isCompleted ? Colors.grey : task['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // النصوص
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['title'],
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.grey : Colors.black87,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (task['subtitle'] != null)
                        Text(
                          task['subtitle'],
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),

                // مربع الاختيار المخصص (Custom Checkbox)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF0D9488)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCompleted
                          ? const Color(0xFF0D9488)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
