import '../../../../core/errors/result.dart';

abstract class SettingsRepository {
  Future<String?> getRecordingFolderPath();
  Future<void> setRecordingFolderPath(String path);
  Stream<String?> watchRecordingFolderPath();
  Future<Result<String>> exportComplaintsCsv();
  Future<Result<String>> backupDatabase(String destinationDir);
  Future<Result<void>> restoreDatabase(String sourceFilePath);
  
  // Auto Backup
  Future<String?> getAutoBackupFolderPath();
  Future<void> setAutoBackupFolderPath(String path);
  Stream<String?> watchAutoBackupFolderPath();
  Future<void> checkAndPerformAutoBackup();

  // Cloud Backup Authentication
  Future<bool> signInToCloud();
  Future<void> signOutFromCloud();
  Future<bool> isCloudSignedIn();
}
