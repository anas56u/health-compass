import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/feature/auth/data/model/PatientModel.dart';
import 'package:health_compass/feature/auth/data/model/doctormodel.dart'; // تأكد من استيراد موديل الطبيب

class DoctorRequestsRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---------------------------------------------------------------------------
  // الجزء الخاص بالطبيب (موجود مسبقاً)
  // ---------------------------------------------------------------------------

  Stream<QuerySnapshot> getPendingRequests() {
    final doctorId = _auth.currentUser?.uid;
    if (doctorId == null) throw Exception("User not logged in");

    return _firestore
        .collection('requests')
        .where('doctor_id', isEqualTo: doctorId)
        .where('status', isEqualTo: 'pending')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Future<List<PatientModel>> getMyPatients() async {
    final doctorId = _auth.currentUser?.uid;
    if (doctorId == null) throw Exception("يجب تسجيل الدخول أولاً");

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('user_type', isEqualTo: 'patient')
          .where('doctor_ids', arrayContains: doctorId)
          .get();

      return snapshot.docs
          .map((doc) => PatientModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب قائمة المرضى: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // الجزء الخاص بالمريض (الإضافات الجديدة)
  // ---------------------------------------------------------------------------

  /// 1. جلب قائمة الـ UIDs للأطباء الذين أرسل لهم المريض طلباً "معلقاً"
  /// نستخدم الـ Stream للحصول على تحديثات فورية في الواجهة
  Stream<List<String>> getSentRequestsIds() {
    final patientId = _auth.currentUser?.uid;
    if (patientId == null) return Stream.value([]);

    return _firestore
        .collection('requests')
        .where('patient_id', isEqualTo: patientId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => doc['doctor_id'] as String).toList(),
        );
  }

  /// 2. جلب قائمة الـ UIDs للأطباء المرتبطين بالمريض فعلياً
  /// (الذين وافقوا على الطلب وظهروا في مصفوفة doctor_ids لدى المريض)
  Stream<List<String>> getLinkedDoctorsIds() {
    final patientId = _auth.currentUser?.uid;
    if (patientId == null) return Stream.value([]);

    return _firestore.collection('users').doc(patientId).snapshots().map((doc) {
      if (doc.exists && doc.data()!.containsKey('doctor_ids')) {
        return List<String>.from(doc['doctor_ids']);
      }
      return [];
    });
  }

  // ---------------------------------------------------------------------------
  // عمليات الحذف والقبول (موجودة مسبقاً مع تحسين بسيط)
  // ---------------------------------------------------------------------------

  Future<void> acceptRequest(String requestId, String patientId) async {
    final doctorId = _auth.currentUser?.uid;
    if (doctorId == null) return;

    WriteBatch batch = _firestore.batch();

    DocumentReference requestRef = _firestore
        .collection('requests')
        .doc(requestId);
    batch.update(requestRef, {'status': 'accepted'});

    DocumentReference patientRef = _firestore
        .collection('users')
        .doc(patientId);
    batch.update(patientRef, {
      'doctor_ids': FieldValue.arrayUnion([doctorId]),
    });

    await batch.commit();
  }

  Future<void> rejectRequest(String requestId) async {
    await _firestore.collection('requests').doc(requestId).update({
      'status': 'rejected',
    });
  }
}
