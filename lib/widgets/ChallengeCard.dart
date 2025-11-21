import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ChallengeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String progressText;
  final String badgeText;
  final String timeText;
  final String points;
  final double percent;
  final Color primaryColor;
  final Color badgeColor;
  final Color badgeTextColor;
  final IconData icon;

  const ChallengeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progressText,
    required this.badgeText,
    required this.timeText,
    required this.points,
    required this.percent,
    required this.primaryColor,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEFF5), 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect( 
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              height: 6,
              width: double.infinity,
              color: primaryColor.withOpacity(0.7), 
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded( 
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeColor, 
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                badgeText,
                                style: GoogleFonts.tajawal(
                                  color: badgeTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.access_time_filled, size: 12, color: Colors.grey.shade600),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    timeText,
                                    style: GoogleFonts.tajawal(
                                      color: Colors.grey.shade600,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Expanded( 
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0, left: 4, right: 4),
                          child: Text(
                            progressText,
                            textAlign: TextAlign.center,
                           
                            textDirection: TextDirection.ltr, 
                            style: GoogleFonts.tajawal(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: primaryColor, 
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: Colors.white, size: 26),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 15),

                  Text(
                    title,
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.w900, 
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                  ),

                  const SizedBox(height: 20),

                  LinearPercentIndicator(
                    lineHeight: 8.0,
                    percent: percent,
                    barRadius: const Radius.circular(10),
                    backgroundColor: Colors.white, 
                    progressColor: primaryColor, 
                    padding: EdgeInsets.zero,
                    animation: true,
                    animationDuration: 1000,
                    isRTL: true,
                  ),

                  const SizedBox(height: 15),

                  Row(
                    textDirection: TextDirection.rtl, 
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFA000), size: 22), 
                      const SizedBox(width: 4),
                      Text(
                        points,
                        style: GoogleFonts.tajawal(
                          color: const Color(0xFFFFA000), 
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
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