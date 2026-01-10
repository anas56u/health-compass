import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medication_model.dart';
import '../models/medication_log_model.dart';
import 'package:intl/intl.dart';

class MedicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;


  Future<String> addMedication(MedicationModel medication) async {
    if (_userId == null) throw Exception('User not authenticated');

    final docRef = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medications')
        .add(medication.toFirestore());

    return docRef.id;
  }

  Stream<List<MedicationModel>> getMedications() {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('medications')
        .where('isActive', isEqualTo: true)
        .orderBy('time')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MedicationModel.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<List<MedicationModel>> getMedicationsForDate(DateTime date) {
    if (_userId == null) return Stream.value([]);

    int dayOfWeek = date.weekday % 7;

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('medications')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => MedicationModel.fromFirestore(doc))
                  .where((med) => med.daysOfWeek.contains(dayOfWeek))
                  .toList()
                ..sort((a, b) => a.time.compareTo(b.time)),
        );
  }

  Future<void> updateMedication(
    String medicationId,
    MedicationModel medication,
  ) async {
    if (_userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medications')
        .doc(medicationId)
        .update(medication.toFirestore());
  }

  Future<void> deleteMedication(String medicationId) async {
    if (_userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medications')
        .doc(medicationId)
        .update({'isActive': false});
  }

  // ==================== MEDICATION LOGS ====================

  Future<MedicationLogModel> getMedicationLog(
    String medicationId,
    DateTime date,
  ) async {
    if (_userId == null) throw Exception('User not authenticated');

    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final logId = '${medicationId}_$dateStr';

    final docSnapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medication_logs')
        .doc(logId)
        .get();

    if (docSnapshot.exists) {
      return MedicationLogModel.fromFirestore(docSnapshot);
    } else {
      final newLog = MedicationLogModel(
        id: logId,
        medicationId: medicationId,
        userId: _userId!,
        date: dateStr,
        status: MedicationStatus.pending,
      );

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('medication_logs')
          .doc(logId)
          .set(newLog.toFirestore());

      return newLog;
    }
  }

  Stream<List<MedicationLogModel>> getMedicationLogsForDate(DateTime date) {
    if (_userId == null) return Stream.value([]);

    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('medication_logs')
        .where('date', isEqualTo: dateStr)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MedicationLogModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> updateMedicationStatus(
    String medicationId,
    DateTime date,
    MedicationStatus status,
  ) async {
    if (_userId == null) throw Exception('User not authenticated');

    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final logId = '${medicationId}_$dateStr';

    final updateData = {
      'medicationId': medicationId,
      'userId': _userId,
      'date': dateStr,
      'status': MedicationLogModel.statusToString(status),
      'takenAt': status == MedicationStatus.taken ? Timestamp.now() : null,
    };

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medication_logs')
        .doc(logId)
        .set(updateData, SetOptions(merge: true));
  }

  /// Get medication status for a specific medication and date
  Future<MedicationStatus> getMedicationStatus(
    String medicationId,
    DateTime date,
  ) async {
    if (_userId == null) return MedicationStatus.pending;

    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final logId = '${medicationId}_$dateStr';

    final docSnapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medication_logs')
        .doc(logId)
        .get();

    if (docSnapshot.exists) {
      final log = MedicationLogModel.fromFirestore(docSnapshot);
      return log.status;
    }

    return MedicationStatus.pending;
  }

  /// Reset all medication statuses to pending for a new day
  /// This should be called automatically or manually at the start of each day
  Future<void> resetDailyStatuses(DateTime date) async {
    if (_userId == null) throw Exception('User not authenticated');

    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    // Get all logs for this date
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medication_logs')
        .where('date', isEqualTo: dateStr)
        .get();

    // Batch update all to pending
    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'status': 'pending', 'takenAt': null});
    }

    await batch.commit();
  }
}
