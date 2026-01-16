import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/core/models/medication_model.dart';
import 'package:health_compass/core/models/vital_model.dart';

class FamilyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. توليد كود عشوائي وحفظه
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

  // 2. جلب الكود الموجود مسبقاً
  Future<String?> getExistingCode() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists && doc.data() != null) {
        // ✅ تصحيح: التحقق من النوع قبل الإرجاع
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('connectionCode')) {
          return data['connectionCode'] as String?;
        }
      }
      return null;
    } catch (e) {
      print("Error fetching code: $e");
      return null;
    }
  }

  // 3. البحث عن كود مريض والحصول على ID
  Future<String?> findPatientByCode(String code) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('connectionCode', isEqualTo: code)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    }
    return null;
  }

  // 4. جلب بروفايل المريض
  Future<Map<String, dynamic>> getPatientProfile(String patientId) async {
    final doc = await _firestore.collection('users').doc(patientId).get();
    if (doc.exists) {
      // ✅ تصحيح: إضافة as Map<String, dynamic>
      return doc.data() as Map<String, dynamic>;
    } else {
      throw "المريض غير موجود";
    }
  }

  // 5. ربط المريض بالمراقب
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

  // 6. جلب أدوية المريض (Stream)
  Stream<List<MedicationModel>> getPatientMedications(String patientId) {
    return _firestore
        .collection('users')
        .doc(patientId)
        .collection('medications')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            // ✅✅ تصحيح: إضافة as Map<String, dynamic> هنا
            return MedicationModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // 7. جلب العلامات الحيوية الأخيرة
  Future<List<VitalModel>> getRecentVitals(String patientId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(patientId)
        .collection('vitals')
        .orderBy('date', descending: true)
        .limit(4)
        .get();

    return snapshot.docs.map((doc) {
      // ✅✅ تصحيح: إضافة as Map<String, dynamic> هنا
      return VitalModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // 8. إلغاء ربط مريض
  Future<void> unlinkPatient(String familyUid, String patientId) async {
    try {
      await _firestore.collection('users').doc(familyUid).update({
        'linked_patients': FieldValue.arrayRemove([patientId]),
      });
    } catch (e) {
      throw "فشل إلغاء الربط: $e";
    }
  }

  // 9. جلب سجل القراءات كاملاً
  Future<List<VitalModel>> getVitalsHistory(
    String patientId, {
    String? type,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .doc(patientId)
          .collection('vitals')
          .orderBy('date', descending: true);

      if (type != null && type != 'all') {
        query = query.where('type', isEqualTo: type);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        // ✅✅ تصحيح: إضافة as Map<String, dynamic> هنا
        return VitalModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw "فشل جلب السجل: $e";
    }
  }
}
