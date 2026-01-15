import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/data/model/doctormodel.dart';

class PatientRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<DoctorModel>> getAllDoctors() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('user_type', isEqualTo: 'doctor') 
          .get();

      return snapshot.docs
          .map((doc) => DoctorModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب قائمة الأطباء: $e');
    }
  }

  Future<void> sendLinkRequest(String doctorId, String doctorName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('requests').add({
        'patient_id': user.uid,
        'patient_email': user.email,
        'doctor_id': doctorId,
        'doctor_name': doctorName,
        'status': 'pending', 
        'type': 'link_request',
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('فشل إرسال الطلب: $e');
    }
  }
}