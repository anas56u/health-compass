import 'dart:io';
import 'package:flutter/services.dart';
import 'package:health_compass/feature/health_dashboard/models/health_data_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart' as intl;
import 'package:arabic_reshaper/arabic_reshaper.dart';

class PdfService {
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF0D9488);
  static final ArabicReshaper _reshaper = ArabicReshaper();

  // ✅ دالة معالجة النصوص العربية لضمان ظهورها بشكل صحيح في الـ PDF
  static String _fixArabic(String text) {
    if (text.isEmpty) return "";
    // إذا كان النص يحتوي على حروف عربية، نقوم بإعادة تشكيله وعكسه للمكتبة
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(text)) {
      String reshaped = _reshaper.reshape(text);
      return reshaped.split('').reversed.join();
    }
    return text;
  }

  static Future<void> generateMedicalReport(
    HealthDataModel data,
    String userName, // ✅ استلام اسم المستخدم الممرر من الـ Dashboard
  ) async {
    final pdf = pw.Document();

    // تحميل خط يدعم العربية (تأكد من وجود الملف في Assets)
    final fontData = await rootBundle.load('assets/Fonts/Cairo-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ترويسة التقرير
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "MEDICAL REPORT",
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.Text(
                    intl.DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.Divider(thickness: 1.5, color: primaryColor),
              pw.SizedBox(height: 15),

              // ✅ عرض اسم المريض (userName) المعالج عربياً
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Patient Name:",
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          _fixArabic(userName), // ✅ هنا يتم عرض الاسم
                          style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      "ID: #HC-2026",
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // جدول البيانات الحيوية
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: primaryColor),
                    children: [
                      _cell("Parameter", isHeader: true),
                      _cell("Result", isHeader: true),
                      _cell("Unit", isHeader: true),
                    ],
                  ),
                  _row("Heart Rate", "${data.heartRate}", "BPM"),
                  _row(
                    "Blood Pressure",
                    "${data.systolic}/${data.diastolic}",
                    "mmHg",
                  ),
                  _row("Sugar Level", "${data.sugar}", "mg/dL"),
                  _row("Body Weight", "${data.weight}", "kg"),
                ],
              ),

              pw.Spacer(),
              pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              pw.Center(
                child: pw.Text(
                  _fixArabic(
                    "هذا التقرير صادر إلكترونياً من تطبيق بوصلة الصحة",
                  ),
                  style: const pw.TextStyle(
                    fontSize: 7,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // عملية الحفظ والفتح
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      "${dir.path}/Medical_Report_${userName.replaceAll(' ', '_')}.pdf",
    );
    await file.writeAsBytes(await pdf.save());

    // فتح الملف تلقائياً بعد الحفظ
    await OpenFile.open(file.path);
  }

  static pw.Widget _cell(String text, {bool isHeader = false}) => pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Center(
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: isHeader ? PdfColors.white : PdfColors.black,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: 9,
        ),
      ),
    ),
  );

  static pw.TableRow _row(String label, String value, String unit) =>
      pw.TableRow(children: [_cell(label), _cell(value), _cell(unit)]);
}
