// lib/services/update_service.dart
import 'package:in_app_update/in_app_update.dart';

class UpdateService {
  static Future<void> checkForUpdates() async {
    try {
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          // Perform immediate update
          await InAppUpdate.performImmediateUpdate();
        } else if (updateInfo.flexibleUpdateAllowed) {
          // Perform flexible update
          await InAppUpdate.startFlexibleUpdate();
        }
      }
    } catch (e) {
      print('Update check failed: $e');
    }
  }

  static Future<void> completeFlexibleUpdate() async {
    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e) {
      print('Failed to complete flexible update: $e');
    }
  }
}