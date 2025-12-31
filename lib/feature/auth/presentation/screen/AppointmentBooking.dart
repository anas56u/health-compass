import 'package:flutter/material.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  // تعريف الألوان لتكون متناسقة
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
        textDirection: TextDirection.rtl, // ضمان الاتجاه العربي
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

  // 1. تحسين الهيدر بإضافة ظل خفيف وتدرج
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
            decoration: BoxDecoration(
              // تدرج لوني خفيف خلف الصورة
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/image 1.png',
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.image, size: 100, color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 2. تحسين قائمة اختيار الشهر
  Widget _buildMonthSelector() {
    return Center(
      child: Container(
        height: 45,
        width: 180,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white, // جعل الخلفية بيضاء لتباين أفضل
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1), // ظل ملون خفيف
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedMonth,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: primaryColor,
            ), // أيقونة أجمل
            isExpanded: true,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(15),
            style: TextStyle(
              color: textDarkColor,
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

  // 3. تحسين شبكة التقويم
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
                        color: Colors.grey[600], // لون أفتح قليلاً للأيام
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
            mainAxisSpacing: 10, // تقليل المسافات قليلاً
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
              child: Container(
                decoration: BoxDecoration(
                  // تغيير الخلفية عند التحديد لتكون ملونة بالكامل
                  color: isSelected
                      ? primaryColor
                      : (isBooked ? Colors.grey[100] : Colors.white),
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  "$day",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    // النص أبيض عند التحديد
                    color: isSelected
                        ? Colors.white
                        : (isBooked ? Colors.grey[400] : textDarkColor),
                    decoration: isBooked ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // 4. تحسين خانات الوقت
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
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: booked
                  ? Colors.grey[100]
                  : (selected
                        ? primaryColor
                        : Colors.white), // لون مميز عند التحديد
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? primaryColor : Colors.grey[200]!,
                width: 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // نقطة الحالة (أخضر للمتاح، رمادي للمحجوز)
                if (!booked)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: selected ? Colors.white : Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected
                        ? Colors.white
                        : (booked ? Colors.grey : textDarkColor),
                    decoration: booked ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // 5. تحسين الزر السفلي
  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 5,
            shadowColor: primaryColor.withOpacity(0.4),
          ),
          // استخدام Ink لقدرة التدرج اللوني
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                "تأكيد الحجز",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
