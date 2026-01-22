import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/feature/auth/presentation/cubit/cubit/user_cubit.dart';
import 'package:health_compass/feature/doctor/requests/cubits/DoctorHomeCubit.dart';
import 'package:health_compass/feature/doctor/requests/cubits/DoctorHomeState.dart';
import '../widgets/doctor_header.dart';
import '../widgets/doctor_stats_card.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserCubit>().getUserData();
    });
  }

  // دالة الحالة الفارغة
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Center(
        child: Text(
          "لا يوجد مرضى لديهم أمراض أخرى حالياً",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorHomeCubit()..getDashboardData(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const DoctorHeader(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: BlocBuilder<DoctorHomeCubit, DoctorHomeState>(
                  builder: (context, state) {
                    if (state is DoctorHomeLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(50.0),
                          child: CircularProgressIndicator(
                            color: Color(0xFF0D9488),
                          ),
                        ),
                      );
                    }

                    if (state is DoctorHomeFailure) {
                      return Center(
                        child: Text("حدث خطأ: ${state.errorMessage}"),
                      );
                    }

                    if (state is DoctorHomeSuccess) {
                      // 1. فلترة القائمة لعرض المرضى الذين لديهم أمراض أخرى فقط
                      final patientsWithIssues = state.recentPatients
                          .where((p) => p['has_issues'] == true)
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // كرت الإحصائيات (العدد الكلي للمرضى)
                          Row(
                            children: [
                              Expanded(
                                child: DoctorStatsCard(
                                  icon: Icons.people_outline,
                                  title: 'عدد المرضى',
                                  value: state.stats.totalPatients.toString(),
                                  color: const Color(0xFF0D9488),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // العنوان الجديد
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'المرضى الذين لديهم أمراض أخرى',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // القائمة الجديدة (مخصصة ومكبرة)
                          SizedBox(
                            height: 180, // زدنا الارتفاع لاستيعاب الكرت الأكبر
                            child: patientsWithIssues.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    reverse: true,
                                    itemCount: patientsWithIssues.length,
                                    itemBuilder: (context, index) {
                                      final patient = patientsWithIssues[index];
                                      final String name =
                                          patient['name'] ?? 'بدون اسم';
                                      final String? image = patient['image'];
                                      // جلبنا اسم المرض الآخر هنا
                                      final String specificDisease =
                                          patient['specific_disease'] ??
                                          'غير محدد';

                                      return Container(
                                        width: 160, // زدنا العرض (كان 110)
                                        margin: const EdgeInsets.only(left: 12),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ), // زوايا أنعم
                                          border: Border.all(
                                            color: Colors.grey.withOpacity(0.1),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                0.08,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // الصورة (بدون نقطة خضراء)
                                            CircleAvatar(
                                              radius: 35, // كبرنا الصورة قليلاً
                                              backgroundColor: const Color(
                                                0xFF0D9488,
                                              ).withOpacity(0.1),
                                              backgroundImage:
                                                  (image != null &&
                                                      image.isNotEmpty)
                                                  ? NetworkImage(image)
                                                  : null,
                                              child:
                                                  (image == null ||
                                                      image.isEmpty)
                                                  ? Text(
                                                      name.isNotEmpty
                                                          ? name[0]
                                                                .toUpperCase()
                                                          : '?',
                                                      style: const TextStyle(
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(
                                                          0xFF0D9488,
                                                        ),
                                                      ),
                                                    )
                                                  : null,
                                            ),

                                            const SizedBox(height: 12),

                                            // الاسم
                                            Text(
                                              name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14, // كبرنا الخط
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),

                                            const SizedBox(height: 6),

                                            // نوع المرض الآخر
                                            Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.orange
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                specificDisease,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.orange[800],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 50),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
