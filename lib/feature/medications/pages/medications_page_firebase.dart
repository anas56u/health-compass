import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/services/notification_service.dart';
import '../widgets/medication_day_selector.dart';
import '../widgets/medication_time_slot.dart';
import '../widgets/medication_card.dart';
import '../widgets/add_medication_dialog.dart';
import '../services/medication_service.dart';
import '../models/medication_model.dart';
import '../models/medication_log_model.dart';

class MedicationsPageFirebase extends StatefulWidget {
  const MedicationsPageFirebase({super.key});

  @override
  State<MedicationsPageFirebase> createState() =>
      _MedicationsPageFirebaseState();
}

class _MedicationsPageFirebaseState extends State<MedicationsPageFirebase> {
  int selectedDayIndex = 3;
  final MedicationService _medicationService = MedicationService();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _calculateSelectedDate();
  }

  void _calculateSelectedDate() {
    final today = DateTime.now();
    final difference = selectedDayIndex - 3; // 3 is today's index
    _selectedDate = today.add(Duration(days: difference));
  }
  Future<void> _deleteMedication(MedicationModel med) async {
    // Best Practice: إظهار رسالة تأكيد قبل الحذف (Confirmation Dialog)
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف الدواء', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
        content: Text('هل أنت متأكد من حذف ${med.medicationName}؟', style: GoogleFonts.tajawal()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: GoogleFonts.tajawal(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: GoogleFonts.tajawal(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // 1. حذف من قاعدة البيانات
      await _medicationService.deleteMedication(med.id);
      
      // 2. إلغاء الإشعار محلياً
      // تأكد أن medicationId و daysOfWeek مخزنة بشكل صحيح في الموديل
      await NotificationService().cancelMedicationReminders(
        med.notificationId, 
        med.daysOfWeek
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف الدواء بنجاح', style: GoogleFonts.tajawal()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error deleting medication: $e");
    }
  }

  void _showAddMedicationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AddMedicationDialog(
        onAdd: (medication) async {
          // Capture the messenger before async gap
          final messenger = ScaffoldMessenger.of(context);
          try {
            await _medicationService.addMedication(medication);
            if (mounted) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'تم إضافة التذكير بنجاح',
                    style: GoogleFonts.tajawal(),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'خطأ في إضافة التذكير: $e',
                    style: GoogleFonts.tajawal(),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _updateMedicationStatus(
    String medicationId,
    MedicationStatus newStatus,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _medicationService.updateMedicationStatus(
        medicationId,
        _selectedDate,
        newStatus,
      );
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'خطأ في تحديث الحالة: $e',
              style: GoogleFonts.tajawal(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'جدول الادويه (يومي)',
                        style: GoogleFonts.tajawal(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _showAddMedicationDialog,
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.white,
                            ),
                            tooltip: 'إضافة دواء',
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.calendar_today_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  MedicationDaySelector(
                    selectedIndex: selectedDayIndex,
                    onDaySelected: (index) {
                      setState(() {
                        selectedDayIndex = index;
                        _calculateSelectedDate();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          // Medication schedule list
          Expanded(
            child: StreamBuilder<List<MedicationModel>>(
              stream: _medicationService.getMedicationsForDate(_selectedDate),
              builder: (context, medicationSnapshot) {
                if (medicationSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0D9488)),
                  );
                }

                if (medicationSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'خطأ في تحميل البيانات',
                      style: GoogleFonts.tajawal(color: Colors.red),
                    ),
                  );
                }

                final medications = medicationSnapshot.data ?? [];

                if (medications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medication_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد أدوية مجدولة لهذا اليوم',
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'انقر على + لإضافة دواء',
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return StreamBuilder<List<MedicationLogModel>>(
                  stream: _medicationService.getMedicationLogsForDate(
                    _selectedDate,
                  ),
                  builder: (context, logSnapshot) {
                    final logs = logSnapshot.data ?? [];
                    final logMap = {
                      for (var log in logs) log.medicationId: log,
                    };

                    // Group medications by time and build dynamic time slots
                    final medicationsByTime = <String, List<MedicationModel>>{};
                    for (var med in medications) {
                      final timeKey = '${med.time}_${med.period}';
                      medicationsByTime.putIfAbsent(timeKey, () => []).add(med);
                    }

                    // Sort time slots chronologically
                    final sortedTimeKeys = medicationsByTime.keys.toList()
                      ..sort((a, b) {
                        final aParts = a.split('_');
                        final bParts = b.split('_');
                        final aTime = aParts[0];
                        final bTime = bParts[0];
                        final aPeriod = aParts[1];
                        final bPeriod = bParts[1];

                        // Convert to 24-hour for sorting
                        int aHour = int.parse(aTime.split(':')[0]);
                        int bHour = int.parse(bTime.split(':')[0]);

                        if (aPeriod == 'م' && aHour != 12) aHour += 12;
                        if (bPeriod == 'م' && bHour != 12) bHour += 12;
                        if (aPeriod == 'ص' && aHour == 12) aHour = 0;
                        if (bPeriod == 'ص' && bHour == 12) bHour = 0;

                        return aHour.compareTo(bHour);
                      });

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Build dynamic time slots based on actual medications
                          ...sortedTimeKeys.map((timeKey) {
                            final parts = timeKey.split('_');
                            final time = parts[0];
                            final period = parts[1];
                            final meds = medicationsByTime[timeKey]!;

                            return _buildTimeSlotWithMedications(
                              time,
                              period,
                              meds,
                              logMap,
                            );
                          }).toList(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMedicationDialog,
        backgroundColor: const Color(0xFF0D9488),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTimeSlotWithMedications(
    String time,
    String period,
    List<MedicationModel> medications,
    Map<String, MedicationLogModel> logMap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: medications.isNotEmpty
                      ? const Color(0xFF0D9488)
                      : Colors.grey[300],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: medications.isNotEmpty
                        ? const Color(0xFF0D9488)
                        : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: 2,
                height: medications.isNotEmpty
                    ? (medications.length * 130.0)
                    : 40,
                color: Colors.grey[300],
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Time slot
          MedicationTimeSlot(time: time, period: period),
          const SizedBox(width: 12),
          // Medication cards
          Expanded(
            child: medications.isEmpty
                ? const SizedBox()
                : Column(
                    children: medications.map((medication) {
                      final log = logMap[medication.id];
                      final status = log?.status ?? MedicationStatus.pending;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MedicationCard(
                          medicationName: medication.medicationName,
                          dosage: medication.dosage,
                          instructions: medication.instructions,
                          status: status,
                          onTaken: () => _updateMedicationStatus(
                            medication.id,
                            MedicationStatus.taken,
                          ),
                          onSkipped: () => _updateMedicationStatus(
                            medication.id,
                            MedicationStatus.notTaken,
                          ),
                          onDelete: () => _deleteMedication(medication),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

