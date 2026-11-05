import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import '../../features/settings/data/datasources/google_drive_service.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../database/app_database.dart';
import '../database/daos/complaints_dao.dart';
import '../database/daos/settings_dao.dart';

const String autoBackupTaskName = 'sagar_auto_backup';

/// Entry point for Android WorkManager. Runs in a separate Flutter engine
/// without the app's UI or DI container, so it builds what it needs itself.
@pragma('vm:entry-point')
void backgroundCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != autoBackupTaskName) return true;

    DartPluginRegistrant.ensureInitialized();
    final db = AppDatabase.create();
    try {
      final repo = SettingsRepositoryImpl(
        settingsDao: SettingsDao(db),
        complaintsDao: ComplaintsDao(db),
        database: db,
        googleDriveService: GoogleDriveService(),
      );
      // false -> WorkManager retries with backoff.
      return await repo.checkAndPerformAutoBackup();
    } catch (e) {
      debugPrint('Background backup failed: $e');
      return false;
    } finally {
      await db.close();
    }
  });
}

/// Schedules the periodic backup check. The job itself only does work when a
/// backup is due (see SettingsRepositoryImpl.checkAndPerformAutoBackup), so
/// running every few hours just means failed uploads are retried sooner.
Future<void> scheduleBackgroundBackup() async {
  if (kIsWeb || !Platform.isAndroid) return;
  try {
    await Workmanager().initialize(backgroundCallbackDispatcher);
    await Workmanager().registerPeriodicTask(
      autoBackupTaskName,
      autoBackupTaskName,
      frequency: const Duration(hours: 6),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: true,
        requiresStorageNotLow: true,
      ),
    );
  } catch (e) {
    debugPrint('Could not schedule background backup: $e');
  }
}
