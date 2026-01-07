import 'package:flutter/material.dart';
import 'package:health_compass/core/routes/routes.dart';
import 'package:health_compass/core/widgets/AccessItem.dart';

class AccessibilityFacilities extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Center(
              child: const Text(
                'تسهيلات الوصول:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Accessitem(
                      icon: Icons.location_on,
                      label: 'تواصل مع طبيبك',
                      context: context,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.doctorContact);
                      },
                    ),
                    Accessitem(
                      icon: Icons.volume_up,
                      label: 'اتصل بالطوارئ',
                      context: context,
                    ),
                    Accessitem(
                      icon: Icons.calendar_today,
                      label: 'احجز موعد مع طبيبك',
                      context: context,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.appointmentBooking,
                        );
                      },
                    ),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Accessitem(
                      icon: Icons.watch_later,
                      label: 'تقاريرك وتقدمك',
                      context: context,
                    ),
                    Accessitem(
                      icon: Icons.chat_bubble_outline,
                      label: 'راسل مساعدك الذكي',
                      context: context,
                    ),
                    Accessitem(
                      icon: Icons.alarm,
                      label: 'إضافة تذكير',
                      context: context,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.reamindersPage);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
