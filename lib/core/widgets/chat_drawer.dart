import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/core/widgets/AboutApp.dart';
import 'package:health_compass/feature/chatbot/data/logic/cubit/chat_cubit.dart';
import 'package:health_compass/feature/chatbot/ui/screens/chat_history_screen.dart';

class ChatDrawer extends StatelessWidget {
  const ChatDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0D9488);

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 1. رأس القائمة (Header)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage('assets/images/chatlogo.png'),
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "دليل ",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const Text(
                  "مساعدك الطبي الذكي",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. خيارات القائمة
          _buildDrawerItem(
            icon: Icons.add_comment_rounded,
            title: "محادثة جديدة",
            color: primaryColor,
            onTap: () {
              Navigator.pop(context); // إغلاق القائمة
              context.read<ChatCubit>().startNewChat(); // بدء محادثة جديدة
            },
          ),

          _buildDrawerItem(
            icon: Icons.history_rounded,
            title: "سجل المحادثات",
            color: Colors.orangeAccent,
            onTap: () {
              Navigator.pop(context); // إغلاق القائمة

              final cubit = context.read<ChatCubit>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: cubit,
                    child: const ChatHistoryScreen(),
                  ),
                ),
              );
            },
          ),

          const Divider(indent: 20, endIndent: 20, height: 30),

          _buildDrawerItem(
            icon: Icons.info_outline_rounded,
            title: "عن التطبيق",
            color: Colors.grey,
            onTap: () {
              Navigator.pop(context); // إغلاق القائمة

              final cubit = context.read<ChatCubit>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: cubit,
                    child: const AboutAppScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          fontFamily: 'Tajawal', // تأكدنا من الخط هنا أيضاً
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
