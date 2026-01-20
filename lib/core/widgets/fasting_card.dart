import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/cache/shared_pref_helper.dart';

class FastingCard extends StatefulWidget {
  const FastingCard({super.key});

  @override
  State<FastingCard> createState() => _FastingCardState();
}

class _FastingCardState extends State<FastingCard> {
  // متغيرات الحالة
  bool _isLoading = true;
  bool _hasActiveFasting = false;
  Duration _remainingTime = Duration.zero;
  bool _isCompleted = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkFastingStatus();
    SharedPrefHelper.fastingUpdateNotifier.addListener(_checkFastingStatus);
    // تحديث العداد كل دقيقة
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkFastingStatus();
    });
  }

  @override
  void dispose() {
    SharedPrefHelper.fastingUpdateNotifier.removeListener(_checkFastingStatus);
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkFastingStatus() async {
    final startTime = await SharedPrefHelper.getFastingStartTime();
    final durationHours = await SharedPrefHelper.getFastingDuration();

    if (startTime == null) {
      if (mounted) setState(() => _hasActiveFasting = false);
      return;
    }

    // خوارزمية تحديد وقت البدء (هل كان اليوم أم الأمس؟)
    final now = DateTime.now();
    DateTime startDateTime = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);

    // إذا كان وقت البدء "في المستقبل" بالنسبة للحظة الحالية، فهذا يعني أنه كان بالأمس
    // مثال: الآن 8 صباحاً، ووقت البدء 10 ليلاً. الـ 10 ليلاً القادمة في المستقبل، إذن المقصود 10 ليلاً أمس
    if (startDateTime.isAfter(now)) {
      startDateTime = startDateTime.subtract(const Duration(days: 1));
    }

    final endDateTime = startDateTime.add(Duration(hours: durationHours));
    final difference = endDateTime.difference(now);

    // إذا مر أكثر من 24 ساعة على انتهاء الصيام، نعتبره ملغياً ولا نعرض البطاقة
    if (difference.isNegative && difference.abs().inHours > 24) {
      if (mounted) setState(() => _hasActiveFasting = false);
      return;
    }

    if (mounted) {
      setState(() {
        _hasActiveFasting = true;
        _isLoading = false;
        if (difference.isNegative) {
          _isCompleted = true;
          _remainingTime = Duration.zero;
        } else {
          _isCompleted = false;
          _remainingTime = difference;
        }
      });
    }
  }

  // دالة لإلغاء/حذف الصيام
  Future<void> _clearFasting() async {
    // ملاحظة: هنا سنحتاج لإضافة دالة حذف في SharedPrefHelper لاحقاً
    // للتبسيط الآن سنخفي البطاقة فقط
    setState(() => _hasActiveFasting = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasActiveFasting) return const SizedBox.shrink(); // لا تعرض شيئاً إذا لا يوجد صيام

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isCompleted 
              ? [const Color(0xFF10B981), const Color(0xFF059669)] // أخضر عند الانتهاء
              : [const Color(0xFFF59E0B), const Color(0xFFD97706)], // برتقالي أثناء الصيام
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_isCompleted ? Colors.green : Colors.orange).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isCompleted ? Icons.check_circle : Icons.timer,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isCompleted ? "اكتمل الصيام بنجاح!" : "جاري الصيام",
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (!_isCompleted)
                  Text(
                    "متبقي: ${_formatDuration(_remainingTime)}",
                    style: GoogleFonts.tajawal(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  )
                else
                  Text(
                    "يمكنك إجراء الفحص الآن",
                    style: GoogleFonts.tajawal(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          // زر إغلاق صغير
          if (_isCompleted)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: _clearFasting,
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    return "${d.inHours}:$twoDigitMinutes ساعة";
  }
}