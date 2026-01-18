import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/feature/health_tracking/presentation/cubits/health_cubit/HealthState.dart';
import 'cubits/health_cubit/health_cubit.dart';
import 'package:health_compass/feature/health_tracking/presentation/Metric_Item.dart';

class HealthStatusCard extends StatelessWidget {
  const HealthStatusCard({super.key});

  // ✅ دالة لتقييم الحالة الصحية وتحديد اللون والنص
  // هذه الدالة تقارن القيم وتعيد كائن يحتوي على النص والألوان المناسبة
  HealthStatusInfo _getHealthStatus(double hr, int sys, int dia, double glu) {
    // 1. حالة الخطر (Critical) - قيم غير منطقية أو خطيرة جداً
    if ((hr > 120 || hr < 40 && hr > 0) || 
        (sys > 160 || sys < 90 && sys > 0) || 
        (glu > 250 || glu < 60 && glu > 0)) {
      return HealthStatusInfo(
        label: "خطر",
        backgroundColor: Colors.red.shade100,
        textColor: Colors.red.shade900,
        borderColor: Colors.red.shade400,
      );
    }

    // 2. حالة التنبيه (Warning) - قيم مرتفعة قليلاً أو منخفضة
    if ((hr > 100 || hr < 60 && hr > 0) || 
        (sys > 130 || sys < 100 && sys > 0) || 
        (glu > 180 || glu < 70 && glu > 0)) {
      return HealthStatusInfo(
        label: "انتبه",
        backgroundColor: Colors.orange.shade100,
        textColor: Colors.orange.shade900,
        borderColor: Colors.orange.shade400,
      );
    }

    // 3. الحالة الطبيعية (Normal)
    return HealthStatusInfo(
      label: "جيدة",
      backgroundColor: Colors.green.shade100,
      textColor: Colors.green.shade700,
      borderColor: Colors.green.shade400,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HealthCubit, HealthState>(
      builder: (context, state) {
        
        if (state is HealthLoading || state is HealthInitial) {
          return Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: const SizedBox(
              height: 180,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (state is HealthConnectNotInstalled) {
          return Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.amber.shade100,
            child: SizedBox(
              height: 180,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "لقراءة بيانات ساعتك، يجب تثبيت تطبيق 'Health Connect' من جوجل.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.amber.shade900),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          context.read<HealthCubit>().installHealthConnect();
                        },
                        child: const Text("تثبيت الآن"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        if (state is HealthError) {
          return Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.red.shade100,
            child: SizedBox(
              height: 180,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "حدث خطأ: ${state.message}",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              ),
            ),
          );
        }

        if (state is HealthLoaded) {
          // ✅ استدعاء دالة التقييم هنا
          final statusInfo = _getHealthStatus(
            state.heartRate,
            state.systolic,
            state.diastolic ,
            state.bloodGlucose,
          );

          return Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ✅ استخدام القيم الديناميكية من دالة التقييم
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusInfo.backgroundColor, // لون الخلفية المتغير
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: statusInfo.borderColor, width: 1), // لون الحدود المتغير
                        ),
                        child: Text(
                          statusInfo.label, // النص المتغير (جيدة/انتبه/خطر)
                          style: TextStyle(
                            color: statusInfo.textColor, // لون النص المتغير
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(
                        'الحالة الصحية اليوم',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      MetricItem(
                        icon: Icons.favorite,
                        iconColor: Colors.red,
                        value: '${state.heartRate.toStringAsFixed(0)} bpm',
                        label: 'نبضات القلب',
                      ),
                      MetricItem(
                        icon: Icons.monitor_heart,
                        iconColor: Colors.red.shade700,
                        value: '${state.systolic.toInt()}/${state.diastolic.toInt()} mmHg',
                        label: 'مستوى ضغط الدم',
                      ),
                      MetricItem(
                        icon: Icons.opacity,
                        iconColor: Colors.pink,
                        value: '${state.bloodGlucose.toStringAsFixed(0)} mg/dl',
                        label: 'مستوى السكر',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ✅ كلاس مساعد صغير لتنظيم بيانات الحالة (يمكن وضعه في نفس الملف أو ملف منفصل)
class HealthStatusInfo {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  HealthStatusInfo({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });
}