import '../../../../core/errors/result.dart';
import '../../domain/entities/recording_item.dart';
import '../../domain/repositories/recordings_repository.dart';

class DiscardRecordingUseCase {
  DiscardRecordingUseCase({required this._repository});

  final RecordingsRepository _repository;

  Future<Result<void>> call(RecordingItem recording) {
    return _repository.discardRecording(recording);
  }
}
