import 'package:flutter/material.dart';

class DoctorBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const DoctorBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_rounded,
            label: 'الرئيسية',
            index: 0,
            isSelected: currentIndex == 0,
          ),
          _buildNavItem(
            icon: Icons.notifications_rounded,
            label: 'الاشعارات',
            index: 1,
            isSelected: currentIndex == 1,
          ),
          _buildNavItem(
            icon: Icons.chat_bubble_rounded,
            label: 'الدردشة',
            index: 2,
            isSelected: currentIndex == 2,
          ),
          _buildNavItem(
            icon: Icons.calendar_today_rounded,
            label: 'المواعيد',
            index: 3,
            isSelected: currentIndex == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF0D9488) : Colors.grey[400],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF0D9488)
                      : Colors.grey[400],
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
