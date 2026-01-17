import 'package:cloud_firestore/cloud_firestore.dart';

class bot_MessageModel {
  final String text;
  final bool isBot;
  final DateTime timestamp;

  const bot_MessageModel({
    required this.text,
    required this.isBot,
    required this.timestamp,
  });

  // تحويل البيانات من Firebase إلى الموديل
  factory bot_MessageModel.fromMap(Map<String, dynamic> map) {
    return bot_MessageModel(
      text: map['text'] ?? '',
      isBot: map['isBot'] ?? false,
      // تحويل Timestamp الخاص بفايربيس إلى DateTime عادي
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // تحويل الموديل إلى بيانات لرفعها لـ Firebase
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isBot': isBot,
      'timestamp': FieldValue.serverTimestamp(), // نستخدم توقيت السيرفر
    };
  }
}
