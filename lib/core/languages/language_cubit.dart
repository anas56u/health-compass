// import 'package:flutter/material.dart';
// import 'package:hydrated_bloc/hydrated_bloc.dart';

// class LanguageCubit extends HydratedCubit<Locale> {
//   LanguageCubit() : super(const Locale('en'));

//   // تغيير اللغة
//   void changeLanguage(String languageCode) {
//     emit(Locale(languageCode));
//   }

//   // الحصول على اللغة الحالية

//   String getCurrentLanguageCode() {
//     return state.languageCode;
//   }

//   final String _jsonKey = "languageCode";

//   @override
//   Locale? fromJson(Map<String, dynamic> json) {
//     final languageCode = json[_jsonKey] as String?;
//     return Locale(languageCode ?? 'en');
//   }

//   @override
//   Map<String, dynamic>? toJson(Locale state) {
//     return {_jsonKey: state.languageCode};
//   }
// }
