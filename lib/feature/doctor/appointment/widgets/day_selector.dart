import 'package:flutter/material.dart';

class DaySelector extends StatelessWidget {
  final List<String> days = const ['س', 'ج', 'خ', 'أ', 'ث', 'إ', 'ح'];
  final List<int> dates = const [25, 26, 27, 28, 29, 30, 31];
  final int selectedIndex;

  const DaySelector({
    super.key,
    this.selectedIndex = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final isSelected = index == selectedIndex;
          return Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0D9488)
                      : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    days[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dates[index].toString(),
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF0D9488)
                      : Colors.black54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

