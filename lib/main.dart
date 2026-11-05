import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/background/background_backup.dart';
import 'core/di/injection.dart';
import 'app/app.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'core/database/daos/settings_dao.dart';
import 'core/database/daos/complaints_dao.dart';
import 'core/database/app_database.dart';
import 'features/settings/data/datasources/google_drive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Enable edge-to-edge full screen
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );

  await configureDependencies();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );

  // Daily backup check in the background job (Android) ...
  scheduleBackgroundBackup();

  // ... and once on every start, which also retries a failed Drive upload.
  // Never shows UI; runs after the first frame so startup isn't slowed.
  SettingsRepositoryImpl(
    settingsDao: getIt<SettingsDao>(),
    complaintsDao: getIt<ComplaintsDao>(),
    database: getIt<AppDatabase>(),
    googleDriveService: getIt<GoogleDriveService>(),
  ).checkAndPerformAutoBackup().catchError((e) {
    debugPrint('Error performing automatic backup during startup: $e');
    return false;
  });
}
