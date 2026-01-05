import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:health_compass/feature/auth/data/model/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> getUserData({required String uid});
  Future<UserCredential> login({
    required String email,
    required String password,

  });

 Future<void> registerUser({
    required UserModel userModel,
    required String password,
    File? imagefile,
  });

  Future<void> logout();

  Future<void> resetPassword({required String email});

  User? getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
 final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _firebaseStorage; 

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FirebaseStorage? firebaseStorage,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;
        @override
  Future<UserModel> getUserData({required String uid}) async {
    try {
      final documentSnapshot = await _firestore.collection('users').doc(uid).get();
      
      if (documentSnapshot.exists) {
        return UserModel.fromMap(documentSnapshot.data()!);
      } else {
        throw Exception('المستخدم غير موجود في قاعدة البيانات');
      }
    } catch (e) {
      throw Exception('فشل جلب بيانات المستخدم: $e');
    }
  }
  @override
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع');
    }
  }

  @override
  Future<void> registerUser({
    required UserModel userModel,
    required String password,
    File? imagefile,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: userModel.email,
        password: password,
      );

      final String uid = userCredential.user!.uid;
      String? imageUrl;
      if (imagefile != null) {
        final ref = _firebaseStorage.ref().child('profile_images/$uid.jpg');
        await ref.putFile(imagefile);
        imageUrl = await ref.getDownloadURL();
      }

      final updatedUser = userModel.copyWith(
        uid: uid,
        profileImage: imageUrl,
      );
      await _firestore.collection('users').doc(uid).set(updatedUser.toMap());

    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع أثناء التسجيل: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('فشل تسجيل الخروج');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('فشل إرسال رابط إعادة تعيين كلمة المرور');
    }
  }

  @override
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'لا يوجد حساب بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'operation-not-allowed':
        return 'العملية غير مسموح بها';
      case 'too-many-requests':
        return 'تم إجراء عدد كبير من المحاولات. حاول لاحقاً';
      case 'network-request-failed':
        return 'فشل الاتصال بالشبكة';
      case 'invalid-credential':
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      default:
        return e.message ?? 'حدث خطأ أثناء المصادقة';
    }
  }
}
