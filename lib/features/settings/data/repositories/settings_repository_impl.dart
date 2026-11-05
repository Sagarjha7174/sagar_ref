import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
import '../../domain/repositories/settings_repository.dart';
import '../datasources/google_drive_service.dart';

/// Result of one backup run.
class _BackupOutcome {
  String? localPath;
  String? localError;
  bool signedIn = false;
  bool uploaded = false;
  String? cloudError;
}

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

  /// Serializes backup/restore work across all repository instances in this
  /// isolate (main.dart, Riverpod and Settings each create one), so two
  /// backups never write the same files at once.
  static Future<void> _queue = Future.value();

  static Future<T> _serialized<T>(Future<T> Function() task) {
    final completer = Completer<T>();
    _queue = _queue.then((_) async {
      try {
        completer.complete(await task());
      } catch (e, s) {
        completer.completeError(e, s);
      }
    });
    return completer.future;
  }

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

  // ===== DATABASE FILE HELPERS =====

  /// Path of the database file the app actually has open, as reported by
  /// SQLite itself. Falls back to drift_flutter's default location.
  Future<String> _liveDatabasePath() async {
    try {
      final rows = await _database.customSelect('PRAGMA database_list').get();
      for (final row in rows) {
        if (row.data['name'] == 'main') {
          final file = row.data['file'] as String?;
          if (file != null && file.isNotEmpty) return file;
        }
      }
    } catch (_) {
      // Database closed or unavailable: use the default location.
    }
    // drift_flutter default: <documents>/<name>.sqlite
    return p.join(
      (await getApplicationDocumentsDirectory()).path,
      '${AppConstants.databaseName}.sqlite',
    );
  }

  static Future<bool> _isSqliteFile(File file) async {
    try {
      if (!await file.exists() || await file.length() < 100) return false;
      final raf = await file.open();
      try {
        final header = await raf.read(16);
        return String.fromCharCodes(header) == 'SQLite format 3\u0000';
      } finally {
        await raf.close();
      }
    } catch (_) {
      return false;
    }
  }

  static Future<void> _deleteIfExists(String path) async {
    final f = File(path);
    if (await f.exists()) await f.delete();
  }

  /// Writes a consistent, self-contained copy of the open database to
  /// [targetPath] using `VACUUM INTO`. Safe while the app is reading/writing,
  /// and includes changes still in the WAL. Produces no -wal/-shm files.
  Future<void> _snapshotTo(String targetPath) async {
    await Directory(p.dirname(targetPath)).create(recursive: true);
    await _deleteIfExists(targetPath); // VACUUM INTO refuses existing files
    await _database.customStatement('VACUUM INTO ?', [targetPath]);
    if (!await _isSqliteFile(File(targetPath))) {
      throw const BackupFailure('Backup snapshot is not a valid database');
    }
  }

  /// Snapshot in the app's temp dir, named like the backup so the Drive file
  /// keeps the same name.
  Future<File> _createSnapshot() async {
    final tmp = await getTemporaryDirectory();
    final path = p.join(tmp.path, 'backup', AppConstants.backupFileName);
    await _snapshotTo(path);
    return File(path);
  }

  /// Copies [snapshot] into [folder] atomically (temp file + rename), so an
  /// interrupted copy never leaves a half-written backup.
  Future<String> _writeLocalCopy(File snapshot, String folder) async {
    final dir = Directory(folder);
    if (!await dir.exists()) await dir.create(recursive: true);

    final dest = p.join(folder, AppConstants.backupFileName);
    final tmp = '$dest.tmp';
    await snapshot.copy(tmp);
    await File(tmp).rename(dest);

    // Older versions copied -wal/-shm next to the backup. A stale one could
    // be applied on restore, so remove them.
    for (final suffix in const ['-wal', '-shm', '-journal']) {
      await _deleteIfExists('$dest$suffix');
    }
    return dest;
  }

  Future<DateTime?> _readTime(String key) async {
    final ms = int.tryParse(await _settingsDao.getValue(key) ?? '');
    return ms == null || ms == 0 ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> _writeTime(String key, DateTime time) =>
      _settingsDao.setValue(key, time.millisecondsSinceEpoch.toString());

  // ===== BACKUP =====

  Future<_BackupOutcome> _runBackup({
    required String? folder,
    required bool interactive,
  }) async {
    final outcome = _BackupOutcome();
    final hasFolder = folder != null && folder.isNotEmpty;
    outcome.signedIn = await _googleDriveService.isSignedIn;

    if (!hasFolder && !outcome.signedIn) {
      throw const BackupFailure(
        'Choose a backup folder or sign in to Google Drive first.',
      );
    }

    final snapshot = await _createSnapshot();
    try {
      if (hasFolder) {
        try {
          outcome.localPath = await _writeLocalCopy(snapshot, folder);
          await _writeTime(AppConstants.keyLastAutoBackupTimestamp, DateTime.now());
        } catch (e) {
          outcome.localError = 'Could not write to backup folder: $e';
          debugPrint(outcome.localError);
        }
      }

      if (outcome.signedIn) {
        try {
          await _googleDriveService.uploadBackup(
            snapshot.path,
            interactive: interactive,
          );
          outcome.uploaded = true;
          await _writeTime(AppConstants.keyLastCloudUploadTimestamp, DateTime.now());
          await _settingsDao.setValue(AppConstants.keyLastCloudUploadError, '');
        } on DriveBackupException catch (e) {
          outcome.cloudError = e.message;
          await _settingsDao.setValue(AppConstants.keyLastCloudUploadError, e.message);
          debugPrint('Google Drive upload failed: ${e.message}');
        }
      }
    } finally {
      await _deleteIfExists(snapshot.path);
    }
    return outcome;
  }

  @override
  Future<Result<String>> backupDatabase(String? destinationDir) {
    return _serialized(() async {
      try {
        final o = await _runBackup(folder: destinationDir, interactive: true);

        if (o.localPath == null && !o.uploaded) {
          return Result.failure(BackupFailure(
            [o.localError, o.cloudError].whereType<String>().join('\n'),
          ));
        }

        final lines = <String>[
          if (o.localPath != null) '✅ Saved to ${o.localPath}',
          if (o.localError != null) '❌ ${o.localError}',
          if (o.uploaded) '✅ Uploaded to Google Drive',
          if (o.cloudError != null) '❌ Google Drive: ${o.cloudError}',
          if (!o.signedIn) 'ℹ️ Sign in to Google Drive to also back up online.',
        ];
        return Result.success(lines.join('\n'));
      } on BackupFailure catch (f) {
        return Result.failure(f);
      } catch (e) {
        return Result.failure(BackupFailure('Backup failed: $e'));
      }
    });
  }

  @override
  Future<bool> checkAndPerformAutoBackup() {
    return _serialized(() async {
      try {
        final folder = await getAutoBackupFolderPath();
        final hasFolder = folder != null && folder.isNotEmpty;
        final signedIn = await _googleDriveService.isSignedIn;
        if (!hasFolder && !signedIn) return true; // nothing configured

        final now = DateTime.now();
        bool isDue(DateTime? last) =>
            last == null ||
            last.isAfter(now) || // clock was changed
            now.difference(last) >= AppConstants.autoBackupInterval;

        final localDue = hasFolder &&
            isDue(await _readTime(AppConstants.keyLastAutoBackupTimestamp));
        // A failed upload never advances this time, so it is retried on the
        // next app start / background run instead of waiting a whole day.
        final cloudDue = signedIn &&
            isDue(await _readTime(AppConstants.keyLastCloudUploadTimestamp));

        if (!localDue && !cloudDue) return true;

        final o = await _runBackup(folder: folder, interactive: false);
        final ok = (!hasFolder || o.localPath != null) &&
            (!signedIn || o.uploaded);
        debugPrint('Auto backup: local=${o.localPath ?? o.localError}, '
            'cloud=${o.uploaded ? 'uploaded' : o.cloudError ?? 'skipped'}');
        return ok;
      } catch (e) {
        debugPrint('Automatic backup failed: $e');
        return false;
      }
    });
  }

  @override
  Future<BackupStatus> getBackupStatus() async {
    final folder = await getAutoBackupFolderPath();
    final error = await _settingsDao.getValue(AppConstants.keyLastCloudUploadError);
    return BackupStatus(
      signedIn: await _googleDriveService.isSignedIn,
      localFolderSet: folder != null && folder.isNotEmpty,
      lastLocalBackup: await _readTime(AppConstants.keyLastAutoBackupTimestamp),
      lastCloudUpload: await _readTime(AppConstants.keyLastCloudUploadTimestamp),
      lastCloudError: (error == null || error.isEmpty) ? null : error,
    );
  }

  // ===== RESTORE =====

  @override
  Future<Result<void>> restoreDatabase(String sourceFilePath) {
    return _serialized(() => _restore(sourceFilePath));
  }

  Future<Result<void>> _restore(String sourceFilePath) async {
    try {
      final source = File(sourceFilePath);
      if (!await source.exists()) {
        return Result.failure(const FileNotFoundFailure('Backup file not found'));
      }
      if (!await _isSqliteFile(source)) {
        return Result.failure(const BackupFailure(
          'This file is not a valid backup. Choose a ".db" backup file.',
        ));
      }

      final dbPath = await _liveDatabasePath();

      // Keep a copy of the current data so a wrong restore can be undone.
      try {
        final docs = await getApplicationDocumentsDirectory();
        await _snapshotTo(p.join(docs.path, 'before_restore.db'));
      } catch (e) {
        debugPrint('Could not save pre-restore copy: $e');
      }

      // Stage the new file next to the live one first; if this copy fails the
      // current database is untouched.
      final staged = '$dbPath.restore';
      await source.copy(staged);

      // Older backups may have a -wal written together with the .db; it holds
      // recent changes. Only trust it if it is not older than the .db (a
      // leftover from an earlier backup would be).
      final sourceWal = File('$sourceFilePath-wal');
      final useWal = await sourceWal.exists() &&
          !(await sourceWal.lastModified()).isBefore(
            (await source.lastModified()).subtract(const Duration(seconds: 5)),
          );

      // Release the native file handle before replacing the file.
      await _database.close();

      for (final suffix in const ['-wal', '-shm', '-journal']) {
        await _deleteIfExists('$dbPath$suffix');
      }
      await File(staged).rename(dbPath);
      if (useWal) await sourceWal.copy('$dbPath-wal');

      return Result.success(null);
    } catch (e) {
      return Result.failure(BackupFailure('Restore failed: $e'));
    }
  }

  @override
  Future<Result<CloudBackupInfo?>> getCloudBackupInfo() async {
    try {
      final info = await _googleDriveService.getBackupInfo(
        AppConstants.backupFileName,
      );
      return Result.success(info == null
          ? null
          : CloudBackupInfo(
              modifiedTime: info.modifiedTime,
              sizeBytes: info.sizeBytes,
            ));
    } on DriveBackupException catch (e) {
      return Result.failure(BackupFailure(e.message));
    } catch (e) {
      return Result.failure(BackupFailure('Could not check Google Drive: $e'));
    }
  }

  @override
  Future<Result<void>> restoreFromCloud() {
    return _serialized(() async {
      String? downloaded;
      try {
        final tmp = await getTemporaryDirectory();
        downloaded = p.join(tmp.path, 'drive_restore', AppConstants.backupFileName);
        await Directory(p.dirname(downloaded)).create(recursive: true);

        final info = await _googleDriveService.downloadBackup(
          AppConstants.backupFileName,
          downloaded,
        );
        if (info == null) {
          return Result.failure(
            const BackupFailure('No backup found on Google Drive.'),
          );
        }
        return await _restore(downloaded);
      } on DriveBackupException catch (e) {
        return Result.failure(BackupFailure(e.message));
      } catch (e) {
        return Result.failure(BackupFailure('Restore from Drive failed: $e'));
      } finally {
        if (downloaded != null) await _deleteIfExists(downloaded);
      }
    });
  }

  // ===== SETTINGS =====

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
  Future<bool> signInToCloud() async {
    final account = await _googleDriveService.signIn();
    return account != null;
  }

  @override
  Future<void> signOutFromCloud() async {
    await _googleDriveService.signOut();
    await _settingsDao.setValue(AppConstants.keyLastCloudUploadError, '');
  }

  @override
  Future<bool> isCloudSignedIn() async {
    return await _googleDriveService.isSignedIn;
  }
}
