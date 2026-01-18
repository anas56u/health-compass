import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_compass/feature/auth/data/model/PatientModel.dart';
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
  // ✅ أضف هذه الدالة الجديدة هنا
  Future<Map<String, String?>> getEmergencyContacts(PatientModel patient) async {
    String? doctorPhone;
    String? familyPhone;

    try {
      // 1. جلب رقم الطبيب الأول (إذا وجد)
      if (patient.doctorIds.isNotEmpty) {
        // نأخذ أول طبيب في القائمة كطبيب الطوارئ الافتراضي
        final doctorId = patient.doctorIds.first;
        final doctorDoc = await _firestore.collection('users').doc(doctorId).get();
        
        if (doctorDoc.exists) {
          doctorPhone = doctorDoc.data()?['phone_number'];
        }
      }

      // 2. جلب رقم أحد أفراد العائلة
      // ملاحظة: نفترض هنا أن وثيقة فرد العائلة في الفايربيس تحتوي على حقل 'linked_patient_id'
      // أو أنك ستبحث بناءً على الـ ID إذا كنت تخزنه عند المريض
      final familyQuery = await _firestore
          .collection('users')
          .where('user_type', isEqualTo: 'family_member')
          .where('patient_id', isEqualTo: patient.uid) // تأكد أن هذا الحقل موجود في داتا فرد العائلة
          .limit(1)
          .get();

      if (familyQuery.docs.isNotEmpty) {
        familyPhone = familyQuery.docs.first.data()['phone_number'];
      }

    } catch (e) {
      print("Error fetching emergency contacts: $e");
      // يمكن إرجاع null في حال حدوث خطأ، ولن يتعطل التطبيق
    }

    return {
      'doctor': doctorPhone,
      'family': familyPhone,
    };
  }
}