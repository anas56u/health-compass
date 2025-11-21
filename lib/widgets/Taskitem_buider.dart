import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/models/taskitem_model.dart';

class Taskitem_buider extends StatelessWidget {
  final Taskitem_Model task;

  const Taskitem_buider({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = task.isCompleted
        ? Colors.green.shade50
        : const Color(0xFFF0F0F0);

    Widget trailingContent;

    if (task.isCompleted) {
      trailingContent = const Icon(
        Icons.check_circle,
        color: Color(0xFF4CAF50),
        size: 30,
      );
    } else {
      trailingContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.shade700, width: 1),
            ),
            child: Text(
              'أتممتها',
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 5),
          const Icon(
            // وضع الجرس أولاً (على اليسار)
            Icons.notifications_none,
            color: Colors.grey,
            size: 20,
          ),
        ],
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
        ),
        // **الـ Row الرئيسي**: يتم الترتيب من اليمين لليسار (RTL)
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          textDirection: TextDirection.rtl,
          children: [
            // 1. الأيقونة الرئيسية (على اليمين في RTL)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? const Color(0xFFE0F7FA)
                    : task.iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(task.leadingIcon, color: task.iconColor, size: 24),
            ),
            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    task.title,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.subtitle,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 15),
            trailingContent,
          ],
        ),
      ),
    );
  }
}
