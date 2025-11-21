class AppConstants {
  const AppConstants._();

  // Shared Preferences Keys
  static const String languageKey = "language_key";
  static const String themeKey = "theme_key";
  static const String userDataKey = "user_data_key";
  static const String onboardingKey = "onboarding_key";
  // Paymob Configuration (New Payment Intentions API)
  static const String paymobPublicKey =
      "egy_pk_test_yeg3HyiiIFEa8SUG6VSVusK9EJuQcGXn";
  static const String paymobSecretKey =
      "egy_sk_test_a7f0ce69562e57d2e369da4742eec097e926fdedce73ca1f21500ba29be22385";
  static const String paymobHmac = "1F1F0ADBFCD4EBE5BFE0E78C1DCA5BD5";
  static const String paymobBaseUrl = "https://accept.paymob.com";
  static const int paymobIntegrationIdCard = 4949814; // Online Card
  static const int paymobIntegrationIdWallet = 4949823; // Mobile Wallet
  static const int paymobIntegrationIdValu = 0; // Valu (if available)

  // Legacy API Key (deprecated - keeping for backward compatibility)
  static const String apiKeyForPaymob =
      "ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRBeU16QXhNaXdpYm1GdFpTSTZJbWx1YVhScFlXd2lmUS5Vd3JNYlVVYno3NGZyUDZnS0dZR05XUUw4REtnU0dSSFVUTF9KYVJvVE9kNDU3MGc3NVlXUEdBeklMTTNITU5lbGN3Q2lNbDVBakl4T3NHRVJvNTBQQQ==";
}

class StorageKeys {
  const StorageKeys._();

  // Key for onboarding
  static const String hasSeenOnboarding = 'has_seen_onboarding';

  // Auth Related
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String googleIdToken = 'google_id_token';
  static const String userId = 'user_id';
  static const String isLoggedIn = 'is_logged_in';
  static const String isLoggedInAsGoogle = 'is_logged_in_as_google';

  // Payment Related
  static const String savedCards = 'saved_cards';
  static const String isSubscribed = 'is_subscribed';
}

// api_keys.dart
class ApiKeys {
  const ApiKeys._();

  // Common Response Keys
  static const String status = 'status';
  static const String message = 'message';
  static const String error = 'error';
  static const String data = 'data';

  // Auth Related
  static const String token = 'token';
  static const String refreshToken = 'refreshToken';

  // User Related
  static const String id = 'id';
  static const String email = 'email';
  static const String password = 'password';
  static const String confirmPassword = 'confirmPassword';
  static const String name = 'name';
  static const String phone = 'phone';
  static const String location = 'location';
  static const String profilePic = 'profilePicture';
}
