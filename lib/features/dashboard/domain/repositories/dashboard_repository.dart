import '../../../complaints/domain/entities/complaint.dart';

abstract class DashboardRepository {
  Stream<List<Complaint>> watchAllComplaints();
}
