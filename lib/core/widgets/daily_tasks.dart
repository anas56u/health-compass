import 'package:flutter/material.dart';
import 'package:health_compass/core/widgets/Taskitem_buider.dart';
import 'package:health_compass/models/taskitem_model.dart';

class DailyTasks extends StatelessWidget {
  List<Taskitem_Model> tasks = [
    Taskitem_Model(
      title: 'الجرعه الصباحيه',
      subtitle: 'تم اخذها الساعه 8:00ص - Metformin 500mg',
      leadingIcon: Icons.medication,
      iconColor: Colors.teal,
      isCompleted: true,
    ),
    Taskitem_Model(
      title: 'قياس نسبة السكر',
      subtitle: 'قبل تناول وجبه الافطار',
      leadingIcon: Icons.restaurant,
      iconColor: Colors.blue,
      isCompleted: true,
    ),
    Taskitem_Model(
      title: 'المشي صباحاً',
      subtitle: '15 دقيقه من وقتك',
      leadingIcon: Icons.directions_walk,
      iconColor: Colors.green,
      isCompleted: true,
    ),
    Taskitem_Model(
      title: 'قياس نبضات القلب',
      subtitle: 'القراءه الصباحيه الساعه 10:00 ص',
      leadingIcon: Icons.favorite,
      iconColor: Colors.red,
      isCompleted: false,
    ),
    Taskitem_Model(
      title: 'دواء بعد الظهر',
      subtitle: 'تأخذ الجرعه الساعه 2:00م',
      leadingIcon: Icons.local_pharmacy,
      iconColor: Colors.brown,
      isCompleted: false,
    ),
  ];
  int totalTasks = 5;
  int completedTasks = 3;
  late final double progress = completedTasks / totalTasks;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              ":مهام اليوم",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF00796B),
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$completedTasks\\$totalTasks',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Taskitem_buider(task: tasks[0]),
            Taskitem_buider(task: tasks[1]),
            Taskitem_buider(task: tasks[2]),
            Taskitem_buider(task: tasks[3]),
            Taskitem_buider(task: tasks[4]),
          ],
        ),
      ),
    );
  }
}
