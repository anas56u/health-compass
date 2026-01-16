import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/feature/Reminders/data/model/reminders_model.dart';
import 'package:health_compass/feature/Reminders/presentation/cubits/reminder_cubit.dart';
import 'package:health_compass/feature/Reminders/widgets/AddReminderDialog.dart';
import 'package:health_compass/feature/Reminders/presentation/cubits/RemindersState.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  final Color primaryColor = const Color(0xFF137A74);
  final Color backgroundColor = const Color(0xFFEFEFEF);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'اضافه تذكير',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'التذكيرات اليوميه'),

              // BlocBuilder لعرض التذكيرات من Cubit
              BlocBuilder<RemindersCubit, RemindersState>(
                builder: (context, state) {
                  if (state is RemindersLoaded) {
                    if (state.reminders.isEmpty) {
                      return const Text('لا توجد تذكيرات بعد');
                    }
                    return Column(
                      children: state.reminders.map((reminder) {
                        return ReminderCard(
                          reminder: reminder,
                          iconColor: primaryColor,
                        );
                      }).toList(),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'اضافه تذكير',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    final reminder = await showDialog<ReminderModel>(
                      context: context,
                      builder: (_) => const AddReminderDialog(),
                    );

                    if (reminder != null && context.mounted) {
                      context.read<RemindersCubit>().addReminder(reminder);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final Color iconColor;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    bool isDoneToday = false;
if (reminder.lastCompletedDate != null) {
  final now = DateTime.now();
  final last = reminder.lastCompletedDate!;
  isDoneToday = last.year == now.year && last.month == now.month && last.day == now.day;
}
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
            child: Icon(
              IconData(reminder.iconCode, fontFamily: 'MaterialIcons'),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF455A64),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الساعة ${TimeOfDay.fromDateTime(reminder.time).format(context)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
<<<<<<< HEAD:lib/feature/Reminders/presentation/screens/Reminders_page.dart
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.grey,
                ),
=======
         icon: Icon(
           isDoneToday ? Icons.check_circle : Icons.circle_outlined,
           color: isDoneToday ? Colors.green : Colors.grey,
           size: 28,
         ),
         onPressed: isDoneToday 
           ? null // إذا انتهت لا تفعل شيئاً
           : () {
               context.read<RemindersCubit>().markAsDone(reminder);
             },
       ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
>>>>>>> f1a3daae5c0d05d7279170ab2ab263d71c297254:lib/feature/Reminders/preesntation/screens/Reminders_page.dart
                onPressed: () {
                  context.read<RemindersCubit>().deleteReminder(reminder);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
