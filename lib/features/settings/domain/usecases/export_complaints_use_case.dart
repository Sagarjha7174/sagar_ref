import '../../../../core/errors/result.dart';
import '../../domain/repositories/settings_repository.dart';

class ExportComplaintsUseCase {
  ExportComplaintsUseCase({required this._repository});

  final SettingsRepository _repository;

  Future<Result<String>> call() {
    return _repository.exportComplaintsCsv();
  }
}
