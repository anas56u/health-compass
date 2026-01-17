import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/feature/auth/data/model/PatientModel.dart';

class DoctorRequestsRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getPendingRequests() {
    final doctorId = _auth.currentUser?.uid;
    if (doctorId == null) {
      throw Exception("User not logged in");
    }

    return _firestore
        .collection('requests')
        .where('doctor_id', isEqualTo: doctorId)
        .where('status', isEqualTo: 'pending') 
        .orderBy('created_at', descending: true)
        .snapshots(); 
  }
  Future<List<PatientModel>> getMyPatients() async {
    final doctorId = _auth.currentUser?.uid;
    if (doctorId == null) {
      throw Exception("يجب تسجيل الدخول أولاً");
    }

    try {
      // نبحث عن المستخدمين من نوع 'patient' والذين تحتوي مصفوفة أطبائهم على هذا الطبيب
      final snapshot = await _firestore
          .collection('users')
          .where('user_type', isEqualTo: 'patient')
          .where('doctor_ids', arrayContains: doctorId) // السحر هنا: arrayContains
          .get();

      return snapshot.docs
          .map((doc) => PatientModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب قائمة المرضى: $e');
    }
  }

  Future<void> acceptRequest(String requestId, String patientId) async {
    final doctorId = _auth.currentUser?.uid;
    if (doctorId == null) return;

    WriteBatch batch = _firestore.batch();

    DocumentReference requestRef = _firestore.collection('requests').doc(requestId);
    batch.update(requestRef, {'status': 'accepted'});

    DocumentReference patientRef = _firestore.collection('users').doc(patientId);
    batch.update(patientRef, {
      'doctor_ids': FieldValue.arrayUnion([doctorId]) 
    });

    await batch.commit();
  }

  Future<void> rejectRequest(String requestId) async {
    await _firestore.collection('requests').doc(requestId).update({
      'status': 'rejected'
    });
  }
}