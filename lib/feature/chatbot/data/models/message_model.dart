import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String text;
  final bool isBot;
  final DateTime timestamp;

  const ChatMessageModel({
    required this.text,
    required this.isBot,
    required this.timestamp,
  });

  // تحويل البيانات من Firebase إلى الموديل
  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
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
