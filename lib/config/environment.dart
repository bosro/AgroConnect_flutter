// lib/config/environment.dart
enum Environment { development, staging, production }

class EnvironmentConfig {
  static const Environment _environment = Environment.production; // Change as needed
  
  static Environment get environment => _environment;
  static bool get isProduction => _environment == Environment.production;
  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  
  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        return 'https://dev-api.farmerfriendsghana.com';
      case Environment.staging:
        return 'https://staging-api.farmerfriendsghana.com';
      case Environment.production:
        return 'https://api.farmerfriendsghana.com';
    }
  }
  
  static String get firebaseProjectId {
    switch (_environment) {
      case Environment.development:
        return 'farmer-friends-dev';
      case Environment.staging:
        return 'farmer-friends-staging';
      case Environment.production:
        return 'farmer-friends-prod';
    }
  }
}