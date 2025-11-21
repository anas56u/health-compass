import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/cubits/health_cubit/HealthState.dart';
import '../../cubits/health_cubit/health_cubit.dart'; 
import 'package:health_compass/widgets/Metric_Item.dart';

class HealthStatusCard extends StatelessWidget {
  const HealthStatusCard({super.key});

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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.green.shade400, width: 1),
                        ),
                        child: Text(
                          'جيده',
                          style: TextStyle(
                            color: Colors.green.shade700,
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
                        value: '${state.systolic}/${state.diastolic} mmHg',
                        label: 'مستوى ضغط الدم',
                      ),
                      MetricItem(
                        icon: Icons.opacity,
                        iconColor: Colors.pink,
                        value: '${state.bloodGlucose.toStringAsFixed(1)} mg/dl',
                        label: 'مستوى السكر في الدم',
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