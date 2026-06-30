import '../../../../core/errors/result.dart';
import '../../../recordings/domain/repositories/recordings_repository.dart';
import '../../../recordings/domain/entities/recording_item.dart';

class MarkRecordingProcessedUseCase {
  MarkRecordingProcessedUseCase({required this._repository});

  final RecordingsRepository _repository;

  Future<Result<void>> call(RecordingItem recording, int complaintId) {
    return _repository.markRecordingProcessed(recording, complaintId);
  }
}
