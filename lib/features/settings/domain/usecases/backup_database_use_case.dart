import '../../../../core/errors/result.dart';
import '../../domain/repositories/settings_repository.dart';

class BackupDatabaseUseCase {
  BackupDatabaseUseCase({required this._repository});

  final SettingsRepository _repository;

  Future<Result<String>> call(String destinationDir) {
    return _repository.backupDatabase(destinationDir);
  }
}
