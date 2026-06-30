import '../../../../core/errors/result.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/repositories/complaints_repository.dart';

class CreateComplaintParams {
  const CreateComplaintParams({
    required this.customerName,
    required this.phoneNumber,
    required this.applianceTypes,
    this.notes,
    this.recordingPath,
  });

  final String customerName;
  final String phoneNumber;
  final List<ApplianceType> applianceTypes;
  final String? notes;
  final String? recordingPath;
}

class CreateComplaintUseCase {
  CreateComplaintUseCase({required ComplaintsRepository repository})
      : _repository = repository;

  final ComplaintsRepository _repository;

  Future<Result<int>> call(CreateComplaintParams params) {
    return _repository.createComplaint(
      customerName: params.customerName,
      phoneNumber: params.phoneNumber,
      applianceTypes: params.applianceTypes,
      notes: params.notes,
      recordingPath: params.recordingPath,
    );
  }
}
