import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DaySelector extends StatefulWidget {
  final Function(DateTime) onDaySelected;

  const DaySelector({super.key, required this.onDaySelected});

  @override
  State<DaySelector> createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  int _selectedIndex = 0;
  late List<DateTime> _days;

  @override
  void initState() {
    super.initState();
    _days = List.generate(
      14,
      (index) => DateTime.now().add(Duration(days: index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // ✅ التعديل هنا: زدنا الارتفاع من 90 إلى 110 لاستيعاب المحتوى
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 10), // قللنا الهوامش قليلاً
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final date = _days[index];
          final isSelected = index == _selectedIndex;

          final dayName = DateFormat('E', 'ar').format(date);
          final dayNumber = date.day.toString();

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              widget.onDaySelected(date);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // توسيط العناصر
                children: [
                  Container(
                    width: 45, // تكبير الدائرة قليلاً لتناسب النص
                    height: 45,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(
                              0.2,
                            ), // تحسين الألوان للخلفية الخضراء
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        dayName,
                        style: TextStyle(
                          // تغيير اللون ليتناسب مع الخلفية (إذا كانت الدائرة بيضاء فالنص ملون، والعكس)
                          color: isSelected
                              ? const Color(0xFF0D9488)
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dayNumber,
                    style: TextStyle(
                      color: Colors
                          .white, // النص السفلي دائماً أبيض لأنه فوق خلفية خضراء
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
