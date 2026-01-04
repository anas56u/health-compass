import 'package:flutter/material.dart';
import 'package:health_compass/feature/Reminders/widgets/AddReminderDialog.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  final Color primaryColor = const Color(0xFF137A74);
  final Color backgroundColor = const Color(0xFFEFEFEF);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'اضافه تذكير',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'التذكيرات اليوميه'),
              ReminderCard(
                title: 'أخذ دواء Metformin 500mg',
                subtitle: 'يومياً الساعه 8:00 ص',
                iconData: Icons.medication,
                iconColor: const Color(0xFF26A69A),
              ),
              ReminderCard(
                title: 'قياس نبضات القلب',
                subtitle: 'يومياً الساعه 12:00 ظهراً',
                iconData: Icons.favorite,
                iconColor: const Color(0xFFEF5350),
              ),
              ReminderCard(
                title: 'ادويه بعد الظهر',
                subtitle: 'يومياً الساعه 2:00 م',
                iconData: Icons.poll, // Placeholder icon
                iconColor: const Color(0xFF6D4C41),
              ),
              const SizedBox(height: 20),
              const SectionHeader(title: 'التذكيرات المهمه'),
              ReminderCard(
                title: 'لديك موعد مع الطبيب',
                subtitle: '5\\2\\2026',
                iconData: Icons.person,
                iconColor: const Color(0xFF1E88E5),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'اضافه تذكير',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AddReminderDialog(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class ReminderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;
  final Color iconColor;
  const ReminderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
            child: Icon(iconData, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF455A64),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 15),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.grey,
                ),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
