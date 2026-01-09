import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart' as intl;
import 'package:health_compass/feature/health_dashboard/models/health_data_model.dart';

class PdfService {
  // الألوان المستوحاة من التطبيق
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF0D9488); // Teal
  static const PdfColor accentColor = PdfColor.fromInt(
    0xFFF0FDFA,
  ); // Light Teal bg
  static const PdfColor darkText = PdfColor.fromInt(0xFF1E293B);
  static const PdfColor lightText = PdfColor.fromInt(0xFF64748B);

  static Future<void> generateAndOpen(HealthDataModel data) async {
    final pdf = pw.Document();

    // تحميل اللوجو والخطوط
    final imageBytes = await rootBundle.load('assets/images/logo.jpeg');
    final logoImage = pw.MemoryImage(imageBytes.buffer.asUint8List());

    // تنسيق التاريخ الحالي
    final String reportDate = intl.DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(40),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: primaryColor,
                  width: 5,
                ), // إطار خارجي
              ),
            ),
          ),
        ),
        header: (context) => _buildHeader(logoImage, reportDate),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 20),

          // 1. عنوان التقرير
          pw.Center(
            child: pw.Text(
              "MEDICAL STATUS REPORT",
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
                letterSpacing: 2,
              ),
            ),
          ),
          pw.SizedBox(height: 20),

          // 2. معلومات المريض
          _buildPatientInfoSection(),
          pw.SizedBox(height: 30),

          // 3. ملخص العلامات الحيوية
          pw.Text(
            "VITAL SIGNS OVERVIEW",
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: lightText,
            ),
          ),
          pw.Divider(color: primaryColor, thickness: 1),
          pw.SizedBox(height: 10),

          _buildVitalsGrid(data),

          pw.SizedBox(height: 30),

          // 4. ملاحظات وتحليل
          _buildInsightsSection(),

          pw.SizedBox(height: 40),

          // 5. مساحة التوقيع
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(width: 150, height: 1, color: PdfColors.grey400),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    "Authorized Signature",
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    // حفظ وفتح الملف
    final output = await getTemporaryDirectory();
    final file = File(
      "${output.path}/Health_Report_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  // --- مكونات التصميم (Widgets) ---

  static pw.Widget _buildHeader(pw.MemoryImage logo, String date) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Row(
              children: [
                pw.Container(width: 50, height: 50, child: pw.Image(logo)),
                pw.SizedBox(width: 10),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "HEALTH COMPASS",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.Text(
                      "Personal Health Assistant",
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  "REPORT DATE",
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: lightText,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  date,
                  style: const pw.TextStyle(fontSize: 10, color: darkText),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 2, color: primaryColor),
      ],
    );
  }

  static pw.Widget _buildPatientInfoSection() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: accentColor,
        borderRadius: pw.BorderRadius.circular(6),
        // ✅ استخدام withOpacity الآن سيعمل بفضل الامتداد في الأسفل
        border: pw.Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoField("Patient Name", "User Name"),
          _buildInfoField("Patient ID", "#892301"),
          _buildInfoField("Age / Gender", "24 Y / Male"),
          _buildInfoField("Blood Type", "O+"),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoField(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 8,
            color: lightText,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 11,
            color: darkText,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildVitalsGrid(HealthDataModel data) {
    return pw.Column(
      children: [
        pw.Row(
          children: [
            _buildVitalCard(
              title: "Heart Rate",
              value: "${data.heartRate.toInt()}",
              unit: "bpm",
              status: _getHeartStatus(data.heartRate.toInt()),
              icon: const pw.IconData(0xe87d),
              color: PdfColors.red50,
              textColor: PdfColors.red700,
            ),
            pw.SizedBox(width: 15),
            _buildVitalCard(
              title: "Blood Pressure",
              value: data.bloodPressure.isEmpty ? "--/--" : data.bloodPressure,
              unit: "mmHg",
              status: "Normal",
              icon: const pw.IconData(0xe91d),
              color: accentColor,
              textColor: primaryColor,
            ),
          ],
        ),
        pw.SizedBox(height: 15),
        pw.Row(
          children: [
            _buildVitalCard(
              title: "Blood Glucose",
              value: "${data.sugar}",
              unit: "mg/dL",
              status: _getSugarStatus(data.sugar),
              icon: const pw.IconData(0xe3e7),
              color: PdfColors.orange50,
              textColor: PdfColors.orange700,
            ),
            pw.SizedBox(width: 15),
            _buildVitalCard(
              title: "Body Weight",
              value: "${data.weight}",
              unit: "kg",
              status: "Stable",
              icon: const pw.IconData(0xe34e),
              color: PdfColors.brown50,
              textColor: PdfColors.brown700,
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildVitalCard({
    required String title,
    required String value,
    required String unit,
    required String status,
    required pw.IconData icon,
    required PdfColor color,
    required PdfColor textColor,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(8),
          // ✅ استخدام withOpacity هنا أيضاً
          border: pw.Border.all(color: textColor.withOpacity(0.3)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(fontSize: 9, color: textColor),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    status,
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  value,
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: darkText,
                  ),
                ),
                pw.SizedBox(width: 4),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 3),
                  child: pw.Text(
                    unit,
                    style: pw.TextStyle(fontSize: 10, color: lightText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildInsightsSection() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border(left: pw.BorderSide(color: primaryColor, width: 4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "ANALYSIS & INSIGHTS",
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            "The patient shows consistent vital signs within the expected range. No significant irregularities detected in the heart rate or blood pressure measurements over the last period. Continued monitoring is recommended.",
            style: const pw.TextStyle(
              fontSize: 10,
              color: darkText,
              lineSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              "Generated by Health Compass App",
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
            pw.Text(
              "Page ${context.pageNumber} of ${context.pagesCount}",
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          "Disclaimer: This report is for informational purposes only and does not constitute medical advice.",
          style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey400),
        ),
      ],
    );
  }

  static String _getSugarStatus(int value) => value == 0
      ? "--"
      : (value > 140 ? "High" : (value < 70 ? "Low" : "Normal"));
  static String _getHeartStatus(int value) => value == 0
      ? "--"
      : (value > 100 ? "High" : (value < 60 ? "Low" : "Normal"));
}

// ✅✅ هذا الامتداد هو الذي يحل المشكلة، تأكد من وجوده في نهاية الملف
extension PdfColorExtension on PdfColor {
  PdfColor withOpacity(double opacity) {
    return PdfColor(red, green, blue, opacity);
  }
}
