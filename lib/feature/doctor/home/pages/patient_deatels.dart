import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' as intl;
import 'package:health_compass/feature/auth/data/model/PatientModel.dart';
import 'package:health_compass/feature/health_dashboard/models/health_data_model.dart';

class PatientDetailsScreen extends StatefulWidget {
  final PatientModel patient;

  const PatientDetailsScreen({super.key, required this.patient});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  int _selectedChartIndex = 0; // 0: سكر، 1: ضغط، 2: قلب
  final Color _primaryColor = const Color(0xFF0D9488);
  final Color _accentColor = const Color(0xFF14B8A6);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9), // خلفية رمادية فاتحة جداً
        appBar: AppBar(
          title: Text("الملف الصحي للمريض", 
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18)),
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.patient.uid)
              .collection('health_readings')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: _primaryColor));
            }

            List<HealthDataModel> history = snapshot.data?.docs
                    .map((doc) => HealthDataModel.fromMap(doc.data() as Map<String, dynamic>))
                    .toList() ?? [];

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientHeader(),
                  const SizedBox(height: 25),
                  _buildChartSection(history),
                  const SizedBox(height: 25),
                  _buildSectionTitle("المعلومات الطبية", Icons.assignment_outlined),
                  _buildMedicalInfoCard(),
                  const SizedBox(height: 25),
                  _buildSectionTitle("السجلات الأخيرة", Icons.history_rounded),
                  _buildRecentRecordsList(history),  
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_primaryColor, _accentColor]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: _primaryColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: Colors.grey[200],
              backgroundImage: (widget.patient.profileImage?.isNotEmpty ?? false)
                  ? NetworkImage(widget.patient.profileImage!)
                  : null,
              child: (widget.patient.profileImage?.isEmpty ?? true)
                  ? Icon(Icons.person, size: 40, color: _primaryColor)
                  : null,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.patient.fullName, 
                  style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: Text(widget.patient.diseaseType, 
                    style: GoogleFonts.cairo(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(List<HealthDataModel> history) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildChartTab("السكري", 0, Colors.orange),
                _buildChartTab("الضغط", 1, _primaryColor),
                _buildChartTab("القلب", 2, Colors.redAccent),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 20),
          if (history.isNotEmpty) 
            SizedBox(height: 240, child: _buildInteractiveChart(history))
          else 
            _buildEmptyState("لا توجد قراءات كافية للرسم البياني"),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildInteractiveChart(List<HealthDataModel> history) {
    List<FlSpot> spots = [];
    var displayData = history.take(7).toList().reversed.toList();
    
    for (int i = 0; i < displayData.length; i++) {
      double val = 0;
      if (_selectedChartIndex == 0) val = displayData[i].sugar.toDouble();
      else if (_selectedChartIndex == 1) val = displayData[i].systolic.toDouble();
      else if (_selectedChartIndex == 2) val = displayData[i].heartRate;
      
      if (val > 0) spots.add(FlSpot(i.toDouble(), val));
    }

    Color chartColor = _selectedChartIndex == 0 ? Colors.orange : (_selectedChartIndex == 1 ? _primaryColor : Colors.redAccent);

    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 10, bottom: 10),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true, 
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, 
                reservedSize: 35,
                getTitlesWidget: (value, meta) => Text(value.toInt().toString(), 
                  style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int idx = value.toInt();
                  if (idx < 0 || idx >= displayData.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(intl.DateFormat('MM/dd').format(displayData[idx].date), 
                      style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
preventCurveOverShooting: true, 
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: chartColor)),
              belowBarData: BarAreaData(
                show: true, 
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [chartColor.withOpacity(0.3), chartColor.withOpacity(0)],
                )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTab(String title, int index, Color color) {
    bool isSelected = _selectedChartIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedChartIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: MediaQuery.of(context).size.width * 0.25,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? color : Colors.grey.shade200),
        ),
        child: Text(title, 
          style: GoogleFonts.cairo(color: isSelected ? Colors.white : Colors.grey[600], 
          fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMedicalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.calendar_today_rounded, "سنة التشخيص", widget.patient.diagnosisYear ?? "غير محدد"),
          _buildDivider(),
          _buildInfoRow(Icons.medication_rounded, "يتناول أدوية حالياً", widget.patient.isTakingMeds ? "نعم" : "لا"),
          _buildDivider(),
          _buildInfoRow(Icons.report_problem_outlined, "مشاكل صحية أخرى", 
            widget.patient.hasOtherIssues ? (widget.patient.specificDisease ?? "موجود") : "لا يوجد"),
        ],
      ),
    );
  }

  Widget _buildRecentRecordsList(List<HealthDataModel> history) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length > 10?10 : history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 5)],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: _primaryColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(_getIconForRecord(item), color: _primaryColor, size: 22),
            ),
            title: Text(_getValueText(item), style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(intl.DateFormat('yyyy/MM/dd | hh:mm a').format(item.date), 
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
            trailing: _buildStatusChip(item),
          ),
        );
      },
    );
  }

  // --- Helper Methods ---

  Widget _buildSectionTitle(String title, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 12, right: 5),
    child: Row(
      children: [
        Icon(icon, size: 20, color: _primaryColor),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    ),
  );

  Widget _buildInfoRow(IconData icon, String label, String value) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: _primaryColor.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 20, color: _primaryColor),
      ),
      const SizedBox(width: 15),
      Text(label, style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600])),
      const Spacer(),
      Text(value, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
    ],
  );

  Widget _buildDivider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Divider(color: Colors.grey.shade100, thickness: 1),
  );

  Widget _buildStatusChip(HealthDataModel item) {
    // منطق بسيط لتحديد اللون (يمكنك تحسينه حسب المعايير الطبية)
    bool isNormal = true;
    if (item.sugar > 140 || item.systolic > 140 || item.heartRate > 100) isNormal = false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isNormal ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(isNormal ? "طبيعي" : "تنبيه", 
        style: GoogleFonts.cairo(color: isNormal ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  IconData _getIconForRecord(HealthDataModel item) {
    if (item.sugar > 0) return Icons.bloodtype_rounded;
    if (item.systolic > 0) return Icons.monitor_heart_rounded;
    return Icons.favorite_rounded;
  }

  String _getValueText(HealthDataModel item) {
    if (item.sugar > 0) return "مستوى السكر: ${item.sugar}";
    if (item.systolic > 0) return "ضغط الدم: ${item.bloodPressure}";
    return "نبض القلب: ${item.heartRate.toInt()}";
  }

  Widget _buildEmptyState(String msg) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.analytics_outlined, size: 40, color: Colors.grey[300]),
        const SizedBox(height: 10),
        Text(msg, style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
      ],
    ),
  );
}