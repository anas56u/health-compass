import 'package:hive/hive.dart';

part 'reminders_model.g.dart';

@HiveType(typeId: 0)
class ReminderModel extends HiveObject {
  @HiveField(0)
  final String id; // للتخزين فقط (UUID)

  @HiveField(1)
  final int notificationId; // خاص بالإشعارات

  @HiveField(2)
  String title;

  @HiveField(3)
  String? details;

  @HiveField(4)
  DateTime time;

  @HiveField(5)
  List<int> repeatDays; // 1 = Monday ... 7 = Sunday

  @HiveField(6)
  bool isEnabled;

  @HiveField(7)
  int iconCode;

  @HiveField(8) // حقل جديد
  DateTime? lastCompletedDate;

  ReminderModel({
    required this.id,
    required this.notificationId,
    required this.title,
    this.details,
    required this.time,
    required this.repeatDays,
    this.isEnabled = true,
    required this.iconCode,
  });
}
