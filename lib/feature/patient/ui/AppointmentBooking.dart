import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_compass/feature/patient/data/repo/cubit/patient_appointments_cubit.dart';
import 'package:health_compass/feature/patient/ui/BookingScreen.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:health_compass/feature/doctor/appointment/models/appointment_model.dart';

class PatientAppointmentsPage extends StatelessWidget {
  const PatientAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدام Directionality لضمان محاذاة اللغة العربية بشكل صحيح
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (context) => PatientAppointmentsCubit()..getMyAppointments(),
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: _buildAppBar(),
          floatingActionButton: _buildFAB(context),
          body: BlocBuilder<PatientAppointmentsCubit, PatientAppointmentsState>(
            builder: (context, state) {
              if (state is PatientAppointmentsLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0D9488)),
                );
              }

              if (state is PatientAppointmentsError) {
                return _buildErrorState(context, state.message);
              }

              if (state is PatientAppointmentsLoaded) {
                if (state.appointments.isEmpty) return _buildEmptyState();

                return RefreshIndicator(
                  onRefresh: () async => context
                      .read<PatientAppointmentsCubit>()
                      .getMyAppointments(),
                  color: const Color(0xFF0D9488),
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.appointments.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) => _buildAppointmentCard(
                      context,
                      state.appointments[index],
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        "مواعيدي",
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
          fontFamily: 'Tajawal',
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15.r)),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Builder(
      builder: (context) => FloatingActionButton.extended(
        onPressed: () => _navigateToBooking(context),
        backgroundColor: const Color(0xFF0D9488),
        icon: Icon(
          Icons.calendar_month_rounded,
          color: Colors.white,
          size: 20.sp,
        ),
        label: Text(
          "حجز جديد",
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    AppointmentModel appointment,
  ) {
    final statusConfig = _getStatusConfig(appointment.status);
    final dateStr = DateFormat('EEEE d MMMM', 'ar').format(appointment.date);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          right: BorderSide(color: statusConfig.color, width: 4.w),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26.r,
                  backgroundColor: const Color(0xFF0D9488).withOpacity(0.05),
                  backgroundImage: appointment.doctorImage != null
                      ? NetworkImage(appointment.doctorImage!)
                      : null,
                  child: appointment.doctorImage == null
                      ? Icon(
                          Icons.person,
                          color: const Color(0xFF0D9488),
                          size: 28.r,
                        )
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        " ${appointment.doctorName}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                          fontFamily: 'Tajawal',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        appointment.type,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12.sp,
                          fontFamily: 'Tajawal',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14.sp,
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          "$dateStr • ${appointment.timeString}",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 11.sp,
                            fontFamily: 'Tajawal',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (appointment.status != 'cancelled')
                  TextButton(
                    onPressed: () => _showCancelDialog(context, appointment),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "إلغاء الحجز",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
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

  Widget _buildStatusBadge(_StatusConfig config) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 12.sp, color: config.color),
          SizedBox(width: 4.w),
          Text(
            config.text,
            style: TextStyle(
              color: config.color,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 70.r,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16.h),
          Text(
            "ليس لديك مواعيد حالياً",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16.sp,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 50.r,
              color: Colors.red[300],
            ),
            SizedBox(height: 10.h),
            Text(
              "خطأ: $message",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Tajawal', fontSize: 13.sp),
            ),
            TextButton(
              onPressed: () =>
                  context.read<PatientAppointmentsCubit>().getMyAppointments(),
              child: const Text("إعادة المحاولة"),
            ),
          ],
        ),
      ),
    );
  }

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

  void _showCancelDialog(BuildContext context, AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl, // تحديد الاتجاه داخل الحوار
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            "تأكيد الإلغاء",
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          content: Text(
            "هل أنت متأكد من إلغاء هذا الحجز؟",
            style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("تراجع"),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<PatientAppointmentsCubit>().cancelAppointment(
                  appointment.id,
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: const Text(
                "إلغاء الحجز",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
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
