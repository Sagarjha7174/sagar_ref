import '../../../../core/errors/result.dart';
import '../../domain/repositories/settings_repository.dart';

class RestoreDatabaseUseCase {
  RestoreDatabaseUseCase({required this._repository});

  final SettingsRepository _repository;

  Future<Result<void>> call(String sourceFilePath) {
    return _repository.restoreDatabase(sourceFilePath);
  }
}
