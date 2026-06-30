import '../../../../core/errors/result.dart';
import '../../domain/entities/recording_item.dart';
import '../../domain/repositories/recordings_repository.dart';

class ScanRecordingsUseCase {
  ScanRecordingsUseCase({required this._repository});

  final RecordingsRepository _repository;

  Future<Result<List<RecordingItem>>> call() {
    return _repository.scanRecordings();
  }
}
