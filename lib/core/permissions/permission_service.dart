import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:logger/logger.dart';

class PermissionService {
  PermissionService({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;

  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    final results = <Permission, PermissionStatus>{};
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    // Storage permissions
    if (sdkInt >= 33) {
      // Android 13+: use READ_MEDIA_AUDIO
      results[Permission.audio] = await Permission.audio.request();
    } else if (sdkInt >= 30) {
      // Android 11-12: need MANAGE_EXTERNAL_STORAGE for MIUI folder
      results[Permission.manageExternalStorage] =
          await Permission.manageExternalStorage.request();
    } else {
      // Android 8-10
      results[Permission.storage] = await Permission.storage.request();
    }

    // Always request MANAGE_EXTERNAL_STORAGE for MIUI recording access
    if (sdkInt >= 30) {
      final manageStatus = await Permission.manageExternalStorage.status;
      if (!manageStatus.isGranted) {
        results[Permission.manageExternalStorage] =
            await Permission.manageExternalStorage.request();
      }
    }

    // Call log / Phone
    results[Permission.phone] = await Permission.phone.request();
    
    // Contacts
    results[Permission.contacts] = await Permission.contacts.request();

    _logger.d('Permission results: $results');
    return results;
  }

  Future<bool> hasAllRequiredPermissions() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    // Check storage
    bool hasStorage = false;
    if (sdkInt >= 30) {
      hasStorage = await Permission.manageExternalStorage.isGranted;
    } else {
      hasStorage = await Permission.storage.isGranted;
    }

    final hasPhone = await Permission.phone.isGranted;
    final hasContacts = await Permission.contacts.isGranted;

    return hasStorage && hasPhone && hasContacts;
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}
