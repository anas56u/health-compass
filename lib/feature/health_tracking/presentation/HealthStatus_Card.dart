import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/core/cache/shared_pref_helper.dart';
import 'package:health_compass/core/models/vital_model.dart';
import 'package:health_compass/feature/health_tracking/presentation/cubits/health_cubit/HealthState.dart';
import 'cubits/health_cubit/health_cubit.dart';
import 'package:health_compass/feature/health_tracking/presentation/Metric_Item.dart';
import 'package:health_compass/feature/family_member/logic/family_cubit.dart';
import 'package:health_compass/feature/family_member/logic/family_state.dart';

class HealthStatusCard extends StatefulWidget {
  const HealthStatusCard({super.key});

  @override
  State<HealthStatusCard> createState() => _HealthStatusCardState();
}

class _HealthStatusCardState extends State<HealthStatusCard> {
  @override
  void initState() {
    super.initState();
    // ✅ تحميل القيمة الأولية من الذاكرة لتحديث النوتيفاير
    SharedPrefHelper.getHealthSource();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ التعديل الجوهري هنا:
    // نستخدم ValueListenableBuilder للاستماع لأي تغيير في المصدر
    // هذا يوفر لنا المتغير isWatchSource بشكل تلقائي ومحدث
    return ValueListenableBuilder<bool>(
      valueListenable: SharedPrefHelper.healthSourceNotifier,
      builder: (context, isWatchSource, child) {
        // الآن المتغير isWatchSource أصبح معرفاً ومتاحاً هنا
        if (isWatchSource) {
          return _buildWatchSourceView();
        } else {
          return _buildManualSourceView();
        }
      },
    );
  }

  // ==========================================
  // ⌚ جزء الساعة الذكية
  // ==========================================
  Widget _buildWatchSourceView() {
    return BlocBuilder<HealthCubit, HealthState>(
      builder: (context, state) {
        if (state is HealthLoading || state is HealthInitial) {
          return _buildLoadingCard();
        }

        if (state is HealthConnectNotInstalled) {
          return _buildErrorCard(
            context,
            "لقراءة بيانات ساعتك، يجب تثبيت تطبيق 'Health Connect' من جوجل.",
            actionButton: ElevatedButton(
              onPressed: () => context.read<HealthCubit>().installHealthConnect(),
              child: const Text("تثبيت الآن"),
            ),
          );
        }

        if (state is HealthError) {
          return _buildErrorCard(context, "حدث خطأ: ${state.message}");
        }

        if (state is HealthLoaded) {
          return _buildCardUI(
            hr: state.heartRate,
            sys: state.systolic,
            dia: state.diastolic,
            glu: state.bloodGlucose,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ==========================================
  // 📝 جزء القراءة اليدوية
  // ==========================================
  Widget _buildManualSourceView() {
    return BlocBuilder<FamilyCubit, FamilyState>(
      builder: (context, state) {
        if (state is FamilyLoading) {
          return _buildLoadingCard();
        }

        // في حالة الخطأ، نعرض رسالة خطأ، إلا إذا كان الخطأ هو "لا يوجد مرضى" وكان المستخدم جديداً
        if (state is FamilyError) {
           // تحسين بسيط: لو أردت يمكنك عرض كارد فارغ بدلاً من الخطأ في بعض الحالات
           return _buildErrorCard(context, "لم يتم العثور على بيانات يدوية");
        }

        if (state is FamilyDashboardLoaded) {
          // 1. تعريف المتغيرات الافتراضية
          double hr = 0;
          int sys = 0;
          int dia = 0;
          double glu = 0;

          // 2. دالة لاستخراج البيانات (Best Practice: نقل المنطق المعقد خارج الـ UI المباشر)
          VitalModel? getLatestVital(List<String> keywords) {
            try {
              if (state.currentVitals.isEmpty) return null;
              
              final relatedVitals = state.currentVitals.where((v) {
                final type = v.type.toLowerCase();
                return keywords.any((k) => type.contains(k));
              }).toList();

              if (relatedVitals.isEmpty) return null;

              relatedVitals.sort((a, b) => b.date.compareTo(a.date));
              return relatedVitals.first;
            } catch (e) {
              return null;
            }
          }

          // 3. استخراج البيانات
          final sugarVital = getLatestVital(['sugar', 'glucose', 'سكر']);
          if (sugarVital != null) {
            glu = double.tryParse(sugarVital.value) ?? 0;
          }

          final pressureVital = getLatestVital(['pressure', 'bp', 'ضغط']);
          if (pressureVital != null) {
            final parts = pressureVital.value.split('/');
            if (parts.length == 2) {
              sys = int.tryParse(parts[0]) ?? 0;
              dia = int.tryParse(parts[1]) ?? 0;
            }
          }

          final heartVital = getLatestVital(['heart', 'pulse', 'rate', 'نبض']);
          if (heartVital != null) {
            hr = double.tryParse(heartVital.value) ?? 0;
          }

          return _buildCardUI(
            hr: hr,
            sys: sys,
            dia: dia,
            glu: glu,
          );
        }

        // حالة افتراضية (مثلاً لم يتم اختيار مريض بعد)
        return _buildCardUI(hr: 0, sys: 0, dia: 0, glu: 0);
      },
    );
  }

  // ==========================================
  // 🎨 واجهة المستخدم الموحدة (Reusable UI)
  // ==========================================
  Widget _buildCardUI({
    required double hr,
    required int sys,
    required int dia,
    required double glu,
  }) {
    final statusInfo = _getHealthStatus(hr, sys, dia, glu);

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
                // الحالة (خطر/جيد)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusInfo.backgroundColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: statusInfo.borderColor, width: 1),
                  ),
                  child: Text(
                    statusInfo.label,
                    style: TextStyle(
                      color: statusInfo.textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // العنوان
                const Text(
                  'الحالة الصحية الأخيرة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // عرض الأرقام
            Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MetricItem(
                  icon: Icons.favorite,
                  iconColor: Colors.red,
                  value: hr > 0 ? '${hr.toStringAsFixed(0)} bpm' : '--',
                  label: 'نبضات القلب',
                ),
                MetricItem(
                  icon: Icons.monitor_heart,
                  iconColor: Colors.red.shade700,
                  value: sys > 0 ? '$sys/$dia mmHg' : '--',
                  label: 'ضغط الدم',
                ),
                MetricItem(
                  icon: Icons.opacity,
                  iconColor: Colors.pink,
                  value: glu > 0 ? '${glu.toStringAsFixed(0)} mg/dl' : '--',
                  label: 'مستوى السكر',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ الويدجتس المساعدة (Loading / Error)
  Widget _buildLoadingCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message, {Widget? actionButton}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.red.shade50,
      child: SizedBox(
        height: 180,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade900),
                ),
                if (actionButton != null) ...[
                  const SizedBox(height: 15),
                  actionButton,
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🧠 منطق تقييم الحالة الصحية
  HealthStatusInfo _getHealthStatus(double hr, int sys, int dia, double glu) {
    if (hr == 0 && sys == 0 && glu == 0) {
      return HealthStatusInfo(
        label: "لا توجد بيانات",
        backgroundColor: Colors.grey.shade100,
        textColor: Colors.grey.shade700,
        borderColor: Colors.grey.shade400,
      );
    }

    // 1. خطر
    if ((hr > 120 || (hr < 40 && hr > 0)) || 
        (sys > 160 || (sys < 90 && sys > 0)) || 
        (glu > 250 || (glu < 60 && glu > 0))) {
      return HealthStatusInfo(
        label: "خطر",
        backgroundColor: Colors.red.shade100,
        textColor: Colors.red.shade900,
        borderColor: Colors.red.shade400,
      );
    }

    // 2. انتبه
    if ((hr > 100 || (hr < 60 && hr > 0)) || 
        (sys > 130 || (sys < 100 && sys > 0)) || 
        (glu > 180 || (glu < 70 && glu > 0))) {
      return HealthStatusInfo(
        label: "انتبه",
        backgroundColor: Colors.orange.shade100,
        textColor: Colors.orange.shade900,
        borderColor: Colors.orange.shade400,
      );
    }

    // 3. جيدة
    return HealthStatusInfo(
      label: "جيدة",
      backgroundColor: Colors.green.shade100,
      textColor: Colors.green.shade700,
      borderColor: Colors.green.shade400,
    );
  }
}

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