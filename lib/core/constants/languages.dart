import 'package:flutter/material.dart';

class Languages {
  static final all = [
    const Locale('en'),
    const Locale('ar'),
    // const Locale('fr'),
    // const Locale('es'),
    // const Locale('pt'),
    // const Locale('ru'),
    // const Locale('zh'),
    // const Locale('ja'),
    // const Locale('de'),
    // const Locale('it'),
    // const Locale('ko'),
    // const Locale('vi'),
    // const Locale('tr'),
    // const Locale('pl'),
    // const Locale('id'),
  ];

  static String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English (US)';
      case 'ar':
        return 'Arabic';
      // case 'fr':
      //   return 'Français';
      // case 'es':
      //   return 'Español';
      // case 'pt':
      //   return 'Português';
      // case 'ru':
      //   return 'Русский';
      // case 'zh':
      //   return '中文';
      // case 'ja':
      //   return '日本語';
      // case 'de':
      //   return 'Deutsch';
      // case 'it':
      //   return 'Italiano';
      // case 'ko':
      //   return '한국어';
      // case 'vi':
      //   return 'Tiếng Việt';
      // case 'tr':
      //   return 'Türkçe';
      // case 'pl':
      //   return 'Polski';
      // case 'id':
      //   return 'Bahasa Indonesia';
      default:
        return 'English (US)';
    }
  }

  static String getLanguageFlag(String code) {
    switch (code) {
      case 'en':
        return '🇺🇸';
      case 'ar':
        return '🇪🇬';
      // case 'fr':
      //   return '🇫🇷';
      // case 'es':
      //   return '🇪🇸';
      // case 'pt':
      //   return '🇵🇹';
      // case 'ru':
      //   return '🇷🇺';
      // case 'zh':
      //   return '🇨🇳';
      // case 'ja':
      //   return '🇯🇵';
      // case 'de':
      //   return '🇩🇪';
      // case 'it':
      //   return '🇮🇹';
      // case 'ko':
      //   return '🇰🇷';
      // case 'vi':
      //   return '🇻🇳';
      // case 'tr':
      //   return '🇹🇷';
      // case 'pl':
      //   return '🇵🇱';
      // case 'id':
      //   return '🇮🇩';
      default:
        return '🇺🇸';
    }
  }

  static String getLanguageNativeName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      // case 'fr':
      //   return 'Français';
      // case 'es':
      //   return 'Español';
      // case 'pt':
      //   return 'Português';
      // case 'ru':
      //   return 'Русский';
      // case 'zh':
      //   return '中文';
      // case 'ja':
      //   return '日本語';
      // case 'de':
      //   return 'Deutsch';
      // case 'it':
      //   return 'Italiano';
      // case 'ko':
      //   return '한국어';
      // case 'vi':
      //   return 'Tiếng Việt';
      // case 'tr':
      //   return 'Türkçe';
      // case 'pl':
      //   return 'Polski';
      // case 'id':
      //   return 'Bahasa Indonesia';
      default:
        return 'English';
    }
  }
}
