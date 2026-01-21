import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/appointments_cubit.dart';
import '../models/appointment_model.dart';
import '../widgets/day_selector.dart';
import '../widgets/time_slot.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // إنشاء الكيوبت وجلب مواعيد اليوم الحالي عند فتح الصفحة
      create: (context) => AppointmentsCubit()..getAppointments(DateTime.now()),
      child: Scaffold(
        backgroundColor: const Color(
          0xFFF5F7FA,
        ), // خلفية رمادية فاتحة مريحة للعين
        body: Column(
          children: [
            // ---------------------------------------------------------
            // 1. الجزء العلوي (Header + DaySelector)
            // ---------------------------------------------------------
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // عنوان الصفحة
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'جدول المواعيد',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // شريط اختيار الأيام
                    Builder(
                      builder: (context) {
                        return DaySelector(
                          onDaySelected: (date) {
                            // عند تغيير اليوم، نحدث القائمة
                            context.read<AppointmentsCubit>().getAppointments(
                              date,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ---------------------------------------------------------
            // 2. قائمة المواعيد (Appointment List)
            // ---------------------------------------------------------
            Expanded(
              child: BlocBuilder<AppointmentsCubit, AppointmentsState>(
                builder: (context, state) {
                  // حالة التحميل
                  if (state is AppointmentsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0D9488),
                      ),
                    );
                  }

                  // حالة الخطأ
                  if (state is AppointmentsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: Colors.red[300],
                            size: 50,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "حدث خطأ في جلب المواعيد",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<AppointmentsCubit>().getAppointments(
                                DateTime.now(),
                              );
                            },
                            child: const Text("إعادة المحاولة"),
                          ),
                        ],
                      ),
                    );
                  }

                  // حالة النجاح وعرض البيانات
                  if (state is AppointmentsLoaded) {
                    // قائمة الفترات الزمنية للعيادة
                    final List<String> timeSlots = [
                      "09:00 ص",
                      "09:30 ص",
                      "10:00 ص",
                      "10:30 ص",
                      "11:00 ص",
                      "11:30 ص",
                      "12:00 م",
                      "12:30 م",
                      "01:00 م",
                      "01:30 م",
                      "02:00 م",
                    ];

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<AppointmentsCubit>().getAppointments(
                          state.selectedDate,
                        );
                      },
                      color: const Color(0xFF0D9488),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          top: 24,
                          left: 16,
                          right: 16,
                          bottom: 80,
                        ),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount: timeSlots.length,
                        itemBuilder: (context, index) {
                          final time = timeSlots[index];

                          // البحث عن موعد يطابق الوقت الحالي
                          final appointment = state.appointments.firstWhere(
                            (app) => app.timeString == time,
                            // إنشاء موديل فارغ إذا لم يوجد موعد
                            orElse: () => AppointmentModel(
                              id: '',
                              patientId: '',
                              patientName: '',
                              doctorId: '',
                              doctorName: '', // حقل ضروري لتجنب الأخطاء
                              date: DateTime.now(),
                              timeString: '',
                              status: 'empty',
                              type: '',
                            ),
                          );

                          return _buildTimeSlotRow(context, time, appointment);
                        },
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- دالة لبناء صف واحد (الوقت + البطاقة) ---
  Widget _buildTimeSlotRow(
    BuildContext context,
    String time,
    AppointmentModel appointment,
  ) {
    final bool isBooked = appointment.status != 'empty';

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // عمود الوقت
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: TimeSlot(time: time),
            ),

            const SizedBox(width: 14),

            // محتوى الموعد (إما بطاقة مريض أو مساحة فارغة)
            Expanded(
              child: isBooked
                  ? _buildBookedCard(context, appointment)
                  : _buildEmptySlotCard(),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. تصميم البطاقة الفارغة (تشير للطبيب أن الوقت متاح) ---
  Widget _buildEmptySlotCard() {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available_rounded,
            color: Colors.grey[400],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            "وقت متاح",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. تصميم بطاقة الموعد المحجوز (تحتوي على بيانات المريض وأزرار التحكم) ---
  Widget _buildBookedCard(BuildContext context, AppointmentModel appointment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس البطاقة: صورة واسم المريض
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF0D9488).withOpacity(0.1),
                child: Text(
                  appointment.patientName.isNotEmpty
                      ? appointment.patientName[0]
                      : '?',
                  style: const TextStyle(
                    color: Color(0xFF0D9488),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'Tajawal',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // نوع الزيارة
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        appointment.type,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blueGrey[700],
                          fontFamily: 'Tajawal',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),

          // إجراءات الطبيب (تثبيت / إلغاء) أو عرض الحالة النهائية
          if (appointment.status == 'confirmed')
            _buildStatusBadge('مؤكد', Colors.green, Icons.check_circle_outline)
          else if (appointment.status == 'cancelled')
            _buildStatusBadge('ملغي', Colors.red, Icons.cancel_outlined)
          else
            Row(
              children: [
                // زر الإلغاء
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    label: 'إلغاء',
                    color: Colors.redAccent,
                    icon: Icons.close_rounded,
                    onTap: () {
                      context.read<AppointmentsCubit>().updateAppointmentStatus(
                        appointment.id,
                        'cancelled',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // زر التثبيت
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    label: 'تثبيت',
                    color: const Color(0xFF0D9488),
                    icon: Icons.check_rounded,
                    onTap: () {
                      context.read<AppointmentsCubit>().updateAppointmentStatus(
                        appointment.id,
                        'confirmed',
                      );
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ويدجت مساعدة لعرض الحالة (مثبت/ملغي)
  Widget _buildStatusBadge(String text, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت مساعدة للأزرار (تثبيت/إلغاء)
  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
