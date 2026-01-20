import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/feature/family_member/logic/family_cubit.dart';
import 'package:health_compass/feature/family_member/logic/family_state.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class LinkPatientScreen extends StatefulWidget {
  const LinkPatientScreen({super.key});

  @override
  State<LinkPatientScreen> createState() => _LinkPatientScreenState();
}

class _LinkPatientScreenState extends State<LinkPatientScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _codeController = TextEditingController();
  final Color primaryColor = const Color(0xFF41BFAA);

  // ✅ 1. تعريف وحدة التحكم بالكاميرا
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed:
        DetectionSpeed.noDuplicates, // لمنع القراءة المتكررة السريعة
  );

  bool isScanning = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // ✅ 2. تنظيف الكنترولر عند الخروج
    _cameraController.dispose();
    _tabController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  // ✅ دالة التقاط الكود من الكاميرا
  void _onQRDetect(BarcodeCapture capture) {
    if (!isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => isScanning = false);

        // ✅ 3. إيقاف الكاميرا برمجياً بدلاً من استخدام disabled
        _cameraController.stop();

        _submitCode(barcode.rawValue!);
        break;
      }
    }
  }

  void _submitCode(String code) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<FamilyCubit>().linkPatient(user.uid, code.toUpperCase());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FamilyCubit, FamilyState>(
      listener: (context, state) {
        if (state is FamilyLinkSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ تم ربط المريض بنجاح!")),
          );
          Navigator.pop(context); // العودة للشاشة الرئيسية
        } else if (state is FamilyError) {
          // ✅ 4. في حالة الخطأ، نعيد تشغيل الكاميرا
          setState(() => isScanning = true);
          _cameraController.start();

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("❌ ${state.message}")));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "ربط مريض جديد",
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            labelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
            indicatorColor: primaryColor,
            labelColor: primaryColor,
            tabs: const [
              Tab(text: "مسح QR Code", icon: Icon(Icons.qr_code_scanner)),
              Tab(text: "إدخال يدوي", icon: Icon(Icons.keyboard)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // --- تبويب 1: الماسح الضوئي ---
            Stack(
              children: [
                MobileScanner(
                  // ✅ ربط الكنترولر هنا
                  controller: _cameraController,
                  onDetect: _onQRDetect,
                  // ❌ تم حذف الخاصية disabled لأنها غير موجودة
                ),
                // تصميم الإطار المربع في المنتصف
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor, width: 3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                // نص توجيهي
                Positioned(
                  bottom: 80,
                  left: 0,
                  right: 0,
                  child: Text(
                    "وجه الكاميرا نحو كود المريض",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        const Shadow(blurRadius: 10, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // --- تبويب 2: الإدخال اليدوي ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "أدخل كود الربط المكون من 6 خانات",
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _codeController,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 5),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                      UpperCaseTextFormatter(),
                    ],
                    decoration: InputDecoration(
                      hintText: "ADF123",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      counterText: "",
                    ),
                  ),
                  const SizedBox(height: 30),
                  BlocBuilder<FamilyCubit, FamilyState>(
                    builder: (context, state) {
                      if (state is FamilyLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _submitCode(_codeController.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "ربط الحساب",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
