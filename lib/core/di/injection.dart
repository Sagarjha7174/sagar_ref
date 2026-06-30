import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_database.dart';
import '../database/daos/complaints_dao.dart';
import '../database/daos/recordings_dao.dart';
import '../database/daos/settings_dao.dart';
import '../permissions/permission_service.dart';
import '../../features/recordings/data/datasources/recording_filename_parser.dart';
import '../../features/recordings/data/datasources/recording_scanner_service.dart';
import '../../features/recordings/data/datasources/recording_scan_cache_service.dart';
import '../../features/recordings/data/datasources/call_log_matcher.dart';
import '../../features/recordings/data/datasources/contact_lookup_service.dart';
import '../../features/settings/data/datasources/google_drive_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Logger
  getIt.registerSingleton<Logger>(Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
    ),
  ));

  // Shared Preferences
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Database
  final db = AppDatabase.create();
  getIt.registerSingleton<AppDatabase>(db);

  // DAOs
  getIt.registerSingleton<ComplaintsDao>(ComplaintsDao(db));
  getIt.registerSingleton<RecordingsDao>(RecordingsDao(db));
  getIt.registerSingleton<SettingsDao>(SettingsDao(db));

  // Services
  getIt.registerSingleton<PermissionService>(
    PermissionService(logger: getIt<Logger>()),
  );
  getIt.registerLazySingleton<RecordingFilenameParser>(
    () => RecordingFilenameParser(),
  );
  getIt.registerLazySingleton<RecordingScannerService>(
    () => RecordingScannerService(
      parser: getIt<RecordingFilenameParser>(),
      recordingsDao: getIt<RecordingsDao>(),
      logger: getIt<Logger>(),
    ),
  );
  getIt.registerLazySingleton<RecordingScanCacheService>(
    () => RecordingScanCacheService(
      prefs: getIt<SharedPreferences>(),
      logger: getIt<Logger>(),
    ),
  );
  getIt.registerLazySingleton<CallLogMatcher>(
    () => CallLogMatcher(),
  );
  getIt.registerLazySingleton<ContactLookupService>(
    () => ContactLookupService(),
  );
  getIt.registerLazySingleton<GoogleDriveService>(
    () => GoogleDriveService(),
  );
}
