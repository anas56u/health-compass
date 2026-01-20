import 'package:flutter/material.dart';
import 'package:health_compass/core/routes/routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';

class EmergencyScreen extends StatefulWidget {
  final String message;
  final double value;
  final String? familyPhoneNumber;
  final String? doctorPhoneNumber;

  const EmergencyScreen({
    Key? key, 
    required this.message, 
    required this.value,
    this.doctorPhoneNumber,
    this.familyPhoneNumber
  }) : super(key: key);

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  // تعريف مشغل الصوت
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    
    // إعداد أنيميشن النبض
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // بدء تشغيل الصوت بطريقة آمنة
    _playAlarmSound();
  }

  // --- [التعديل الجوهري 1]: حماية التطبيق من الانهيار ---
  Future<void> _playAlarmSound() async {
    try {
      // إعداد التكرار أولاً
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      // التحقق: هل خرج المستخدم من الشاشة أثناء إعداد الصوت؟
      if (!mounted) return; 

      // تشغيل الصوت (استخدام play يختصر setSource + resume)
      await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
      
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  @override
  void dispose() {
    // --- [التعديل الجوهري 2]: ترتيب تنظيف الموارد ---
    // إيقاف الصوت فوراً قبل حذف المشغل
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    
    // التحقق من إمكانية الاتصال قبل محاولة فتحه
    if (await canLaunchUrl(launchUri)) {
      // إيقاف الصوت للسماح للمستخدم بالتحدث
      await _audioPlayer.stop(); 
      await launchUrl(launchUri);
    } else {
      // إظهار رسالة خطأ للمستخدم في حال الفشل
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تعذر إجراء الاتصال، يرجى المحاولة يدوياً")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // الجزء العلوي: أيقونة التحذير والنص
                Column(
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_rounded,
                        size: 80,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "تنبيه صحي حرج!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.red.shade900,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),

                // الجزء الأوسط: بطاقة القيمة
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: Colors.red.shade100, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "القيمة المسجلة",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${widget.value.toInt()}",
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: Colors.red.shade800,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "BPM", 
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // الجزء السفلي: أزرار التحكم
                Column(
                  children: [
                    ScaleTransition(
                      scale: _animation,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => _makePhoneCall('911'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(35),
                            elevation: 10,
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone_in_talk_rounded, size: 40),
                              SizedBox(height: 5),
                              Text("SOS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildSecondaryButton(
                            icon: Icons.family_restroom,
                            label: "العائلة",
                            color: Colors.blue.shade700,
                            onTap: widget.familyPhoneNumber != null 
                              ? () => _makePhoneCall(widget.familyPhoneNumber!)
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("لا يوجد رقم عائلة مسجل")),
                                  );
                                },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildSecondaryButton(
                            icon: Icons.medical_services_rounded,
                            label: "طبيبي",
                            color: Colors.green.shade700,
                            onTap: widget.doctorPhoneNumber != null 
                              ? () => _makePhoneCall(widget.doctorPhoneNumber!)
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("لا يوجد طبيب مرتبط")),
                                  );
                                },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        // عند الضغط على إلغاء، نخرج من الشاشة
                        // دالة dispose تتكفل بالتنظيف
// هذا يضمن عدم ظهور شاشة سوداء
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.patientHome, // تأكد أن هذا الاسم مطابق لما في AppRoutes
                          (route) => false, // يحذف كل الصفحات السابقة (بما فيها الطوارئ)
                        );                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        "أنا بخير، إلغاء التنبيه",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}