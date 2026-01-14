import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/routes/routes.dart';
// import 'package:health_compass/core/widgets/AccessItem.dart'; // سنقوم ببناء التصميم مباشرة لضمان الشكل الجديد

class AccessibilityFacilities extends StatelessWidget {
  const AccessibilityFacilities({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. تحديث القائمة لإضافة الألوان لكل عنصر (الترميز اللوني)
    final List<Map<String, dynamic>> accessItems = [
      {
        'icon': Icons.location_on_rounded,
        'label': 'تواصل مع طبيبك',
        'color': Colors.blue, // لون مميز
        'route': AppRoutes.chatScreen,
      },
      {
        'icon': Icons.watch_later_rounded,
        'label': 'تقاريرك وتقدمك',
        'color': const Color(0xFF0D9488),
        'route': AppRoutes.healthDashboard,
      },
      {
        'icon': Icons.volume_up_rounded,
        'label': 'اتصل بالطوارئ',
        'color': Colors.redAccent, // أحمر للطوارئ
        'route': null,
      },
      {
        'icon': Icons.chat_bubble_outline_rounded,
        'label': 'راسل دليل',
        'color': const Color(0xFF0D9488), // لون الهوية
        'route': AppRoutes.chatBot,
      },
      {
        'icon': Icons.calendar_today_rounded,
        'label': 'احجز موعد',
        'color': Colors.purple, // لون مختلف للمواعيد
        'route': AppRoutes.appointmentBooking,
      },
      {
        'icon': Icons.alarm_add_rounded,
        'label': 'إضافة تذكير',
        'color': Colors.orange, // برتقالي للتنبيهات
        'route': AppRoutes.reamindersPage,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // العنوان
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.accessibility_new_rounded,
                  color: Color(0xFF0D9488),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'خدمات الوصول السريع', // اسم أكثر ودية
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // الشبكة
            Directionality(
              textDirection: TextDirection.rtl,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: accessItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12, // مسافات متزنة
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.3, // نسبة تجعل البطاقة عريضة ومريحة للنص
                ),
                itemBuilder: (context, index) {
                  final item = accessItems[index];
                  final Color itemColor = item['color'];

                  return Container(
                    decoration: BoxDecoration(
                      // لون خلفية فاتح جداً مشتق من لون الأيقونة
                      color: itemColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: itemColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    // Material و InkWell لإضافة تأثير الضغط
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          if (item['route'] != null) {
                            Navigator.pushNamed(context, item['route']);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("جاري فتح: ${item['label']}"),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: itemColor,
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .start, // محاذاة لليمين (بسبب RTL)
                            children: [
                              // دائرة خلف الأيقونة لتمييزها
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: itemColor.withOpacity(0.2),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  item['icon'],
                                  color: itemColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // النص
                              Expanded(
                                child: Text(
                                  item['label'],
                                  style: GoogleFonts.tajawal(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
