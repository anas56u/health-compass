import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/feature/patient/data/repo/cubit/patient_appointments_cubit.dart';
import 'package:health_compass/feature/patient/ui/BookingScreen.dart';
import 'package:intl/intl.dart';
import 'package:health_compass/feature/doctor/appointment/models/appointment_model.dart';

class PatientAppointmentsPage extends StatelessWidget {
  const PatientAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // تهيئة الكيوبت وجلب البيانات فور الدخول
      create: (context) => PatientAppointmentsCubit()..getMyAppointments(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            "مواعيدي",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),

        // إضافة زر "حجز موعد جديد"
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton.extended(
            onPressed: () => _navigateToBooking(context),
            backgroundColor: const Color(0xFF0D9488),
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.white,
            ),
            label: const Text(
              "حجز موعد جديد",
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        body: BlocBuilder<PatientAppointmentsCubit, PatientAppointmentsState>(
          builder: (context, state) {
            // حالة التحميل
            if (state is PatientAppointmentsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0D9488)),
              );
            }

            // حالة الخطأ مع زر لإعادة المحاولة
            if (state is PatientAppointmentsError) {
              return _buildErrorState(context, state.message);
            }

            // حالة النجاح وعرض المواعيد
            if (state is PatientAppointmentsLoaded) {
              if (state.appointments.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () async => context
                    .read<PatientAppointmentsCubit>()
                    .getMyAppointments(),
                color: const Color(0xFF0D9488),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    80,
                  ), // ترك مساحة للزر العائم
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemCount: state.appointments.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) =>
                      _buildAppointmentCard(context, state.appointments[index]),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  // --- واجهة عرض الأخطاء ---
  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 60, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            "حدث خطأ: $message",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontFamily: 'Tajawal'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () =>
                context.read<PatientAppointmentsCubit>().getMyAppointments(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
            ),
            child: const Text(
              "إعادة المحاولة",
              style: TextStyle(color: Colors.white, fontFamily: 'Tajawal'),
            ),
          ),
        ],
      ),
    );
  }

  // --- كرت عرض الموعد ---
  Widget _buildAppointmentCard(
    BuildContext context,
    AppointmentModel appointment,
  ) {
    final statusConfig = _getStatusConfig(appointment.status);
    final dateStr = DateFormat('EEEE d MMMM', 'ar').format(appointment.date);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(right: BorderSide(color: statusConfig.color, width: 5)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF0D9488).withOpacity(0.1),
                  backgroundImage: appointment.doctorImage != null
                      ? NetworkImage(appointment.doctorImage!)
                      : null,
                  child: appointment.doctorImage == null
                      ? const Icon(
                          Icons.person,
                          color: Color(0xFF0D9488),
                          size: 30,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "د. ${appointment.doctorName}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.type,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(statusConfig),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "$dateStr • ${appointment.timeString}",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
                if (appointment.status != 'cancelled')
                  TextButton(
                    onPressed: () => _showCancelDialog(context, appointment),
                    child: const Text(
                      "إلغاء الحجز",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ويدجت حالة الموعد ---
  Widget _buildStatusBadge(_StatusConfig config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.text,
            style: TextStyle(
              color: config.color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  // --- واجهة القائمة الفارغة ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_rounded, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text(
            "ليس لديك أي مواعيد قادمة",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  // --- منطق التنقل لشاشة الحجز ---
  void _navigateToBooking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (dialogContext) => BlocProvider.value(
          value: context.read<PatientAppointmentsCubit>(),
          child: const BookingScreen(),
        ),
      ),
    );
  }

  // --- نافذة تأكيد الإلغاء ---
  void _showCancelDialog(BuildContext context, AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "تأكيد الإلغاء",
          style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "هل أنت متأكد من رغبتك في إلغاء هذا الموعد؟ لا يمكن التراجع عن هذا الإجراء.",
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("تراجع", style: TextStyle(fontFamily: 'Tajawal')),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PatientAppointmentsCubit>().cancelAppointment(
                appointment.id,
              );
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "نعم، إلغاء الحجز",
              style: TextStyle(color: Colors.white, fontFamily: 'Tajawal'),
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status) {
      case 'confirmed':
        return _StatusConfig(Colors.green, Icons.check_circle_rounded, "مؤكد");
      case 'cancelled':
        return _StatusConfig(Colors.red, Icons.cancel_rounded, "ملغي");
      default:
        return _StatusConfig(
          Colors.orange,
          Icons.access_time_rounded,
          "قيد الانتظار",
        );
    }
  }
}

class _StatusConfig {
  final Color color;
  final IconData icon;
  final String text;
  _StatusConfig(this.color, this.icon, this.text);
}
