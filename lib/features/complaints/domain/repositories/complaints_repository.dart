import '../../domain/entities/complaint.dart';
import '../../../../core/errors/result.dart';

abstract class ComplaintsRepository {
  Future<Result<int>> createComplaint({
    required String customerName,
    required String phoneNumber,
    required List<ApplianceType> applianceTypes,
    String? notes,
    String? recordingPath,
  });

  Future<Result<void>> completeComplaint({
    required int id,
    required double amountEarned,
    required double amountCollected,
    required double amountPending,
    String? completionNotes,
    String? imagePath,
  });

  Future<Result<void>> recordCollection({
    required int id,
    required double amountCollected,
    required double amountPending,
  });

  Future<Result<void>> rejectComplaint(int id);
  Future<Result<void>> reopenComplaint(int id);
  Future<Result<void>> deleteComplaint(int id);

  Future<Complaint?> findPendingByPhone(String phoneNumber);
  Future<Complaint?> getComplaintById(int id);

  Stream<List<Complaint>> watchPendingComplaints();
  Stream<Complaint?> watchComplaintById(int id);
  Stream<List<Complaint>> watchAllComplaints();

  Future<List<Complaint>> getCompletedAndRejected();
  Future<List<Complaint>> getAllComplaints();
}
