import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' as intl;
import 'package:health_compass/feature/health_dashboard/models/health_data_model.dart';
import 'package:health_compass/feature/health_dashboard/logic/health_dashboard_cubit.dart';
import 'package:health_compass/feature/home/presentation/PatientView_body.dart';
import 'package:pdf/pdf.dart';
import 'package:health_compass/core/services/pdf_service.dart';

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

  bool _isWeekly = true;
  int _selectedChartIndex = 0;
  int _selectedDateIndex = 6;

  String _getSugarStatus(int value) =>
      value == 0 ? "--" : (value > 140 ? "مرتفع" : "طبيعي");

  String _getHeartStatus(int value) =>
      value == 0 ? "--" : (value > 100 ? "تسارع" : "طبيعي");

  void _activateChartFor(int index) {
    setState(() => _selectedChartIndex = index);
    if (_scrollController.hasClients) {
      final screenHeight = MediaQuery.of(context).size.height;
      _scrollController.animateTo(
        screenHeight * 0.45,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      // ✅ تحسين فحص فراغ البيانات ليشمل الضغط أيضاً
                      bool isEmptyData =
                          state.latestData.heartRate == 0 &&
                          state.latestData.sugar == 0 &&
                          state.latestData.systolic == 0;

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
                            state.userName,
                            state.isWeekly,
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
                                  _buildFadeIn(
                                    child: _buildRealDateTimeline(context),
                                    delay: 100,
                                  ),
                                  const SizedBox(height: 25),

                                  // ✅ بطاقة التحدي الآن تستخدم البيانات الحقيقية من الـ state
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
                                  if (!isEmptyData) ...[
                                    _buildSectionTitle("التحليل البياني"),
                                    const SizedBox(height: 15),
                                    _buildMultiChartSection(
                                      state.historyData,
                                      state.isWeekly,
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
            "لا توجد قراءات لهذا اليوم",
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "اختر يوماً آخر من الشريط العلوي أو أضف قراءة جديدة.",
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
    String userName,
    bool isWeeklyView,
  ) {
    final int percentInt = (commitment * 100).toInt();
    return SliverAppBar(
      expandedHeight: 280,
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
          onPressed: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("جاري إنشاء التقرير...")),
            );
            await PdfService.generateMedicalReport(data, userName);
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
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeaderTabButton(
                          context,
                          "أسبوعي",
                          true,
                          isWeeklyView,
                        ),
                        _buildHeaderTabButton(
                          context,
                          "شهري",
                          false,
                          isWeeklyView,
                        ),
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

  Widget _buildHeaderTabButton(
    BuildContext context,
    String text,
    bool isWeeklyBtn,
    bool currentIsWeekly,
  ) {
    bool isSelected = currentIsWeekly == isWeeklyBtn;
    return GestureDetector(
      onTap: () =>
          context.read<HealthDashboardCubit>().toggleViewMode(isWeeklyBtn),
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

  Widget _buildRealDateTimeline(BuildContext context) {
    return SizedBox(
      height: 85,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, index) {
          final date = DateTime.now().subtract(Duration(days: 6 - index));
          final bool isSelected = index == _selectedDateIndex;
          final String dayName = intl.DateFormat('E', 'ar').format(date);

          return InkWell(
            onTap: () {
              setState(() => _selectedDateIndex = index);
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
                    "${date.day}",
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

  Widget _buildDailyProgressCard(int completed, int total) {
    double progress = total == 0 ? 0 : completed / total;
    bool isFull = progress >= 1.0 && total > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isFull
            ? const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
              )
            : const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
              isFull
                  ? const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 30,
                    )
                  : Text(
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
                  isFull ? "أنت أسطورة!" : "تحدي المهام",
                  style: GoogleFonts.cairo(
                    color: isFull ? Colors.black87 : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  total == 0
                      ? "لا توجد مهام اليوم"
                      : (isFull
                            ? "أتممت جميع المهام 🎉"
                            : "أكملت $completed من أصل $total مهام"),
                  style: GoogleFonts.cairo(
                    color: isFull ? Colors.black54 : Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSignsGrid(HealthDataModel data) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
        children: [
          _buildProHealthCard(
            title: "نبضات القلب",
            value: data.heartRate > 0 ? "${data.heartRate.toInt()}" : "--",
            unit: "bpm",
            status: _getHeartStatus(data.heartRate.toInt()),
            color: const Color(0xFFEF4444),
            icon: Icons.favorite_rounded,
            onTap: () => _activateChartFor(2),
          ),
          _buildProHealthCard(
            title: "ضغط الدم",
            value: data.systolic == 0 ? "--/--" : data.bloodPressure,
            unit: "mmHg",
            status: "طبيعي",
            color: _primaryColor,
            icon: Icons.compress_rounded,
            onTap: () => _activateChartFor(1),
          ),
          _buildProHealthCard(
            title: "السكر",
            value: data.sugar > 0 ? "${data.sugar}" : "--",
            unit: "mg/dL",
            status: _getSugarStatus(data.sugar),
            color: const Color(0xFFF59E0B),
            icon: Icons.water_drop_rounded,
            onTap: () => _activateChartFor(0),
          ),
          _buildProHealthCard(
            title: "الوزن",
            value: data.weight > 0 ? "${data.weight}" : "--",
            unit: "kg",
            status: "متابعة",
            color: const Color(0xFF78350F),
            icon: Icons.monitor_weight_rounded,
            onTap: () {},
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
            FittedBox(
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
            Text(
              unit,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiChartSection(
    List<HealthDataModel> history,
    bool isWeeklyView, {
    required double height,
  }) {
    final int daysCount = isWeeklyView ? 7 : 30;
    List<FlSpot> spots = [];
    List<double> dailyValues = List.filled(daysCount, 0.0);
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    for (var item in history) {
      final difference = today
          .difference(DateTime(item.date.year, item.date.month, item.date.day))
          .inDays;
      if (difference >= 0 && difference < daysCount) {
        int index = (daysCount - 1) - difference;
        double val = _selectedChartIndex == 0
            ? item.sugar.toDouble()
            : (_selectedChartIndex == 2
                  ? item.heartRate
                  : item.systolic.toDouble());
        if (dailyValues[index] == 0) dailyValues[index] = val;
      }
    }

    for (int i = 0; i < daysCount; i++) {
      if (dailyValues[i] > 0) spots.add(FlSpot(i.toDouble(), dailyValues[i]));
    }

    if (spots.isEmpty) return const SizedBox();

    Color activeColor = _selectedChartIndex == 0
        ? Colors.orange
        : (_selectedChartIndex == 1 ? _primaryColor : Colors.redAccent);

    return Container(
      height: height > 500 ? 500 : height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartTab("السكري", 0, Colors.orange),
              _buildChartTab("الضغط", 1, _primaryColor),
              _buildChartTab("القلب", 2, Colors.redAccent),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
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
                      interval: isWeeklyView ? 1 : 5,
                      getTitlesWidget: (value, meta) {
                        int idx = value.toInt();
                        if (idx < 0 || idx >= daysCount)
                          return const SizedBox();
                        final date = DateTime.now().subtract(
                          Duration(days: (daysCount - 1) - idx),
                        );
                        return Text(
                          isWeeklyView
                              ? intl.DateFormat('E', 'ar').format(date)
                              : intl.DateFormat('d/M').format(date),
                          style: const TextStyle(fontSize: 10),
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
                    color: activeColor,
                    barWidth: 4,
                    dotData: FlDotData(show: isWeeklyView),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          activeColor.withOpacity(0.2),
                          activeColor.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: GoogleFonts.cairo(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
  );

  Widget _buildInsightBanner() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_graph, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "أداء رائع! التزامك بالمهام تحسن بشكل ملحوظ.",
              style: GoogleFonts.cairo(color: Colors.green[800], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFadeIn({required Widget child, required int delay}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delay),
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
