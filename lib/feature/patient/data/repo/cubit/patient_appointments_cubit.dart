import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_compass/feature/doctor/appointment/models/appointment_model.dart';

// -----------------------------------------------------------------------------
// States: تم إضافة الـ const لتحسين الأداء وتوريث الفئة الأساسية بشكل صحيح
// -----------------------------------------------------------------------------
abstract class PatientAppointmentsState {
  const PatientAppointmentsState();
}

class PatientAppointmentsInitial extends PatientAppointmentsState {
  const PatientAppointmentsInitial();
}

class PatientAppointmentsLoading extends PatientAppointmentsState {
  const PatientAppointmentsLoading();
}

class PatientAppointmentsLoaded extends PatientAppointmentsState {
  final List<AppointmentModel> appointments;
  const PatientAppointmentsLoaded(this.appointments);
}

class PatientAppointmentsError extends PatientAppointmentsState {
  final String message;
  const PatientAppointmentsError(this.message);
}

// -----------------------------------------------------------------------------
// Cubit: إضافة منطق الحجز الجديد وتحسين التعامل مع الـ Firestore
// -----------------------------------------------------------------------------
class PatientAppointmentsCubit extends Cubit<PatientAppointmentsState> {
  PatientAppointmentsCubit() : super(const PatientAppointmentsInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// جلب كافة مواعيد المريض الحالي (الأحدث أولاً)
  Future<void> getMyAppointments() async {
    if (isClosed) return;

    emit(const PatientAppointmentsLoading());

    try {
      final userId = _auth.currentUser?.uid;

      if (userId == null) {
        _safeEmit(
          const PatientAppointmentsError("يرجى تسجيل الدخول لعرض المواعيد"),
        );
        return;
      }

      final snapshot = await _firestore
          .collection('appointments')
          .where('patient_id', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      final appointments = snapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
          .toList();

      _safeEmit(PatientAppointmentsLoaded(appointments));
    } catch (e) {
      _safeEmit(PatientAppointmentsError("فشل جلب البيانات: ${e.toString()}"));
    }
  }

  /// حجز موعد جديد
  Future<void> bookAppointment({
    required String doctorId,
    required String doctorName,
    String? doctorImage,
    required DateTime date,
    required String time,
    required String type,
  }) async {
    if (isClosed) return;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('appointments').add({
        'patient_id': user.uid,
        'patient_name': user.displayName ?? "مريض",
        'doctor_id': doctorId,
        'doctor_name': doctorName,
        'doctor_image': doctorImage,
        'date': Timestamp.fromDate(date),
        'time': time,
        'status': 'pending', // حالة الانتظار
        'type': type,
      });

      // إعادة جلب القائمة لتحديث الواجهة بالموعد الجديد
      await getMyAppointments();
    } catch (e) {
      _safeEmit(PatientAppointmentsError("فشل عملية الحجز: $e"));
    }
  }

  /// إلغاء الموعد وتحديث القائمة
  Future<void> cancelAppointment(String appointmentId) async {
    if (isClosed) return;

    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'cancelled',
      });

      // تحديث القائمة فوراً لتعكس التغيير
      await getMyAppointments();
    } catch (e) {
      _safeEmit(PatientAppointmentsError("فشل إلغاء الموعد: $e"));
    }
  }

  /// دالة مساعدة للإرسال الآمن للحالات (تجنب الـ Emit بعد إغلاق الكيوبت)
  void _safeEmit(PatientAppointmentsState state) {
    if (!isClosed) emit(state);
  }
}
