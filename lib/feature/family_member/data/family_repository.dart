import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // ✅ ضروري لعمل دالة DateFormat ومنع التكرار
import 'package:health_compass/core/models/medication_model.dart';
import 'package:health_compass/core/models/vital_model.dart';
import 'package:health_compass/feature/auth/data/model/family_member_model.dart';

class FamilyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- 1. إدارة الأكواد والربط ---

  Future<String> generateAndSaveInviteCode() async {
    User? user = _auth.currentUser;
    if (user == null) throw "User not logged in";

    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    String code = String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );

    await _firestore.collection('users').doc(user.uid).set({
      'connectionCode': code,
    }, SetOptions(merge: true));

    return code;
  }

  Future<String?> getExistingCode() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('connectionCode')) {
          return data['connectionCode'] as String?;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String> linkPatientByCode(String familyUid, String code) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('connectionCode', isEqualTo: code)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw "الكود غير صحيح أو انتهت صلاحيته";
      }

      final patientDoc = querySnapshot.docs.first;
      final patientId = patientDoc.id;

      await _firestore.collection('users').doc(familyUid).update({
        'linked_patients': FieldValue.arrayUnion([patientId]),
      });

      return patientId;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> unlinkPatient(String familyUid, String patientId) async {
    try {
      await _firestore.collection('users').doc(familyUid).update({
        'linked_patients': FieldValue.arrayRemove([patientId]),
      });
    } catch (e) {
      throw "فشل إلغاء الربط: $e";
    }
  }

  // --- 2. جلب البيانات (Queries) ---

  Future<List<Map<String, dynamic>>> getLinkedPatientsProfiles(
    String familyUid,
  ) async {
    final familyDoc = await _firestore.collection('users').doc(familyUid).get();
    final List<dynamic> linkedIds = familyDoc.data()?['linked_patients'] ?? [];

    if (linkedIds.isEmpty) return [];

    final futures = linkedIds.map((id) async {
      final doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    });

    final results = await Future.wait(futures);
    return results.whereType<Map<String, dynamic>>().toList();
  }

  Future<FamilyMemberModel> getMyProfile() async {
    final user = _auth.currentUser;
    if (user == null) throw "لا يوجد مستخدم مسجل";

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return FamilyMemberModel.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      throw "لم يتم العثور على بيانات الحساب";
    }
  }

  Future<List<VitalModel>> getRecentVitals(String patientId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(patientId)
        .collection('health_readings')
        .orderBy('date', descending: true)
        .limit(4)
        .get();

    return snapshot.docs.map((doc) {
      return VitalModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Stream<List<MedicationModel>> getPatientMedications(String patientId) {
    return _firestore
        .collection('users')
        .doc(patientId)
        .collection('medications')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return MedicationModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  Stream<List<VitalModel>> getPatientVitals(String patientId) {
    return _firestore
        .collection('users')
        .doc(patientId)
        .collection('health_readings')
        .orderBy('date', descending: true) // ✅ إضافة ترتيب للقائمة التاريخية
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return VitalModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // --- 3. عمليات التعديل (Commands) ---

  // ✅ الدالة المحسنة لإضافة القراءات الحيوية ومنع التكرار اللحظي
  Future<void> addVitalRecord({
    required String patientId,
    double? sugar,
    String? pressure,
  }) async {
    final batch = _firestore.batch();

    // استخدام الدقيقة كمعرف فريد لمنع تكرار القراءة في نفس الدقيقة
    final String timeKey = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());

    final vitalsRef = _firestore
        .collection('users')
        .doc(patientId)
        .collection('health_readings');

    // 1. إضافة قراءة السكر (إذا وُجدت) بمعرف فريد يعتمد على الدقيقة
    if (sugar != null) {
      final sugarDoc = vitalsRef.doc('sugar_$timeKey');
      batch.set(sugarDoc, {
        'type': 'sugar',
        'value': sugar.toString(),
        'unit': 'mg/dL',
        'date': FieldValue.serverTimestamp(),
      });
    }

    // 2. إضافة قراءة الضغط (إذا وُجدت) بمعرف فريد يعتمد على الدقيقة
    if (pressure != null && pressure.isNotEmpty) {
      final pressureDoc = vitalsRef.doc('pressure_$timeKey');
      batch.set(pressureDoc, {
        'type': 'pressure',
        'value': pressure,
        'unit': 'mmHg',
        'date': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> addMedication(
    String patientId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection('users')
        .doc(patientId)
        .collection('medications')
        .add(data);
  }

  Future<void> deleteMedication(String patientId, String medId) async {
    await _firestore
        .collection('users')
        .doc(patientId)
        .collection('medications')
        .doc(medId)
        .delete();
  }

  Future<void> deleteVital(String patientId, String vitalId) async {
    await _firestore
        .collection('users')
        .doc(patientId)
        .collection('health_readings')
        .doc(vitalId)
        .delete();
  }

  Future<void> addMedicationsBatch({
    required String patientId,
    required List<Map<String, dynamic>> medicationsList,
  }) async {
    final batch = _firestore.batch();
    final medRef = _firestore
        .collection('users')
        .doc(patientId)
        .collection('medications');

    for (var medData in medicationsList) {
      final docRef = medRef.doc(); // إنشاء معرف جديد لكل موعد
      batch.set(docRef, medData);
    }

    await batch.commit(); // تنفيذ الكل في طلب واحد
  }
}
