import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/widgets/Taskitem_buider.dart';
import 'package:health_compass/widgets/HealthStatus_Card.dart';
import 'package:health_compass/widgets/custom_text.dart';
import 'package:health_compass/widgets/daily_tasks.dart';
import 'package:health_compass/widgets/header_patientview.dart';

class Patientview_body extends StatelessWidget {
  const Patientview_body({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [header_patientview(), SizedBox(height: 20), DailyTasks()],
        ),
      ),
    );
  }
}
