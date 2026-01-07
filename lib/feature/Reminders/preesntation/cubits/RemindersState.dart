import 'package:health_compass/feature/Reminders/data/model/reminders_model.dart';

abstract class RemindersState {}
class RemindersInitial extends RemindersState {}
class RemindersLoaded extends RemindersState {
  final List<ReminderModel> reminders;
  RemindersLoaded(this.reminders);
}