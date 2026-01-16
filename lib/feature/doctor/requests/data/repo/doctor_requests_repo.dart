import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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