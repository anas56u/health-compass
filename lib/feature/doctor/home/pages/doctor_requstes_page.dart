import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/feature/doctor/requests/cubits/doctor_requests_cubit.dart';
import 'package:health_compass/feature/doctor/requests/cubits/doctor_requests_state.dart';
import 'package:health_compass/feature/doctor/requests/data/repo/doctor_requests_repo.dart';

class DoctorRequestsPage extends StatelessWidget {
  const DoctorRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorRequestsCubit(DoctorRequestsRepo()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F9FC),
        appBar: AppBar(
          title: const Text("طلبات الارتباط الجديدة"),
          backgroundColor: const Color(0xFF0D9488),
          foregroundColor: Colors.white,
        ),
        body: BlocListener<DoctorRequestsCubit, DoctorRequestsState>(
          listener: (context, state) {
            if (state is DoctorRequestsSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("تم تنفيذ العملية بنجاح"), backgroundColor: Colors.green),
              );
            } else if (state is DoctorRequestsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("خطأ: ${state.message}"), backgroundColor: Colors.red),
              );
            }
          },
          child: StreamBuilder<QuerySnapshot>(
            stream: DoctorRequestsRepo().getPendingRequests(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              final requests = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index].data() as Map<String, dynamic>;
                  final requestId = requests[index].id;
                  
                  return _buildRequestCard(context, request, requestId);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> request, String requestId) {
    final String patientName = request['patient_name'] ?? 'مريض غير معروف';
    final String patientId = request['patient_id'];
    
    final Timestamp? timestamp = request['created_at'];
    final String dateStr = timestamp != null 
        ? "${timestamp.toDate().day}/${timestamp.toDate().month} - ${timestamp.toDate().hour}:${timestamp.toDate().minute}" 
        : "";

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE0F2F1),
                  child: Icon(Icons.person, color: Color(0xFF0D9488)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        "يرغب بالارتباط بك لمتابعة حالته",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      if(dateStr.isNotEmpty)
                        Text(dateStr, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<DoctorRequestsCubit>().rejectPatient(requestId);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("رفض"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<DoctorRequestsCubit>().acceptPatient(requestId, patientId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("قبول"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "لا توجد طلبات جديدة",
            style: TextStyle(color: Colors.grey[500], fontSize: 18),
          ),
        ],
      ),
    );
  }
}