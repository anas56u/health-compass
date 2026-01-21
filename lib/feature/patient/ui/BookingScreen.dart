import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/feature/patient/data/repo/cubit/patient_appointments_cubit.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // 1. حل مشكلة الألوان المفقودة (image_c5165d.png)
  final Color primaryColor = const Color(0xFF0D9488);
  final Color backgroundColor = const Color(0xFFF5F9FC);

  // متغيرات الحجز
  DateTime selectedDate = DateTime.now();
  String selectedTime = "09:00 ص";
  String selectedType = "كشف عام";

  // بيانات الطبيب المختار
  String? selectedDoctorId;
  String? selectedDoctorName;
  String? selectedDoctorImage;

  final List<String> timeSlots = [
    "09:00 ص",
    "10:00 ص",
    "11:00 ص",
    "12:00 م",
    "01:00 م",
    "02:00 م",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "حجز موعد جديد",
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "اختر الطبيب المعالج:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 10),

            // 2. جلب الأطباء المرتبطين بالمريض فقط ديناميكياً
            _buildDoctorDropdown(),

            const SizedBox(height: 25),
            const Text(
              "اختر التاريخ:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 10),
            _buildDatePicker(),

            const SizedBox(height: 25),
            const Text(
              "اختر الوقت:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 10),
            _buildTimePicker(),

            const SizedBox(height: 40),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  // --- دالة جلب الأطباء المرتبطين من Firestore ---
  Widget _buildDoctorDropdown() {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return StreamBuilder<DocumentSnapshot>(
      // 1. جلب وثيقة المريض الحالي للحصول على قائمة معرفات أطبائه
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .snapshots(),
      builder: (context, patientSnapshot) {
        if (patientSnapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }

        if (!patientSnapshot.hasData || !patientSnapshot.data!.exists) {
          return _buildErrorText("تعذر العثور على بيانات المريض");
        }

        // ✅ التعديل هنا: استخدام doctor_id (بصيغة المفرد) ليتطابق مع الفهرس
        List<dynamic> linkedDoctorIds =
            patientSnapshot.data!.get('doctor_ids') ?? [];

        if (linkedDoctorIds.isEmpty) {
          return _buildErrorText("لا يوجد أطباء مرتبطين بك حالياً");
        }

        // 2. جلب تفاصيل هؤلاء الأطباء فقط
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where(FieldPath.documentId, whereIn: linkedDoctorIds)
              .snapshots(),
          builder: (context, doctorSnapshot) {
            if (doctorSnapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!doctorSnapshot.hasData || doctorSnapshot.data!.docs.isEmpty) {
              return const SizedBox();
            }

            final doctors = doctorSnapshot.data!.docs;

            return DropdownButtonFormField<String>(
              value: selectedDoctorId,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                color: Colors.black87,
              ),
              decoration: _buildInputDecoration(),
              hint: const Text(
                "اختر الطبيب المعالج",
                style: TextStyle(fontFamily: 'Tajawal'),
              ),
              items: doctors.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final String name = data['full_name'] ?? "غير معروف";

                return DropdownMenuItem<String>(
                  value: doc.id,
                  child: Text("د. $name"),
                );
              }).toList(),
              onChanged: (val) {
                if (val == null) return;
                final docData =
                    doctors.firstWhere((d) => d.id == val).data()
                        as Map<String, dynamic>;

                setState(() {
                  selectedDoctorId = val;
                  selectedDoctorName = "د. ${docData['full_name']}";
                  selectedDoctorImage = docData['image_url'];
                });
              },
              validator: (value) => value == null ? 'يرجى اختيار الطبيب' : null,
            );
          },
        );
      },
    );
  }

  // دالة مساعدة لتنسيق الحقل
  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
      ),
    );
  }

  // دالة مساعدة لعرض رسائل التنبيه
  Widget _buildErrorText(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.red,
          fontFamily: 'Tajawal',
          fontSize: 13,
        ),
      ),
    );
  }

  // --- دالة اختيار التاريخ ---
  Widget _buildDatePicker() {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      title: Text("${selectedDate.toLocal()}".split(' ')[0]),
      trailing: Icon(Icons.calendar_today, color: primaryColor),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (picked != null) setState(() => selectedDate = picked);
      },
    );
  }

  // --- دالة اختيار الوقت ---
  Widget _buildTimePicker() {
    return Wrap(
      spacing: 10,
      children: timeSlots.map((time) {
        final isSelected = selectedTime == time;
        return ChoiceChip(
          label: Text(time),
          selected: isSelected,
          selectedColor: primaryColor.withOpacity(0.2),
          onSelected: (selected) => setState(() => selectedTime = time),
        );
      }).toList(),
    );
  }

  // --- زر التأكيد وحل مشكلة الـ Provider (image_ba86cf.png) ---
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          if (selectedDoctorId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("يرجى اختيار الطبيب أولاً")),
            );
            return;
          }

          // استدعاء الحجز عبر الكيوبت الممرر للشاشة
          context.read<PatientAppointmentsCubit>().bookAppointment(
            doctorId: selectedDoctorId!,
            doctorName: selectedDoctorName!,
            doctorImage: selectedDoctorImage,
            date: selectedDate,
            time: selectedTime,
            type: selectedType,
          );

          Navigator.pop(context);
        },
        child: const Text(
          "تأكيد الحجز",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Tajawal',
          ),
        ),
      ),
    );
  }
}
