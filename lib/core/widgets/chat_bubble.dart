import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isBot;
  final Color primaryColor;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isBot,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isBot
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. أيقونة البوت (تظهر فقط إذا كانت الرسالة من البوت)
          if (isBot) ...[
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 13,
                child: CircleAvatar(
                  radius: 15, // Adjust size as needed
                  backgroundImage: AssetImage('assets/images/chatlogo.png'),
                  // Optional: add a background color in case the image has transparency or fails to load
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],

          // 2. جسم الرسالة (الفقاعة)
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isBot ? Colors.white : primaryColor,
                // إضافة ظل خفيف لإعطاء عمق (Elevation)
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                // جعل الحواف دائرية (Rounded Corners)
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  // إذا كان بوت، الحافة اليسرى السفلية حادة، والعكس
                  bottomLeft: Radius.circular(isBot ? 0 : 20),
                  bottomRight: Radius.circular(isBot ? 20 : 0),
                ),
                border: isBot ? Border.all(color: Colors.grey.shade100) : null,
              ),
              // استخدام Markdown لتنسيق النص (Bold, Lists, etc.)
              child: MarkdownBody(
                data: text,
                selectable: true, // السماح بنسخ النص
                styleSheet: MarkdownStyleSheet(
                  // تنسيق الفقرات
                  p: TextStyle(
                    color: isBot ? Colors.black87 : Colors.white,
                    fontSize: 15,
                    height: 1.6, // تباعد أسطر مريح للقراءة
                  ),
                  // تنسيق الخط العريض (Bold)
                  strong: TextStyle(
                    color: isBot ? primaryColor : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  // تنسيق نقاط القائمة
                  listBullet: TextStyle(
                    color: isBot ? primaryColor : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
