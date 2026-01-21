import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  // private constructor as I don't want to allow creating an instance of this class itself.
  SharedPrefHelper._();
  static final ValueNotifier<bool> fastingUpdateNotifier = ValueNotifier(false);

  // استخدام إعدادات موحدة لـ FlutterSecureStorage في كل مكان
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
  );

  /// Removes a value from SharedPreferences with given [key].
  static removeData(String key) async {
    debugPrint('SharedPrefHelper : data with key : $key has been removed');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove(key);
  }

  /// Removes all keys and values in the SharedPreferences
  static clearAllData() async {
    debugPrint('SharedPrefHelper : all data has been cleared');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
  }

  /// Saves a [value] with a [key] in the SharedPreferences.
  static Future<void> setData(String key, dynamic value) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      debugPrint(
        "SharedPrefHelper : setData with key : $key and value : $value",
      );

      switch (value.runtimeType) {
        case String:
          await sharedPreferences.setString(key, value);
          break;
        case int:
          await sharedPreferences.setInt(key, value);
          break;
        case bool:
          await sharedPreferences.setBool(key, value);
          break;
        case double:
          await sharedPreferences.setDouble(key, value);
          break;
        default:
          return;
      }
    } catch (e) {
      debugPrint("Error saving data: $e");
    }
  }

  /// Gets a bool value from SharedPreferences with given [key].
  static getBool(String key) async {
    debugPrint('SharedPrefHelper : getBool with key : $key');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(key) ?? false;
  }

  /// Gets a double value from SharedPreferences with given [key].
  static getDouble(String key) async {
    debugPrint('SharedPrefHelper : getDouble with key : $key');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getDouble(key) ?? 0.0;
  }

  /// Gets an int value from SharedPreferences with given [key].
  static getInt(String key) async {
    debugPrint('SharedPrefHelper : getInt with key : $key');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getInt(key) ?? 0;
  }

  /// Gets an String value from SharedPreferences with given [key].
  static getString(String key) async {
    debugPrint('SharedPrefHelper : getString with key : $key');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(key) ?? '';
  }

  /// Saves a [value] with a [key] in the FlutterSecureStorage.
  static Future<void> setSecuredString(String key, String value) async {
    try {
      debugPrint("FlutterSecureStorage : setSecuredString with key : $key");
      await _secureStorage.write(key: key, value: value);

      // التحقق من الحفظ
      final saved = await _secureStorage.read(key: key);
      debugPrint(
        "FlutterSecureStorage : verification - saved value exists: ${saved != null}",
      );
    } catch (e) {
      debugPrint("FlutterSecureStorage : Error saving secured string: $e");
      rethrow;
    }
  }

  /// Gets an String value from FlutterSecureStorage with given [key].
  static Future<String> getSecuredString(String key) async {
    try {
      debugPrint('FlutterSecureStorage : getSecuredString with key : $key');
      final value = await _secureStorage.read(key: key);
      debugPrint(
        'FlutterSecureStorage : retrieved value exists: ${value != null}',
      );
      return value ?? '';
    } catch (e) {
      debugPrint('FlutterSecureStorage : Error getting secured string: $e');
      return '';
    }
  }

  /// Removes a specific key from FlutterSecureStorage
  static Future<void> removeSecuredString(String key) async {
    try {
      debugPrint('FlutterSecureStorage : removing key : $key');
      await _secureStorage.delete(key: key);
    } catch (e) {
      debugPrint('FlutterSecureStorage : Error removing secured string: $e');
    }
  }

  /// Removes all keys and values in the FlutterSecureStorage
  static clearAllSecuredData() async {
    try {
      debugPrint('FlutterSecureStorage : all data has been cleared');
      await _secureStorage.deleteAll();
    } catch (e) {
      debugPrint('FlutterSecureStorage : Error clearing all secured data: $e');
    }
  }

  /// Check if a key exists in FlutterSecureStorage
  static Future<bool> hasSecuredKey(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      return value != null;
    } catch (e) {
      debugPrint('FlutterSecureStorage : Error checking key existence: $e');
      return false;
    }
  }

  /// Get all keys from FlutterSecureStorage (for debugging)
  static Future<Map<String, String>> getAllSecuredData() async {
    try {
      return await _secureStorage.readAll();
    } catch (e) {
      debugPrint('FlutterSecureStorage : Error getting all secured data: $e');
      return {};
    }
  }

  // ==================== Auth Related Methods ====================

  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';
  static const String _userIdKey = 'user_id';

  /// Save login state
  static Future<void> saveLoginState({
    required bool isLoggedIn,
    String? email,
    String? userId,
  }) async {
    await setData(_isLoggedInKey, isLoggedIn);
    if (email != null) {
      await setSecuredString(_userEmailKey, email);
    }
    if (userId != null) {
      await setSecuredString(_userIdKey, userId);
    }
    debugPrint(
      'SharedPrefHelper : Login state saved - isLoggedIn: $isLoggedIn',
    );
  }

  /// Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    return await getBool(_isLoggedInKey);
  }

  /// Get user email
  static Future<String> getUserEmail() async {
    return await getSecuredString(_userEmailKey);
  }

  /// Get user ID
  static Future<String> getUserId() async {
    return await getSecuredString(_userIdKey);
  }

  /// Clear login data (for logout) 
  static Future<void> clearLoginData() async {
    await setData(_isLoggedInKey, false);
    await removeSecuredString(_userEmailKey);
    await removeSecuredString(_userIdKey);
        await clearFastingData(); 

    debugPrint('SharedPrefHelper : Login data cleared');
  }

  // ==================== Fasting Feature Keys ====================
  static const String _fastingStartHour = 'fasting_start_hour';
  static const String _fastingStartMinute = 'fasting_start_minute';
  static const String _fastingDuration = 'fasting_duration';

  /// دالة لحفظ بيانات الصيام دفعة واحدة
  static Future<void> saveFastingData(TimeOfDay startTime, int duration) async {
    await setData(_fastingStartHour, startTime.hour);
    await setData(_fastingStartMinute, startTime.minute);
    await setData(_fastingDuration, duration);
    fastingUpdateNotifier.value = !fastingUpdateNotifier.value;
    debugPrint('SharedPrefHelper : Fasting data saved');
  }

  /// دالة لاسترجاع وقت البدء (تعيد null إذا لم يتم الحفظ مسبقاً)
  static Future<TimeOfDay?> getFastingStartTime() async {
    int hour = await getInt(_fastingStartHour); // إذا لم يوجد سيعيد 0
    int minute = await getInt(_fastingStartMinute);
    
    // لنتأكد هل تم الحفظ فعلاً أم أنها القيم الافتراضية؟ 
    // (هنا سنفترض ببساطة أنه سيعيد الوقت، ولتجاوز التعقيد سنعتمد على القيم الموجودة)
    // ملاحظة: SharedPreferences تعيد 0 كقيمة افتراضية للـ int
    
    // للتأكد 100% يفضل فحص إذا كان المفتاح موجوداً، لكن للتبسيط:
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_fastingStartHour)) return null;
    
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// دالة لاسترجاع مدة الصيام
  static Future<int> getFastingDuration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_fastingDuration) ?? 8; // القيمة الافتراضية 8 ساعات
  }
 
/// ✅ دالة حذف بيانات الصيام (أضف هذا الجزء)
  static Future<void> clearFastingData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // 1. حذف جميع المفاتيح المتعلقة بالصيام
    await prefs.remove(_fastingStartHour);
    await prefs.remove(_fastingStartMinute);
    await prefs.remove(_fastingDuration);

    // 2. إشعار الواجهة (UI) بأن الحالة تغيرت ليتم تحديثها فوراً
    // هذا السطر مهم جداً لأنه يخبر الـ ValueListenableBuilder بإعادة بناء نفسه
    fastingUpdateNotifier.value = !fastingUpdateNotifier.value;
    
    debugPrint('SharedPrefHelper : Fasting data cleared successfully');
  }
}
