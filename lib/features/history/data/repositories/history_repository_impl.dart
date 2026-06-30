import '../../../complaints/domain/entities/complaint.dart';
import '../../../complaints/data/models/complaint_model.dart';
import '../../../../core/database/daos/complaints_dao.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl({required this._complaintsDao});

  final ComplaintsDao _complaintsDao;

  @override
  Future<List<Complaint>> getCompletedAndRejected() async {
    final results = await _complaintsDao.getCompletedAndRejected();
    return results.map((c) => c.toDomain()).toList();
  }

  @override
  Future<List<Complaint>> getCompletedAndRejectedPaged(int limit, int offset) async {
    final results = await _complaintsDao.getCompletedAndRejectedPaged(limit, offset);
    return results.map((c) => c.toDomain()).toList();
  }
}
