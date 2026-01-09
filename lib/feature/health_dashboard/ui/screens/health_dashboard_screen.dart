import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' as intl;

// تأكد من استيراد الموديلات والكيوبت والخدمة بشكل صحيح
import 'package:health_compass/feature/health_dashboard/models/health_data_model.dart';
import 'package:health_compass/feature/health_dashboard/logic/health_dashboard_cubit.dart';
import 'package:health_compass/feature/home/presentation/PatientView_body.dart';
import 'package:pdf/pdf.dart';

class HealthDashboardScreen extends StatefulWidget {
  const HealthDashboardScreen({super.key});

  @override
  State<HealthDashboardScreen> createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends State<HealthDashboardScreen>
    with SingleTickerProviderStateMixin {
  final Color _primaryColor = const Color(0xFF0D9488);
  final Color _bgColor = const Color(0xFFF8FAFC);
  final ScrollController _scrollController = ScrollController();

  bool _isWeekly = true; // يمكن ربطها بالكيوبت لاحقاً
  int _selectedChartIndex = 0;
  int _selectedDateIndex = 6; // افتراضياً اليوم

  // --- دوال مساعدة للعرض ---
  String _getSugarStatus(int value) =>
      value == 0 ? "--" : (value > 140 ? "مرتفع" : "طبيعي");

  String _getHeartStatus(int value) =>
      value == 0 ? "--" : (value > 100 ? "تسارع" : "طبيعي");

  // --- تفعيل الرسم البياني والتركيز عليه ---
  void _activateChartFor(int index) {
    setState(() => _selectedChartIndex = index);
    // التمرير التلقائي لمكان الرسم البياني (بشكل نسبي لارتفاع الشاشة)
    if (_scrollController.hasClients) {
      final screenHeight = MediaQuery.of(context).size.height;
      _scrollController.animateTo(
        screenHeight * 0.45, // تقريباً منتصف الصفحة
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // استخدام MediaQuery للأبعاد النسبية
    final size = MediaQuery.of(context).size;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
    );

    return BlocProvider(
      create: (context) => HealthDashboardCubit()..initDashboard(),
      child: Builder(
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: _bgColor,
              body: RefreshIndicator(
                onRefresh: () async {
                  context.read<HealthDashboardCubit>().initDashboard();
                },
                color: _primaryColor,
                child: BlocBuilder<HealthDashboardCubit, HealthDashboardState>(
                  builder: (context, state) {
                    if (state is HealthDashboardLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is HealthDashboardError) {
                      return Center(child: Text("خطأ: ${state.message}"));
                    }

                    if (state is HealthDashboardLoaded) {
                      // التحقق من فراغ البيانات لعرض الـ Empty State
                      bool isEmptyData =
                          state.latestData.heartRate == 0 &&
                          state.latestData.sugar == 0;

                      return CustomScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        slivers: [
                          _buildSliverAppBar(
                            context,
                            state.latestData,
                            state.commitmentPercentage,
                          ),

                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 25),
                                  // 1. شريط التاريخ
                                  _buildFadeIn(
                                    child: _buildRealDateTimeline(),
                                    delay: 100,
                                  ),
                                  const SizedBox(height: 25),

                                  // 2. بطاقة الإنجاز (أصبحت تفاعلية الآن)
                                  _buildFadeIn(
                                    child: _buildDailyProgressCard(
                                      state.completedTasks,
                                      state.totalTasks,
                                    ),
                                    delay: 200,
                                  ),
                                  const SizedBox(height: 25),

                                  _buildFadeIn(
                                    child: _buildSectionTitle(
                                      "العلامات الحيوية",
                                    ),
                                    delay: 300,
                                  ),
                                  const SizedBox(height: 15),
                                ],
                              ),
                            ),
                          ),

                          // 3. شبكة البيانات الحيوية
                          isEmptyData
                              ? SliverToBoxAdapter(
                                  child: _buildEmptyStateWidget(),
                                )
                              : _buildVitalSignsGrid(state.latestData),

                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 30),
                                  // 4. الرسم البياني (يظهر فقط عند وجود بيانات)
                                  if (!isEmptyData) ...[
                                    _buildSectionTitle("التحليل البياني"),
                                    const SizedBox(height: 15),
                                    // نمرر الارتفاع النسبي للرسم البياني
                                    _buildMultiChartSection(
                                      state.historyData,
                                      height: size.height * 0.45,
                                    ),
                                    const SizedBox(height: 30),
                                  ],

                                  _buildInsightBanner(),
                                  const SizedBox(height: 100),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Widgets ---

  Widget _buildEmptyStateWidget() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.monitor_heart_outlined,
            size: 60,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 15),
          Text(
            "لا توجد قراءات بعد",
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "ابدأ بقياس مؤشراتك الحيوية لتظهر هنا.",
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    HealthDataModel data,
    double commitment,
  ) {
    final int percentInt = (commitment * 100).toInt();
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: _primaryColor,
      elevation: 0,
      stretch: true,
      leading: IconButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.white24,
          child: Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Patientview_body()),
        ),
      ),
      actions: [
        IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
          ),
          tooltip: "تحميل التقرير",
          onPressed: () {
            // PdfService.generateAndOpen(data);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("تأكد من تفعيل PdfService")),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_primaryColor, const Color(0xFF115E59)],
                ),
              ),
            ),
            Positioned(
              top: -50,
              right: -50,
              child: CircleAvatar(
                radius: 150,
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 60),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: CircularProgressIndicator(
                          value: commitment,
                          strokeWidth: 10,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "$percentInt%",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "معدل الالتزام",
                            style: GoogleFonts.cairo(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // أزرار التبديل (أسبوعي/شهري)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✅ نمرر الـ context هنا
                        _buildHeaderTabButton(context, "أسبوعي", true),
                        _buildHeaderTabButton(context, "شهري", false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ أضفنا (BuildContext context) هنا
  Widget _buildHeaderTabButton(
    BuildContext context,
    String text,
    bool isWeeklyBtn,
  ) {
    bool isSelected = _isWeekly == isWeeklyBtn;

    return GestureDetector(
      onTap: () {
        setState(() => _isWeekly = isWeeklyBtn);
        // ✅ الآن نستخدم الـ context الصحيح الممرر للدالة
        context.read<HealthDashboardCubit>().toggleViewMode(isWeeklyBtn);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          text,
          style: GoogleFonts.cairo(
            color: isSelected ? _primaryColor : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  //  الشريط الزمني التفاعلي
  Widget _buildRealDateTimeline() {
    return SizedBox(
      height: 85,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final date = DateTime.now().subtract(Duration(days: 6 - index));
          final bool isSelected = index == _selectedDateIndex;
          final String dayName = intl.DateFormat('E', 'ar').format(date);
          final String dayNumber = date.day.toString();

          return InkWell(
            onTap: () {
              setState(() => _selectedDateIndex = index);
              //  استخدم الـ context القادم من itemBuilder
              context.read<HealthDashboardCubit>().changeSelectedDate(date);
            },
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              decoration: BoxDecoration(
                color: isSelected ? _primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? _primaryColor : Colors.grey.shade200,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: GoogleFonts.cairo(
                      color: isSelected ? Colors.white70 : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNumber,
                    style: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  //  بطاقة الإنجاز (تفاعلية)
  Widget _buildDailyProgressCard(int completed, int total) {
    double progress = total == 0 ? 0 : completed / total;
    bool isFull = progress >= 1.0;

    return InkWell(
      onTap: () {
        // يمكنك هنا الانتقال لصفحة المهام: Navigator.push...
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isFull
              ? const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                ) // ذهبي
              : const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF334155)],
                ), // كحلي
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isFull
                  ? Colors.amber.withOpacity(0.4)
                  : const Color(0xFF1E293B).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation(
                      isFull ? Colors.white : const Color(0xFF2DD4BF),
                    ),
                  ),
                ),
                if (isFull)
                  const Icon(Icons.emoji_events, color: Colors.white, size: 30)
                else
                  Text(
                    "${(progress * 100).toInt()}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFull ? "أنت أسطورة!" : "تحدي اليوم",
                    style: GoogleFonts.cairo(
                      color: isFull ? Colors.black87 : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isFull
                        ? "أتممت جميع المهام بنجاح 🎉"
                        : "أكملت $completed من أصل $total مهام",
                    style: GoogleFonts.cairo(
                      color: isFull ? Colors.black54 : Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  //  شبكة العلامات الحيوية (تفاعلية)
  Widget _buildVitalSignsGrid(HealthDataModel data) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
        children: [
          _buildFadeIn(
            child: _buildProHealthCard(
              title: "نبضات القلب",
              value: data.heartRate > 0 ? "${data.heartRate.toInt()}" : "--",
              unit: "bpm",
              status: _getHeartStatus(data.heartRate.toInt()),
              color: const Color(0xFFEF4444),
              icon: Icons.favorite_rounded,
              onTap: () => _activateChartFor(2), // تفعيل رسم القلب
            ),
            delay: 400,
          ),
          _buildFadeIn(
            child: _buildProHealthCard(
              title: "ضغط الدم",
              value: data.bloodPressure.isEmpty ? "--/--" : data.bloodPressure,
              unit: "mmHg",
              status: "طبيعي",
              color: _primaryColor,
              icon: Icons.compress_rounded,
              onTap: () => _activateChartFor(1), // تفعيل رسم الضغط
            ),
            delay: 500,
          ),
          _buildFadeIn(
            child: _buildProHealthCard(
              title: "السكر",
              value: data.sugar > 0 ? "${data.sugar}" : "--",
              unit: "mg/dL",
              status: _getSugarStatus(data.sugar),
              color: const Color(0xFFF59E0B),
              icon: Icons.water_drop_rounded,
              onTap: () => _activateChartFor(0), // تفعيل رسم السكر
            ),
            delay: 600,
          ),
          _buildFadeIn(
            child: _buildProHealthCard(
              title: "الوزن",
              value: data.weight > 0 ? "${data.weight}" : "--",
              unit: "kg",
              status: "متابعة",
              color: const Color(0xFF78350F),
              icon: Icons.monitor_weight_rounded,
              onTap: () {},
            ),
            delay: 700,
          ),
        ],
      ),
    );
  }

  Widget _buildProHealthCard({
    required String title,
    required String value,
    required String unit,
    required String status,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white24,
                  radius: 18,
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.cairo(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- الرسم البياني الذكي
  Widget _buildMultiChartSection(
    List<HealthDataModel> history, {
    required double height,
  }) {
    // 1. تحديد النطاق بناءً على الاختيار (أسبوعي أم شهري)
    final int daysCount = _isWeekly ? 7 : 30;

    List<FlSpot> spots = [];
    List<double> dailyValues = List.filled(daysCount, 0.0);
    DateTime toDateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
    final today = toDateOnly(DateTime.now());

    // 2. توزيع البيانات
    for (var item in history) {
      final itemDate = toDateOnly(item.date);
      final difference = today.difference(itemDate).inDays;

      if (difference >= 0 && difference < daysCount) {
        // المعادلة العامة: (آخر اندكس - الفرق)
        int index = (daysCount - 1) - difference;

        double val = 0.0;
        if (_selectedChartIndex == 0)
          val = item.sugar.toDouble();
        else if (_selectedChartIndex == 2)
          val = item.heartRate;
        else if (_selectedChartIndex == 1)
          val = item.systolic.toDouble();

        // نأخذ القيمة الأحدث إذا تكررت التواريخ
        if (dailyValues[index] == 0) dailyValues[index] = val;
      }
    }

    // 3. إنشاء النقاط
    for (int i = 0; i < daysCount; i++) {
      if (dailyValues[i] > 0) {
        spots.add(FlSpot(i.toDouble(), dailyValues[i]));
      }
    }

    if (spots.isEmpty) {
      return Container(
        height: height > 400 ? 400 : height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          "لا توجد بيانات كافية للرسم",
          style: GoogleFonts.cairo(color: Colors.grey),
        ),
      );
    }

    // حساب الحدود
    double maxY = spots.map((e) => e.y).reduce(max);
    double minY = spots.map((e) => e.y).reduce(min);
    double graphMin = (minY - 10) < 0 ? 0 : (minY - 10);
    double graphMax = maxY + 10;
    if (graphMax == graphMin) graphMax += 10;

    Color activeColor = _selectedChartIndex == 0
        ? Colors.orange
        : _selectedChartIndex == 1
        ? _primaryColor
        : Colors.redAccent;

    return Container(
      height: height > 500 ? 500 : height,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildChartTab("السكري", 0, Colors.orange),
                _buildChartTab("الضغط", 1, _primaryColor),
                _buildChartTab("القلب", 2, Colors.redAccent),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => Colors.blueGrey.withOpacity(0.9),
                    getTooltipItems: (touchedSpots) => touchedSpots
                        .map(
                          (spot) => LineTooltipItem(
                            '${spot.y.toInt()}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  handleBuiltInTouches: true,
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (graphMax - graphMin) / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      // ✅ في الوضع الشهري: نعرض تاريخ كل 5 أيام لتجنب الزحام
                      interval: _isWeekly ? 1 : 5,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < daysCount) {
                          final date = DateTime.now().subtract(
                            Duration(days: (daysCount - 1) - index),
                          );
                          // ✅ تنسيق التاريخ يختلف حسب الوضع
                          final text = _isWeekly
                              ? intl.DateFormat('E', 'ar').format(
                                  date,
                                ) // سبت، أحد
                              : intl.DateFormat('d/M').format(date); // 12/1

                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              text,
                              style: GoogleFonts.cairo(
                                color: Colors.grey.shade600,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: activeColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: _isWeekly,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 3,
                            strokeColor: activeColor,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          activeColor.withOpacity(0.25),
                          activeColor.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                minX: 0,
                maxX: (daysCount - 1)
                    .toDouble(), // ✅ الحد الأقصى ديناميكي (6 أو 29)
                minY: graphMin,
                maxY: graphMax,
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTab(String title, int index, Color color) {
    bool isSelected = _selectedChartIndex == index;
    return GestureDetector(
      onTap: () => _activateChartFor(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(left: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: GoogleFonts.cairo(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: GoogleFonts.cairo(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
  );

  Widget _buildInsightBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 18,
            child: Icon(
              Icons.auto_graph_rounded,
              color: Color(0xFF10B981),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "تحسن ملحوظ!",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF065F46),
                    fontSize: 14,
                  ),
                ),
                Text(
                  "أداؤك أفضل بنسبة 12% مقارنة بالأسبوع الماضي.",
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF047857),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFadeIn({required Widget child, required int delay}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

extension PdfColorExtension on PdfColor {
  PdfColor withOpacity(double opacity) => PdfColor(red, green, blue, opacity);
}
