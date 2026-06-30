class AppConstants {
  AppConstants._();

  static const String appName = 'Sagar Refrigeration Service';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'sagar_refrigeration.db';
  static const int databaseVersion = 4;

  // Settings keys
  static const String keyRecordingFolderPath = 'recording_folder_path';
  static const String keyLastScanTimestamp = 'last_scan_timestamp';
  static const String keyDbVersion = 'db_version';
  static const String keyAutoBackupFolderPath = 'auto_backup_folder_path';
  static const String keyLastAutoBackupTimestamp = 'last_auto_backup_timestamp';

  // Call log matching window (seconds)
  static const int callLogMatchWindowSeconds = 120;

  // Recording file extension
  static const String recordingExtension = '.mp3';

  // MIUI default recording paths
  static const List<String> miuiRecordingPaths = [
    '/sdcard/MIUI/sound_recorder/call_rec/',
    '/storage/emulated/0/MIUI/sound_recorder/call_rec/',
  ];

  // Appliance types
  static const List<String> applianceTypes = ['AC', 'Fridge', 'Washing Machine'];

  // CSV Export
  static const String exportSubDir = 'exports';
  static const List<String> csvHeaders = [
    'Customer Name',
    'Phone Number',
    'Appliance Type',
    'Status',
    'Amount Earned (₹)',
    'Complaint Notes',
    'Created Date',
    'Completed Date',
    'Rejection Date',
    'Completion Notes',
  ];
}
