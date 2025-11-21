import '../constants/constants.dart';
import 'shared_pref_helper.dart';

class OnboardingManager {
  /// Check if user has already seen the onboarding screens
  static Future<bool> hasSeenOnboarding() async {
    return await SharedPrefHelper.getBool(StorageKeys.hasSeenOnboarding);
  }

  /// Save that user has seen the onboarding screens
  static Future<void> markOnboardingAsSeen() async {
    await SharedPrefHelper.setData(StorageKeys.hasSeenOnboarding, true);
  }
}
