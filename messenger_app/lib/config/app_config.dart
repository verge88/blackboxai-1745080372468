class AppConfig {
  // App name
  static const String appName = 'Messenger App';
  
  // API endpoints (if needed for custom backend)
  static const String baseUrl = '';
  
  // Firebase configuration
  static const String firebaseProjectId = 'messenger-app-12345';
  static const String firebaseMessagingSenderId = '123456789012';
  static const String firebaseAppId = '1:123456789012:web:abcdef1234567890';
  
  // App settings
  static const bool enableLogging = true;
  static const int messageFetchLimit = 50;
  
  // UI settings
  static const Duration messageAnimationDuration = Duration(milliseconds: 300);
  static const Duration chatListRefreshInterval = Duration(seconds: 30);
}