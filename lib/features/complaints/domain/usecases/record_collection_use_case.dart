import '../../../../core/errors/result.dart';
import '../repositories/complaints_repository.dart';

class RecordCollectionParams {
  const RecordCollectionParams({
    required this.id,
    required this.amountCollected,
    required this.amountPending,
  });

  final int id;
  final double amountCollected;
  final double amountPending;
}

class RecordCollectionUseCase {
  RecordCollectionUseCase({required ComplaintsRepository repository})
      : _repository = repository;

  final ComplaintsRepository _repository;

  Future<Result<void>> call(RecordCollectionParams params) {
    return _repository.recordCollection(
      id: params.id,
      amountCollected: params.amountCollected,
      amountPending: params.amountPending,
    );
  }
}
