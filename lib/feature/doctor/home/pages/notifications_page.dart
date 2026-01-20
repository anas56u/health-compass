import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/feature/auth/data/model/PatientModel.dart';
import 'package:health_compass/feature/doctor/requests/cubits/doctor_requests_cubit.dart';
import 'package:health_compass/feature/doctor/requests/cubits/doctor_requests_state.dart';
import 'package:health_compass/feature/doctor/requests/data/repo/doctor_requests_repo.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // اللون الأساسي للتطبيق
    const primaryColor = Color(0xFF0D9488);

    return BlocProvider(
      create: (context) => DoctorRequestsCubit(DoctorRequestsRepo()),
      child: Scaffold(
        // خلفية فاتحة جداً لإبراز الكروت
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            "طلبات الارتباط",
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: BlocConsumer<DoctorRequestsCubit, DoctorRequestsState>(
          listener: (context, state) {
            if (state is DoctorRequestsSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.white),
                      SizedBox(width: 8),
                      Text('تم تنفيذ الإجراء بنجاح'),
                    ],
                  ),
                  backgroundColor: primaryColor.withOpacity(0.9),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            } else if (state is DoctorRequestsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            return StreamBuilder<QuerySnapshot>(
              stream: DoctorRequestsRepo().getPendingRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: primaryColor));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final requests = snapshot.data!.docs;

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: requests.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final requestDoc = requests[index];
                    final requestData = requestDoc.data() as Map<String, dynamic>;
                    
                    return _RequestCard(
                      requestId: requestDoc.id,
                      patientId: requestData['patient_id'] ?? requestData['uid'],
                      requestDate: requestData['created_at'],
                      primaryColor: primaryColor,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            "لا توجد طلبات جديدة",
            style: TextStyle(color: Colors.grey[700], fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            "ستظهر طلبات ارتباط المرضى هنا",
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// --- ويدجت الكرت المحسن ---
// --- ويدجت الكرت المحسن (نسخة بدون Overflow) ---
class _RequestCard extends StatelessWidget {
  final String requestId;
  final String patientId;
  final dynamic requestDate;
  final Color primaryColor;

  const _RequestCard({
    required this.requestId,
    required this.patientId,
    required this.requestDate,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(patientId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // كرت تحميل مؤقت
          return Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(child: CircularProgressIndicator(color: primaryColor.withOpacity(0.5))),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        // حماية ضد البيانات الناقصة
        if (userData.isEmpty) return const SizedBox(); 
        
        final patient = PatientModel.fromMap(userData);
        
        String timeAgo = 'الآن';
        if (requestDate != null) {
          final date = (requestDate as Timestamp).toDate();
          timeAgo = DateFormat('dd MMM, hh:mm a').format(date); 
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // الجزء العلوي: المعلومات
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. صورة المريض
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryColor.withOpacity(0.2), width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        backgroundImage: (patient.profileImage != null && patient.profileImage!.isNotEmpty)
                            ? NetworkImage(patient.profileImage!)
                            : null,
                        child: (patient.profileImage == null || patient.profileImage!.isEmpty)
                            ? Icon(Icons.person_rounded, color: primaryColor, size: 32)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // 2. تفاصيل المريض (الاسم والأمراض)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // سطر الاسم والتاريخ
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  patient.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16, // تصغير الخط قليلاً لتفادي المشاكل
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // التاريخ
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  timeAgo,
                                  style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // قسم الأمراض (الحل الجذري للـ Overflow هنا)
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildDiseaseChip(
                                label: patient.diseaseType,
                                color: primaryColor,
                                icon: Icons.medical_services_outlined,
                                isPrimary: true,
                              ),
                              
                              if (patient.hasOtherIssues && patient.specificDisease != null)
                                _buildDiseaseChip(
                                  label: patient.specificDisease!,
                                  color: Colors.orange[700]!,
                                  icon: Icons.warning_amber_rounded,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),

              // الجزء السفلي: الأزرار
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // زر الرفض
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<DoctorRequestsCubit>().rejectPatient(requestId);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close_rounded, size: 18),
                            SizedBox(width: 4),
                            Text("رفض", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // زر القبول
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<DoctorRequestsCubit>().acceptPatient(requestId, patientId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_rounded, size: 18),
                            SizedBox(width: 4),
                            Text("قبول", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // دالة رسم كبسولة المرض (مع حماية النص الطويل)
  Widget _buildDiseaseChip({
    required String label,
    required Color color,
    required IconData icon,
    bool isPrimary = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(isPrimary ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      // هذا القيد يمنع الكبسولة من أن تصبح عريضة جداً وتخرج عن الشاشة
      constraints: const BoxConstraints(maxWidth: 160), 
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          // Flexible + Ellipsis: الحل السحري للنصوص الطويلة
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

}