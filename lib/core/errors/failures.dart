sealed class AppFailure {
  const AppFailure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class PermissionDeniedFailure extends AppFailure {
  const PermissionDeniedFailure([super.message = 'Permission denied']);
}

class DatabaseFailure extends AppFailure {
  const DatabaseFailure([super.message = 'Database error occurred']);
}

class FileNotFoundFailure extends AppFailure {
  const FileNotFoundFailure([super.message = 'File not found']);
}

class DuplicateComplaintFailure extends AppFailure {
  const DuplicateComplaintFailure([super.message = 'A pending complaint already exists for this phone number']);
}

class RecordingNotFoundFailure extends AppFailure {
  const RecordingNotFoundFailure([super.message = 'Recording not found']);
}

class ExportFailure extends AppFailure {
  const ExportFailure([super.message = 'Export failed']);
}

class BackupFailure extends AppFailure {
  const BackupFailure([super.message = 'Backup operation failed']);
}
