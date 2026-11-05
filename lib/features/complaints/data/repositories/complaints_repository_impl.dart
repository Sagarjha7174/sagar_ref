import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../../../core/database/daos/complaints_dao.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/phone_number_utils.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/repositories/complaints_repository.dart';
import '../models/complaint_model.dart';

class ComplaintsRepositoryImpl implements ComplaintsRepository {
  ComplaintsRepositoryImpl({required ComplaintsDao complaintsDao})
      : _complaintsDao = complaintsDao;

  final ComplaintsDao _complaintsDao;

  @override
  Future<Result<int>> createComplaint({
    required String customerName,
    required String phoneNumber,
    required List<ApplianceType> applianceTypes,
    String? notes,
    String? recordingPath,
  }) async {
    try {
      // Check duplicate pending
      final normalized = PhoneNumberUtils.normalize(phoneNumber);
      if (normalized.replaceAll(RegExp(r'\D'), '').length < 7) {
        return Result.failure(const DatabaseFailure(
          'Phone number is missing or invalid.',
        ));
      }
      final existing = await _complaintsDao.findPendingByPhone(normalized);
      if (existing != null) {
        return Result.failure(const DuplicateComplaintFailure());
      }

      final id = await _complaintsDao.insertComplaint(
        db.ComplaintsCompanion.insert(
          customerName: customerName,
          phoneNumber: normalized,
          applianceType: applianceTypes.map((e) => e.toDbString()).join(','),
          notes: Value(notes),
          recordingPath: Value(recordingPath),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      return Result.success(id);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to create complaint: $e'));
    }
  }

  @override
  Future<Result<void>> completeComplaint({
    required int id,
    required double amountEarned,
    required double amountCollected,
    required double amountPending,
    String? completionNotes,
    String? imagePath,
  }) async {
    try {
      if (amountEarned <= 0) {
        return Result.failure(
          const DatabaseFailure('Amount must be greater than zero.'),
        );
      }
      await _complaintsDao.completeComplaint(
        id: id,
        amountEarned: amountEarned,
        amountCollected: amountCollected,
        amountPending: amountPending,
        completionNotes: completionNotes,
        imagePath: imagePath,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to complete: $e'));
    }
  }

  @override
  Future<Result<void>> recordCollection({
    required int id,
    required double amountCollected,
    required double amountPending,
  }) async {
    try {
      await _complaintsDao.updateCollection(
        id: id,
        amountCollected: amountCollected,
        amountPending: amountPending,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to update collection: $e'));
    }
  }

  @override
  Future<Result<void>> rejectComplaint(int id) async {
    try {
      await _complaintsDao.rejectComplaint(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to reject: $e'));
    }
  }

  @override
  Future<Result<void>> reopenComplaint(int id) async {
    try {
      // Get complaint to check phone number duplicate
      final complaint = await _complaintsDao.getComplaintById(id);
      if (complaint == null) {
        return Result.failure(const DatabaseFailure('Complaint not found'));
      }

      final existing = await _complaintsDao.findPendingByPhone(complaint.phoneNumber);
      if (existing != null && existing.id != id) {
        return Result.failure(const DuplicateComplaintFailure(
          'A pending complaint already exists for this number. Resolve it first.',
        ));
      }

      await _complaintsDao.reopenComplaint(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to reopen: $e'));
    }
  }

  @override
  Future<Result<void>> deleteComplaint(int id) async {
    try {
      await _complaintsDao.deleteComplaint(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to delete: $e'));
    }
  }

  @override
  Future<Complaint?> findPendingByPhone(String phoneNumber) async {
    final normalized = PhoneNumberUtils.normalize(phoneNumber);
    final result = await _complaintsDao.findPendingByPhone(normalized);
    return result?.toDomain();
  }

  @override
  Future<Complaint?> getComplaintById(int id) async {
    final result = await _complaintsDao.getComplaintById(id);
    return result?.toDomain();
  }

  @override
  Stream<List<Complaint>> watchPendingComplaints() {
    return _complaintsDao
        .watchComplaintsByStatus('Pending')
        .map((list) => list.map((c) => c.toDomain()).toList());
  }

  @override
  Stream<Complaint?> watchComplaintById(int id) {
    return _complaintsDao
        .watchComplaintById(id)
        .map((c) => c?.toDomain());
  }

  @override
  Stream<List<Complaint>> watchAllComplaints() {
    return _complaintsDao
        .watchAllComplaints()
        .map((list) => list.map((c) => c.toDomain()).toList());
  }

  @override
  Future<List<Complaint>> getCompletedAndRejected() async {
    final results = await _complaintsDao.getCompletedAndRejected();
    return results.map((c) => c.toDomain()).toList();
  }

  @override
  Future<List<Complaint>> getAllComplaints() async {
    final results = await _complaintsDao.getAllComplaints();
    return results.map((c) => c.toDomain()).toList();
  }
}
