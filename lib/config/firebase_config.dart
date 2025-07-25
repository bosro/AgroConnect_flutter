// lib/config/firebase_config.dart
class FirebaseConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  
  static String get projectId => isProduction ? 'farmer-friends-prod' : 'farmer-friends-dev';
  
  static Map<String, dynamic> get androidConfig => {
    "project_info": {
      "project_number": isProduction ? "YOUR_PROD_PROJECT_NUMBER" : "YOUR_DEV_PROJECT_NUMBER",
      "project_id": projectId,
    },
    "client": [
      {
        "client_info": {
          "mobilesdk_app_id": isProduction ? "YOUR_PROD_APP_ID" : "YOUR_DEV_APP_ID",
          "android_client_info": {
            "package_name": "com.farmerfriendsghana.app"
          }
        }
      }
    ]
  };
}