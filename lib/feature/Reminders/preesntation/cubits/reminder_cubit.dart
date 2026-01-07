import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/feature/Reminders/data/model/reminders_model.dart';
import 'package:health_compass/feature/Reminders/preesntation/cubits/RemindersState.dart';
import 'package:hive/hive.dart';
import 'package:health_compass/core/servaces/notification_service.dart';

class RemindersCubit extends Cubit<RemindersState> {
  final Box<ReminderModel> reminderBox;
  final NotificationService notificationService;

  RemindersCubit(this.reminderBox, this.notificationService)
      : super(RemindersInitial()) {
    loadReminders();
  }

  void loadReminders() {
    emit(RemindersLoaded(reminderBox.values.toList()));
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
    await reminderBox.delete(reminder.id);
    await notificationService.cancelReminder(reminder.notificationId);
    loadReminders();
  }
}
