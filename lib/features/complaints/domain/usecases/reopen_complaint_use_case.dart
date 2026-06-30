import '../../../../core/errors/result.dart';
import '../../domain/repositories/complaints_repository.dart';

class ReopenComplaintUseCase {
  ReopenComplaintUseCase({required this._repository});

  final ComplaintsRepository _repository;

  Future<Result<void>> call(int complaintId) {
    return _repository.reopenComplaint(complaintId);
  }
}
