import '../../../../core/errors/result.dart';
import '../../domain/repositories/complaints_repository.dart';

class CompleteComplaintParams {
  const CompleteComplaintParams({
    required this.id,
    required this.amountEarned,
    required this.amountCollected,
    required this.amountPending,
    this.completionNotes,
    this.imagePath,
  });

  final int id;
  final double amountEarned;
  final double amountCollected;
  final double amountPending;
  final String? completionNotes;
  final String? imagePath;
}

class CompleteComplaintUseCase {
  CompleteComplaintUseCase({required ComplaintsRepository repository})
      : _repository = repository;

  final ComplaintsRepository _repository;

  Future<Result<void>> call(CompleteComplaintParams params) {
    return _repository.completeComplaint(
      id: params.id,
      amountEarned: params.amountEarned,
      amountCollected: params.amountCollected,
      amountPending: params.amountPending,
      completionNotes: params.completionNotes,
      imagePath: params.imagePath,
    );
  }
}
