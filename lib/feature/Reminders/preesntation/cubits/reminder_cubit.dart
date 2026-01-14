// ------------------ RemindersCubit ------------------
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:health_compass/feature/Reminders/data/model/reminders_model.dart';
import 'package:health_compass/feature/Reminders/preesntation/cubits/RemindersState.dart';
import 'package:health_compass/core/services/notification_service.dart';

class RemindersCubit extends Cubit<RemindersState> {
  final Box<ReminderModel> reminderBox;
  final NotificationService notificationService;

  RemindersCubit(this.reminderBox, this.notificationService)
    : super(RemindersInitial()) {
    loadReminders();
  }

 void loadReminders() async {
    final reminders = reminderBox.values.toList();
    emit(RemindersLoaded(reminders));

    final now = DateTime.now();

    for (var reminder in reminders) {
      // هل قام المستخدم بإنجاز المهمة اليوم؟
      bool isDoneToday = false;
      if (reminder.lastCompletedDate != null) {
        final last = reminder.lastCompletedDate!;
        isDoneToday = last.year == now.year && 
                      last.month == now.month && 
                      last.day == now.day;
      }

      // إذا كانت منجزة اليوم، لا نقم بجدولة الإشعارات المزعجة (أو نلغيها لضمان عدم عودتها)
      if (isDoneToday) {
        // خيار إضافي: يمكنك التأكد من إلغائها هنا أيضاً للأمان
        if (reminder.repeatDays.contains(now.weekday)) {
           await notificationService.cancelTodayAnnoyance(reminder.notificationId, now.weekday);
        }
        continue; // تخطى الجدولة لهذا العنصر
      }

      // إذا لم تكن منجزة، جدولها كالمعتاد
      await notificationService.scheduleAnnoyingReminder(
        id: reminder.notificationId,
        title: reminder.title,
        body: reminder.details,
        time: reminder.time,
        days: reminder.repeatDays,
      );
    }
  }
  Future<void> markAsDone(ReminderModel reminder) async {
    // 1. تحديد اليوم الحالي (مثلاً الاثنين = 1)
    final now = DateTime.now();
    final todayWeekday = now.weekday;

    // 2. إذا كان اليوم هو أحد أيام التكرار، نلغي إشعاراته المزعجة
    if (reminder.repeatDays.contains(todayWeekday)) {
      await notificationService.cancelTodayAnnoyance(
        reminder.notificationId, 
        todayWeekday
      );
    }

    // 3. تحديث الموديل وحفظه في Hive
    // ملاحظة: بما أنه HiveObject يمكننا تعديل الحقل وحفظه مباشرة
    reminder.lastCompletedDate = now;
    await reminder.save(); 

    // 4. تحديث الواجهة
    loadReminders(); 
  }

  Future<void> addReminder(ReminderModel reminder) async {
    await reminderBox.put(reminder.id, reminder);

    await notificationService.scheduleAnnoyingReminder(
      id: reminder.notificationId,
      title: reminder.title,
      body: reminder.details,
      time: reminder.time,
      days: reminder.repeatDays,
    );

    loadReminders();
  }

  Future<void> deleteReminder(ReminderModel reminder) async {
   
    await notificationService.cancelAnnoyingReminder(
      reminder.notificationId, 
      reminder.repeatDays
    );

    await reminderBox.delete(reminder.id);
    
    loadReminders();
  }
}
