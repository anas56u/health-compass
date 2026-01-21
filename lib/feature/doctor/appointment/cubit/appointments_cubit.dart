import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/appointment_model.dart';

// -----------------------------------------------------------------------------
// States
// -----------------------------------------------------------------------------
abstract class AppointmentsState {
  // ✅ الحل هنا: إضافة كونستركتور ثابت للكلاس الأب
  const AppointmentsState();
}

class AppointmentsInitial extends AppointmentsState {
  const AppointmentsInitial();
}

class AppointmentsLoading extends AppointmentsState {
  const AppointmentsLoading();
}

class AppointmentsLoaded extends AppointmentsState {
  final List<AppointmentModel> appointments;
  final DateTime selectedDate;

  const AppointmentsLoaded(this.appointments, this.selectedDate);
}

class AppointmentsError extends AppointmentsState {
  final String message;

  const AppointmentsError(this.message);
}

// -----------------------------------------------------------------------------
// Cubit
// -----------------------------------------------------------------------------
class AppointmentsCubit extends Cubit<AppointmentsState> {
  // لاحظ هنا نستخدم const مع الحالة الابتدائية أيضاً
  AppointmentsCubit() : super(const AppointmentsInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime _currentSelectedDate = DateTime.now();

  Future<void> getAppointments(DateTime date) async {
    if (isClosed) return;

    // استخدام const هنا
    emit(const AppointmentsLoading());
    _currentSelectedDate = date;

    try {
      final doctorId = _auth.currentUser?.uid;

      if (doctorId == null) {
        if (!isClosed) emit(const AppointmentsError("غير مسجل الدخول"));
        return;
      }

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('appointments')
          .where('doctor_id', isEqualTo: doctorId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      final appointments = snapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
          .toList();

      if (!isClosed) {
        // استخدام const هنا لأن الكلاس أصبح يدعمها
        emit(AppointmentsLoaded(appointments, date));
      }
    } catch (e) {
      if (!isClosed) {
        emit(AppointmentsError(e.toString()));
      }
    }
  }

  Future<void> updateAppointmentStatus(
    String appointmentId,
    String newStatus,
  ) async {
    if (isClosed) return;

    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': newStatus,
      });

      if (!isClosed) {
        getAppointments(_currentSelectedDate);
      }
    } catch (e) {
      if (!isClosed) {
        emit(AppointmentsError("فشل تحديث الحالة: $e"));
      }
    }
  }
}
