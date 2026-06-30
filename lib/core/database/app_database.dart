import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../constants/app_constants.dart';
import 'daos/complaints_dao.dart';
import 'daos/recordings_dao.dart';
import 'daos/settings_dao.dart';

part 'app_database.g.dart';

// ============ TABLE DEFINITIONS ============

class Complaints extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get customerName => text()();
  TextColumn get phoneNumber => text()();
  TextColumn get applianceType => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get recordingPath => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('Pending'))();
  RealColumn get amountEarned => real().nullable()();
  RealColumn get amountCollected => real().nullable()();
  RealColumn get amountPending => real().nullable()();
  TextColumn get completionNotes => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get rejectedAt => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [];

  @override
  List<String> get customConstraints => [];
}

class ProcessedRecordings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get filePath => text().unique()();
  TextColumn get phoneNumber => text()();
  IntColumn get recordedAt => integer()();
  IntColumn get complaintId => integer().nullable().references(Complaints, #id)();
  IntColumn get markedAt => integer()();
}

class DiscardedRecordings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get filePath => text().unique()();
  TextColumn get phoneNumber => text()();
  IntColumn get recordedAt => integer()();
  IntColumn get discardedAt => integer()();
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {key};
}

// ============ DATABASE ============

@DriftDatabase(
  tables: [Complaints, ProcessedRecordings, DiscardedRecordings, AppSettings],
  daos: [ComplaintsDao, RecordingsDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => AppConstants.databaseVersion;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: AppConstants.databaseName,
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  static Future<void> _migrateOldDatabaseFile() async {
    try {
      final oldPath = '${(await getApplicationDocumentsDirectory()).path}/${AppConstants.databaseName}.sqlite';
      final newPath = '${(await getApplicationSupportDirectory()).path}/${AppConstants.databaseName}';
      
      final oldFile = File(oldPath);
      final newFile = File(newPath);
      
      if (await oldFile.exists() && !await newFile.exists()) {
        // Copy database file
        await oldFile.copy(newPath);
        
        // Also copy WAL and SHM files if they exist
        final oldWal = File('$oldPath-wal');
        final oldShm = File('$oldPath-shm');
        if (await oldWal.exists()) {
          await oldWal.copy('$newPath-wal');
        }
        if (await oldShm.exists()) {
          await oldShm.copy('$newPath-shm');
        }
      }
    } catch (_) {}
  }

  // Simpler constructor for production use
  AppDatabase.connect(super.connection);

  static AppDatabase create() {
    return AppDatabase.connect(_openConnection());
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Initialize default settings
          await into(appSettings).insert(AppSettingsCompanion.insert(
            key: AppConstants.keyRecordingFolderPath,
            value: '',
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ));
          await into(appSettings).insert(AppSettingsCompanion.insert(
            key: AppConstants.keyLastScanTimestamp,
            value: '0',
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ));
          await into(appSettings).insert(AppSettingsCompanion.insert(
            key: AppConstants.keyDbVersion,
            value: '1',
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ));
          await into(appSettings).insert(AppSettingsCompanion.insert(
            key: AppConstants.keyAutoBackupFolderPath,
            value: '',
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ));
          await into(appSettings).insert(AppSettingsCompanion.insert(
            key: AppConstants.keyLastAutoBackupTimestamp,
            value: '0',
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ));
        },
        onUpgrade: (m, from, to) async {
          if (from < 3) {
            try {
              await m.addColumn(complaints, complaints.amountCollected);
            } catch (_) {}
            try {
              await m.addColumn(complaints, complaints.amountPending);
            } catch (_) {}
          }
          if (from < 4) {
            try {
              await m.addColumn(complaints, complaints.imagePath);
            } catch (_) {}
          }
        },
      );

  /// Get the database file path for backup/restore
  static String get databasePath => AppConstants.databaseName;
}
