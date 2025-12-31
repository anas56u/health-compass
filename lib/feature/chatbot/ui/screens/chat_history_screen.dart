import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/feature/chatbot/data/logic/cubit/chat_cubit.dart';
import 'package:intl/intl.dart' as intl;

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // نستخدم الكيوبت الموجود مسبقاً (الذي تم تمريره)
    final chatCubit = context.read<ChatCubit>();
    const primaryColor = Color(0xFF0D9488);

    return Directionality(
      textDirection: TextDirection.rtl, // ضمان اتجاه عربي
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA), // خلفية رمادية فاتحة
        appBar: AppBar(
          title: const Text(
            "سجل المحادثات",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'Tajawal', // تأكد من استخدام خط التطبيق
            ),
          ),
          backgroundColor: primaryColor,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          // الاستماع للتغيرات في قاعدة البيانات
          stream: chatCubit.getHistoryStream(),
          builder: (context, snapshot) {
            // 1. حالة التحميل
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            }

            // 2. حالة الخطأ أو عدم وجود بيانات
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "لا يوجد محادثات سابقة",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            final sessions = snapshot.data!.docs;

            // 3. عرض القائمة
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final data = sessions[index].data() as Map<String, dynamic>;

                // جلب مقتطف الرسالة والتاريخ
                final preview = data['preview'] ?? 'محادثة جديدة';
                final timestamp = (data['lastMessageTime'] as Timestamp?)
                    ?.toDate();

                // تنسيق التاريخ (مثال: 12/05 - 09:30 PM)
                final dateStr = timestamp != null
                    ? intl.DateFormat('MM/dd - hh:mm a', 'en').format(timestamp)
                    : '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: primaryColor,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Tajawal',
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.grey[300],
                    ),
                    onTap: () {
                      // ✅ الأكشن المهم: تحميل الجلسة والعودة
                      chatCubit.loadSession(sessions[index].id);
                      Navigator.pop(context); // الرجوع للشات لعرض المحادثة
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
