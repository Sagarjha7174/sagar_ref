import '../../../../core/errors/result.dart';
import '../repositories/complaints_repository.dart';

class DeleteComplaintUseCase {
  DeleteComplaintUseCase({required this._repository});

  final ComplaintsRepository _repository;

  Future<Result<void>> call(int id) {
    return _repository.deleteComplaint(id);
  }
}
