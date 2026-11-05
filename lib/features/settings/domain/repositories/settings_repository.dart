import '../../../../core/errors/result.dart';

/// Current state of local + Google Drive backups, for display in Settings.
class BackupStatus {
  const BackupStatus({
    required this.signedIn,
    required this.localFolderSet,
    this.lastLocalBackup,
    this.lastCloudUpload,
    this.lastCloudError,
  });

  final bool signedIn;
  final bool localFolderSet;
  final DateTime? lastLocalBackup;
  final DateTime? lastCloudUpload;

  /// Message of the last failed Drive upload; null once an upload succeeds.
  final String? lastCloudError;

  /// Signed in but the latest upload failed (it will be retried).
  bool get cloudUploadPending => signedIn && lastCloudError != null;
}

/// A backup stored on Google Drive.
class CloudBackupInfo {
  const CloudBackupInfo({this.modifiedTime, this.sizeBytes});

  final DateTime? modifiedTime;
  final int? sizeBytes;
}

abstract class SettingsRepository {
  Future<String?> getRecordingFolderPath();
  Future<void> setRecordingFolderPath(String path);
  Stream<String?> watchRecordingFolderPath();
  Future<Result<String>> exportComplaintsCsv();

  /// Manual backup: writes to the local backup folder (if set) and uploads to
  /// Google Drive (if signed in). Returns a user-facing summary.
  Future<Result<String>> backupDatabase(String? destinationDir);
  Future<Result<void>> restoreDatabase(String sourceFilePath);

  // Auto Backup
  Future<String?> getAutoBackupFolderPath();
  Future<void> setAutoBackupFolderPath(String path);
  Stream<String?> watchAutoBackupFolderPath();

  /// Runs a backup if one is due (24h since the last local backup or the last
  /// successful Drive upload). Never shows UI. Returns false if a due backup
  /// failed, so a background scheduler can retry.
  Future<bool> checkAndPerformAutoBackup();
  Future<BackupStatus> getBackupStatus();

  // Cloud Backup
  Future<bool> signInToCloud();
  Future<void> signOutFromCloud();
  Future<bool> isCloudSignedIn();
  Future<Result<CloudBackupInfo?>> getCloudBackupInfo();
  Future<Result<void>> restoreFromCloud();
}
