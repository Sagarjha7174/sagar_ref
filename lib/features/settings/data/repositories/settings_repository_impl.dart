import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/complaints_dao.dart';
import '../../../../core/database/daos/settings_dao.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/utils/csv_utils.dart';
import '../../../complaints/data/models/complaint_model.dart';
import '../../../complaints/domain/entities/complaint.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/google_drive_service.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({
    required SettingsDao settingsDao,
    required ComplaintsDao complaintsDao,
    required AppDatabase database,
    required GoogleDriveService googleDriveService,
  })  : _settingsDao = settingsDao,
        _complaintsDao = complaintsDao,
        _database = database,
        _googleDriveService = googleDriveService;

  final SettingsDao _settingsDao;
  final ComplaintsDao _complaintsDao;
  final AppDatabase _database;
  final GoogleDriveService _googleDriveService;

  @override
  Future<String?> getRecordingFolderPath() {
    return _settingsDao.getValue(AppConstants.keyRecordingFolderPath);
  }

  @override
  Future<void> setRecordingFolderPath(String path) {
    return _settingsDao.setValue(AppConstants.keyRecordingFolderPath, path);
  }

  @override
  Stream<String?> watchRecordingFolderPath() {
    return _settingsDao.watchValue(AppConstants.keyRecordingFolderPath);
  }

  @override
  Future<Result<String>> exportComplaintsCsv() async {
    try {
      final complaints = await _complaintsDao.getAllComplaints();
      complaints.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final rows = <List<dynamic>>[
        AppConstants.csvHeaders,
        ...complaints.map((c) {
          final domain = c.toDomain();
          return [
            domain.customerName,
            domain.phoneNumber,
            domain.applianceTypes.map((e) => e.displayName).join(', '),
            domain.status.displayName,
            domain.amountEarned?.toString() ?? '',
            domain.notes ?? '',
            domain.createdAt.toDisplayDateTime(),
            domain.completedAt?.toDisplayDateTime() ?? '',
            domain.rejectedAt?.toDisplayDateTime() ?? '',
            domain.completionNotes ?? '',
          ];
        }),
      ];

      final csvString = CsvUtils.listToCsv(rows);
      final appDir = await getApplicationDocumentsDirectory();
      final exportDir = Directory(p.join(appDir.path, AppConstants.exportSubDir));
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toFileTimestamp();
      final filePath = p.join(exportDir.path, 'complaints_$timestamp.csv');
      final file = File(filePath);
      await file.writeAsString(csvString);

      return Result.success(filePath);
    } catch (e) {
      return Result.failure(ExportFailure('Export failed: $e'));
    }
  }

  Future<String?> _getDatabasePath() async {
    final names = [
      AppConstants.databaseName,
      '${AppConstants.databaseName}.sqlite',
    ];

    final paths = <String>[];
    for (final name in names) {
      paths.addAll([
        p.join((await getApplicationSupportDirectory()).path, name),
        p.join((await getApplicationDocumentsDirectory()).path, '..', 'databases', name),
        p.join((await getApplicationDocumentsDirectory()).path, name),
      ]);
    }

    for (final path in paths) {
      if (await File(path).exists()) {
        return path;
      }
    }

    // Try a recursive scan of app private directories to locate the database file
    try {
      final searchDirs = [
        await getApplicationSupportDirectory(),
        await getApplicationDocumentsDirectory(),
        Directory(p.join((await getApplicationDocumentsDirectory()).path, '..')),
      ];
      for (final dir in searchDirs) {
        if (await dir.exists()) {
          await for (final entity in dir.list(recursive: true, followLinks: false)) {
            if (entity is File) {
              final fileName = p.basename(entity.path);
              if (names.contains(fileName)) {
                return entity.path;
              }
            }
          }
        }
      }
    } catch (_) {}

    // Fallback default: first path
    if (paths.isNotEmpty) {
      return paths.first;
    }
    return null;
  }

  @override
  Future<Result<String>> backupDatabase(String destinationDir) async {
    try {
      final dbPath = await _getDatabasePath();
      if (dbPath == null) {
        return Result.failure(const BackupFailure('Database path not resolved'));
      }
      
      final dbFile = File(dbPath);
      if (!await dbFile.exists()) {
        return Result.failure(const BackupFailure('Database file not found'));
      }

      // User requested: overwrite auto backup file directly
      final backupPath = p.join(
        destinationDir,
        'sagar_refrig_auto_backup.db',
      );

      // Copy main database file
      await dbFile.copy(backupPath);
      
      // Also copy WAL and SHM files if they exist to keep the backup fully integral
      final walFile = File('$dbPath-wal');
      final shmFile = File('$dbPath-shm');
      if (await walFile.exists()) {
        await walFile.copy('$backupPath-wal');
      }
      if (await shmFile.exists()) {
        await shmFile.copy('$backupPath-shm');
      }

      // Upload to Google Drive automatically!
      bool cloudSuccess = false;
      bool signedIn = false;
      try {
        if (await _googleDriveService.isSignedIn) {
          signedIn = true;
          print('Starting automatic upload to Google Drive...');
          await _googleDriveService.uploadBackup(backupPath);
          cloudSuccess = true;
          print('Google Drive upload successful.');
        } else {
          print('Google Drive not signed in. Skipping cloud backup.');
        }
      } catch (uploadError) {
        print('Google Drive upload failed: $uploadError');
        // We don't fail the local backup if cloud backup fails, just log it.
      }

      String successMessage = backupPath;
      if (signedIn && cloudSuccess) {
        successMessage += '\n\n✅ Uploaded to Google Drive';
      } else if (signedIn && !cloudSuccess) {
        successMessage += '\n\n❌ Google Drive upload failed. Check internet.';
      }

      return Result.success(successMessage);
    } catch (e) {
      return Result.failure(BackupFailure('Backup failed: $e'));
    }
  }

  @override
  Future<Result<void>> restoreDatabase(String sourceFilePath) async {
    try {
      final sourceFile = File(sourceFilePath);
      if (!await sourceFile.exists()) {
        return Result.failure(const FileNotFoundFailure('Backup file not found'));
      }

      // Find the active database path
      final dbPath = await _getDatabasePath();
      if (dbPath == null) {
        return Result.failure(const BackupFailure('Could not resolve active database path'));
      }

      print('--- DATABASE RESTORE DIAGNOSTICS ---');
      print('Source path: $sourceFilePath');
      print('Source file size: ${await sourceFile.length()} bytes');
      print('Target active path: $dbPath');

      // Close current database connection to release native file locks
      await _database.close();

      // IMPORTANT: Actively delete existing WAL and SHM files to prevent SQLite
      // from rolling back or corrupting the newly restored database.
      final activeWal = File('$dbPath-wal');
      final activeShm = File('$dbPath-shm');
      if (await activeWal.exists()) await activeWal.delete();
      if (await activeShm.exists()) await activeShm.delete();

      // Copy source file to active database file directly
      await sourceFile.copy(dbPath);

      // Copy WAL and SHM files of the backup if they exist (though usually they don't in regular backups)
      final sourceWal = File('$sourceFilePath-wal');
      final sourceShm = File('$sourceFilePath-shm');
      if (await sourceWal.exists()) {
        await sourceWal.copy('$dbPath-wal');
      }
      if (await sourceShm.exists()) {
        await sourceShm.copy('$dbPath-shm');
      }

      print('Database files overwritten successfully!');
      print('--- END RESTORE DIAGNOSTICS ---');

      return Result.success(null);
    } catch (e) {
      return Result.failure(BackupFailure('Restore failed: $e'));
    }
  }

  @override
  Future<String?> getAutoBackupFolderPath() {
    return _settingsDao.getValue(AppConstants.keyAutoBackupFolderPath);
  }

  @override
  Future<void> setAutoBackupFolderPath(String path) {
    return _settingsDao.setValue(AppConstants.keyAutoBackupFolderPath, path);
  }

  @override
  Stream<String?> watchAutoBackupFolderPath() {
    return _settingsDao.watchValue(AppConstants.keyAutoBackupFolderPath);
  }

  @override
  Future<void> checkAndPerformAutoBackup() async {
    try {
      final folderPath = await getAutoBackupFolderPath();
      if (folderPath == null || folderPath.isEmpty) return;

      final lastBackupStr = await _settingsDao.getValue(AppConstants.keyLastAutoBackupTimestamp) ?? '0';
      final lastBackupMs = int.tryParse(lastBackupStr) ?? 0;
      final now = DateTime.now();

      // Check if 24 hours have passed since last backup
      final lastBackupTime = DateTime.fromMillisecondsSinceEpoch(lastBackupMs);
      if (now.difference(lastBackupTime).inHours >= 24) {
        final dbPath = await _getDatabasePath();
        if (dbPath == null) return;

        final dbFile = File(dbPath);
        if (!await dbFile.exists()) return;

        // Auto backup target folder and file
        final backupFolder = Directory(folderPath);
        if (!await backupFolder.exists()) {
          await backupFolder.create(recursive: true);
        }

        // Auto backup uses a fixed filename so it overwrites the old one
        final backupPath = p.join(folderPath, 'sagar_refrig_auto_backup.db');
        
        // Copy database file
        await dbFile.copy(backupPath);
        
        // Also copy WAL and SHM files if they exist to keep the backup fully integral
        final walFile = File('$dbPath-wal');
        final shmFile = File('$dbPath-shm');
        if (await walFile.exists()) {
          await walFile.copy('$backupPath-wal');
        }
        if (await shmFile.exists()) {
          await shmFile.copy('$backupPath-shm');
        }

        // Update last backup timestamp
        await _settingsDao.setValue(
          AppConstants.keyLastAutoBackupTimestamp,
          now.millisecondsSinceEpoch.toString(),
        );

        // Upload to Google Drive
        try {
          if (await _googleDriveService.isSignedIn) {
            print('Starting background auto-upload to Google Drive...');
            await _googleDriveService.uploadBackup(backupPath);
            print('Google Drive background upload successful.');
          }
        } catch (uploadError) {
          print('Google Drive background upload failed: $uploadError');
        }

        print('AUTOMATIC DAILY BACKUP COMPLETED SUCCESSFUL!');
      }
    } catch (e) {
      print('Automatic daily backup failed: $e');
    }
  }

  @override
  Future<bool> signInToCloud() async {
    final account = await _googleDriveService.signIn();
    return account != null;
  }

  @override
  Future<void> signOutFromCloud() async {
    await _googleDriveService.signOut();
  }

  @override
  Future<bool> isCloudSignedIn() async {
    return await _googleDriveService.isSignedIn;
  }
}
