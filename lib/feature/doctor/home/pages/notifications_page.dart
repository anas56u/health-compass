import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart'; // تأكد من وجود المكتبة أو استبدلها بـ TextStyle عادي
import 'package:health_compass/feature/doctor/requests/cubits/doctor_requests_cubit.dart';
import 'package:health_compass/feature/doctor/requests/cubits/doctor_requests_state.dart';
import 'package:health_compass/feature/doctor/requests/data/repo/doctor_requests_repo.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Stream<QuerySnapshot> _notificationsStream;

  @override
  void initState() {
    super.initState();
    _notificationsStream = DoctorRequestsRepo().getPendingRequests();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorRequestsCubit(DoctorRequestsRepo()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F9FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'الإشعارات',
            style: GoogleFonts.tajawal(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
         
        ),
        body: BlocListener<DoctorRequestsCubit, DoctorRequestsState>(
          listener: (context, state) {
            if (state is DoctorRequestsSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("تم تحديث حالة الطلب بنجاح"),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is DoctorRequestsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("خطأ: ${state.message}"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: StreamBuilder<QuerySnapshot>(
            stream: _notificationsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("حدث خطأ: ${snapshot.error}"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              final notifications = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final data = notifications[index].data() as Map<String, dynamic>;
                  final requestId = notifications[index].id;
                  
                  if (data['type'] == 'link_request') {
                    return _buildLinkRequestNotification(context, data, requestId);
                  }
                  
                  return const SizedBox(); 
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLinkRequestNotification(BuildContext context, Map<String, dynamic> data, String requestId) {
    final String patientName = data['patient_name'] ?? 'مريض جديد';
    final String patientId = data['patient_id'];
    
    String timeAgo = "الآن";
    if (data['created_at'] != null) {
      final Timestamp timestamp = data['created_at'];
      final diff = DateTime.now().difference(timestamp.toDate());
      if (diff.inMinutes < 60) {
        timeAgo = "منذ ${diff.inMinutes} دقيقة";
      } else if (diff.inHours < 24) {
        timeAgo = "منذ ${diff.inHours} ساعة";
      } else {
        timeAgo = "منذ ${diff.inDays} يوم";
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيقونة الإشعار
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_add_rounded, color: Color(0xFF0D9488)),
              ),
              const SizedBox(width: 12),
              // النصوص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "طلب ارتباط جديد",
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: GoogleFonts.tajawal(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.tajawal(color: Colors.grey[600], fontSize: 13),
                        children: [
                          const TextSpan(text: "يرغب المريض "),
                          TextSpan(
                            text: patientName,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const TextSpan(text: " بالارتباط بك لمتابعة حالته الصحية."),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // أزرار الإجراء السريع
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // رفض الطلب
                    context.read<DoctorRequestsCubit>().rejectPatient(requestId);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text("رفض"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // قبول الطلب
                    context.read<DoctorRequestsCubit>().acceptPatient(requestId, patientId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text("قبول الطلب"),
                ),
              ),
            ],
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
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "لا توجد إشعارات جديدة",
            style: GoogleFonts.tajawal(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}