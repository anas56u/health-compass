import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج البيانات الخاص بالأدوية (Medication Model)
/// يستخدم لتمثيل بيانات الدواء وتحويلها من وإلى قاعدة بيانات Firestore
class MedicationModel {
  final String id; // المعرف الخاص بالوثيقة في Firestore
  final String medicationName; // اسم الدواء
  final String dosage; // الجرعة (مثل: حبة واحدة)
  final String instructions; // التعليمات (مثل: بعد الأكل)
  final String time; // وقت أخذ الدواء (مثل: 09:00)
  final String period; // الفترة (ص للصباح، م للمساء)
  final List<int> daysOfWeek; // أيام الأسبوع المحددة للتذكير
  final bool isActive; // حالة التذكير (نشط أم معطل)
  final DateTime createdAt; // تاريخ إنشاء التذكير
  final int notificationId; // المعرف الخاص بالتنبيه المحلي على الجهاز

  MedicationModel({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.instructions,
    required this.time,
    required this.period,
    required this.daysOfWeek,
    this.isActive = true,
    required this.createdAt,
    required this.notificationId,
  });

  /// دالة لتحويل البيانات القادمة من Firestore إلى كائن (Object) من نوع MedicationModel
  factory MedicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MedicationModel(
      id: doc.id,
      // نستخدم الرمز (??) للبحث عن المسمى الطويل أولاً ليتوافق مع إضافة فرد العائلة،
      // وإذا لم يوجد يبحث عن المسمى القصير لضمان ظهور البيانات القديمة.
      medicationName: data['medicationName'] ?? data['name'] ?? '',
      dosage: data['dosage'] ?? data['dose'] ?? '',
      instructions: data['instructions'] ?? data['type'] ?? '',
      time: data['time'] ?? '',
      period: data['period'] ?? '',
      // تحويل البيانات القادمة كمصفوفة أرقام بشكل آمن
      daysOfWeek: List<int>.from(data['daysOfWeek'] ?? []),
      isActive: data['isActive'] ?? true,
      // تحويل التاريخ من Timestamp الخاص بـ Firebase إلى DateTime الخاص بـ Dart
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      notificationId: data['notificationId'] ?? 0,
    );
  }

  /// دالة لتحويل كائن الدواء إلى خريطة بيانات (Map) لإرسالها إلى Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'medicationName': medicationName,
      'dosage': dosage,
      'instructions': instructions,
      'time': time,
      'period': period,
      'daysOfWeek': daysOfWeek,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'notificationId': notificationId,
    };
  }

  /// دالة لإنشاء نسخة جديدة من الكائن مع إمكانية تعديل بعض القيم فقط
  MedicationModel copyWith({
    String? id,
    String? medicationName,
    String? dosage,
    String? instructions,
    String? time,
    String? period,
    List<int>? daysOfWeek,
    bool? isActive,
    DateTime? createdAt,
    int? notificationId,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      instructions: instructions ?? this.instructions,
      time: time ?? this.time,
      period: period ?? this.period,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      notificationId: notificationId ?? this.notificationId,
    );
  }
}
