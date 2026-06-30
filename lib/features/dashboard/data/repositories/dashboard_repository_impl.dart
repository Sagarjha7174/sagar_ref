import '../../../complaints/domain/entities/complaint.dart';
import '../../../complaints/data/models/complaint_model.dart';
import '../../../../core/database/daos/complaints_dao.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({required this._complaintsDao});

  final ComplaintsDao _complaintsDao;

  @override
  Stream<List<Complaint>> watchAllComplaints() {
    return _complaintsDao
        .watchAllComplaints()
        .map((list) => list.map((c) => c.toDomain()).toList());
  }
}
