import 'package:flutter/material.dart';
import 'package:health_compass/widgets/Metric_Item.dart';

Widget HealthStatusCard() {
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
                value: '88 bpm',
                label: 'نبضات القلب',
              ),

              MetricItem(
                icon: Icons.monitor_heart,
                iconColor: Colors.red.shade700,
                value: '115/72 mmHg',
                label: 'مستوى ضغط الدم',
              ),

              MetricItem(
                icon: Icons.opacity,
                iconColor: Colors.pink,
                value: '89 mg/dl',
                label: 'مستوى السكر في الدم',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
