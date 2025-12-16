import 'package:flutter/material.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final Color primaryColor = const Color(0xFF2D9C96);
  final Color lightTealColor = const Color(0xFFE0F2F1);
  final Color backgroundColor = const Color(0xFFF5F9FC);
  final Color textDarkColor = const Color(0xFF1D2635);

  final List<String> months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
  ];
  String selectedMonth = 'فبراير';
  int selectedDay = 5;
  String selectedTime = "10:00 ص";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeaderSection(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _buildMonthSelector(),
                      const SizedBox(height: 30),
                      _buildCalendarGrid(),
                      const SizedBox(height: 30),

                      const Text(
                        "اختيار الوقت:",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildTimeSlots(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Stack(
      children: [
        Positioned(
          top: 10,
          right: 15,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            color: textDarkColor,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            height: 190,
            child: Image.asset(
              'assets/images/image 1.png',
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.image, size: 100, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Center(
      child: Container(
        height: 45,
        width: 180,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EEF5),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedMonth,
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
            isExpanded: true,
            dropdownColor: const Color(0xFFE8EEF5),
            borderRadius: BorderRadius.circular(15),
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
            ),
            onChanged: (v) => setState(() => selectedMonth = v!),
            items: months
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    alignment: Alignment.center,
                    child: Text(v),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final weekDays = [
      'أحد',
      'أثنين',
      'ثلاثاء',
      'أربعاء',
      'خميس',
      'جمعه',
      'سبت',
    ];

    final List<Map<String, dynamic>> days = List.generate(30, (index) {
      int d = index + 1;
      bool booked = [3, 11, 13, 16, 17, 25, 28].contains(d);
      return {'day': d, 'isBooked': booked};
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays
                .map(
                  (e) => SizedBox(
                    width: 40,
                    child: Text(
                      e,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textDarkColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 15,
            crossAxisSpacing: 5,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            final day = days[index]['day'];
            final isBooked = days[index]['isBooked'];
            final isSelected = day == selectedDay;

            return InkWell(
              onTap: isBooked ? null : () => setState(() => selectedDay = day),
              customBorder: const CircleBorder(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryColor, width: 2),
                      ),
                    ),

                  Text(
                    "$day",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w900
                          : FontWeight.w500,
                      color: textDarkColor,
                    ),
                  ),

                  if (isBooked)
                    Icon(
                      Icons.close,
                      color: primaryColor.withOpacity(0.8), // شفافية بسيطة
                      size: 24,
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimeSlots() {
    final times = [
      {'time': "10:00 ص", 'status': 'available'},
      {'time': "10:30 ص", 'status': 'available'},
      {'time': "11:00 ص", 'status': 'booked'},
      {'time': "12:00 م", 'status': 'available'},
      {'time': "12:30 م", 'status': 'available'},
      {'time': "01:00 م", 'status': 'available'},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: times.map((t) {
        String time = t['time'] as String;
        bool booked = t['status'] == 'booked';
        bool selected = time == selectedTime;

        return InkWell(
          onTap: booked ? null : () => setState(() => selectedTime = time),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: booked
                  ? lightTealColor
                  : (selected ? Colors.transparent : const Color(0xFFEEF2F6)),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: selected ? primaryColor : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 14,
                    decoration: booked ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.grey,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: booked ? Colors.grey : textDarkColor,
                  ),
                ),
                if (booked) ...[
                  const SizedBox(width: 5),
                  const Icon(Icons.close, size: 16, color: Colors.grey),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE0F2F1),
          foregroundColor: textDarkColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: primaryColor, width: 1.5),
          ),
        ),
        child: const Text(
          "حجز الموعد",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
