import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicationDaySelector extends StatelessWidget {
  final List<String> days;
  final List<int> dates;
  final int selectedIndex;
  final Function(int)? onDaySelected;

  const MedicationDaySelector({
    super.key,
    this.days = const ['س', 'ج', 'خ', 'أ', 'ث', 'إ', 'ح'],
    this.dates = const [19, 20, 21, 22, 23, 24, 25],
    this.selectedIndex = 3,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onDaySelected?.call(index),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      days[index],
                      style: GoogleFonts.tajawal(
                        color: isSelected
                            ? const Color(0xFF0D9488)
                            : Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dates[index].toString(),
                  style: GoogleFonts.tajawal(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.7),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

