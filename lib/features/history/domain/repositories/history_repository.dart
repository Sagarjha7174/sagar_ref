import '../../../complaints/domain/entities/complaint.dart';

abstract class HistoryRepository {
  Future<List<Complaint>> getCompletedAndRejected();
  Future<List<Complaint>> getCompletedAndRejectedPaged(int limit, int offset);
}
