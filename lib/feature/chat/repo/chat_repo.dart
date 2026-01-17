import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/feature/auth/data/model/masseag_model.dart';

class ChatRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. إرسال رسالة
  Future<void> sendMessage({
    required String receiverId,
    required String text,
  }) async {
    final String currentUserId = _auth.currentUser!.uid;
    final DateTime timestamp = DateTime.now();

    // إنشاء كائن الرسالة
    MessageModel newMessage = MessageModel(
      senderId: currentUserId,
      receiverId: receiverId,
      text: text,
      timestamp: timestamp,
      isRead: false,
    );

    // توليد ID الغرفة (السر هنا!)
    // نقوم بترتيب الـ IDs أبجدياً، مما يضمن أن (userA_userB) هو نفسه (userB_userA)
    // فلا نكرر إنشاء غرف مختلفة لنفس الشخصين
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); 
    String chatRoomId = ids.join("_"); 

    // إضافة الرسالة إلى الكوليكشن
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  // 2. جلب الرسائل (Stream)
  // نستخدم Stream لأننا نريد تحديثاً لحظياً (Real-time)
  Stream<QuerySnapshot> getMessages(String otherUserId) {
    final String currentUserId = _auth.currentUser!.uid;
    
    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true) // الأحدث يظهر في الأسفل (سنعكس الـ ListView)
        .snapshots();
  }
}