class ApiConstants {
  static const String baseUrl = 'www.google.com/user';

  // API Endpoints
  //===============================================
  // Auth Endpoints
  static const String login = 'login';
  static const String signup = 'register';
  static const String verifyEmail = 'email-verify';
  static const String logout = 'logout';
  //==================================================
  // Get-Packages Endpoints
  static const String getPackages = 'get-packages';
  static const String subscribePackage = 'subscripe-package';
  //==================================================
  // Categories Endpoints
  static const String getCategories = 'get-categories';
  static const String getSuggestionVideos = '/get-sugg-videos';
  static const String getVideos = 'get-videos';
  static const String categoryLikes = 'cate-likes';
  //==================================================

  // User Profile Endpoints
  static const String getUserProfile = '/get-profile';
  static const String editUserProfile = '/edit-user';
  static const String getPassConfirmCode = '/get-pass-conf-code';
  static const String manageTimeActive = '/manage-time-active';
  static const String deleteTimeActive = '/del-time-active';
  static const String policy = 'setting';
  static const String deleteAccount = 'delete-account';
}
