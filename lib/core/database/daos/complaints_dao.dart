import 'package:drift/drift.dart';
import '../app_database.dart';

part 'complaints_dao.g.dart';

@DriftAccessor(tables: [Complaints])
class ComplaintsDao extends DatabaseAccessor<AppDatabase>
    with _$ComplaintsDaoMixin {
  ComplaintsDao(super.db);

  // ===== CREATE =====

  Future<int> insertComplaint(ComplaintsCompanion complaint) {
    return into(complaints).insert(complaint);
  }

  // ===== READ =====

  Future<List<Complaint>> getAllComplaints() {
    return (select(complaints)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<Complaint?> getComplaintById(int id) {
    return (select(complaints)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<Complaint>> getComplaintsByStatus(String status) {
    return (select(complaints)
          ..where((t) => t.status.equals(status))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<Complaint?> findPendingByPhone(String phoneNumber) {
    return (select(complaints)
          ..where((t) =>
              t.phoneNumber.equals(phoneNumber) &
              t.status.equals('Pending'))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<Complaint>> getCompletedAndRejected() {
    return (select(complaints)
          ..where((t) =>
              t.status.equals('Completed') | t.status.equals('Rejected'))
          ..orderBy([
            (t) => OrderingTerm.desc(
                  coalesce([t.completedAt, t.rejectedAt, t.createdAt]),
                )
          ]))
        .get();
  }

  Future<List<Complaint>> getCompletedAndRejectedPaged(int limit, int offset) {
    return (select(complaints)
          ..where((t) =>
              t.status.equals('Completed') | t.status.equals('Rejected'))
          ..orderBy([
            (t) => OrderingTerm.desc(
                  coalesce([t.completedAt, t.rejectedAt, t.createdAt]),
                )
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  // ===== WATCH (Streams) =====

  Stream<List<Complaint>> watchComplaintsByStatus(String status) {
    return (select(complaints)
          ..where((t) => t.status.equals(status))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Stream<Complaint?> watchComplaintById(int id) {
    return (select(complaints)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  Stream<List<Complaint>> watchAllComplaints() {
    return (select(complaints)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  // ===== UPDATE =====

  Future<bool> completeComplaint({
    required int id,
    required double amountEarned,
    required double amountCollected,
    required double amountPending,
    String? completionNotes,
    String? imagePath,
  }) {
    return (update(complaints)..where((t) => t.id.equals(id))).write(
      ComplaintsCompanion(
        status: const Value('Completed'),
        amountEarned: Value(amountEarned),
        amountCollected: Value(amountCollected),
        amountPending: Value(amountPending),
        completionNotes: Value(completionNotes),
        imagePath: Value(imagePath),
        completedAt: Value(DateTime.now().millisecondsSinceEpoch),
        rejectedAt: const Value(null),
      ),
    ).then((rows) => rows > 0);
  }

  Future<bool> updateCollection({
    required int id,
    required double amountCollected,
    required double amountPending,
  }) {
    return (update(complaints)..where((t) => t.id.equals(id))).write(
      ComplaintsCompanion(
        amountCollected: Value(amountCollected),
        amountPending: Value(amountPending),
      ),
    ).then((rows) => rows > 0);
  }

  Future<bool> rejectComplaint(int id) {
    return (update(complaints)..where((t) => t.id.equals(id))).write(
      ComplaintsCompanion(
        status: const Value('Rejected'),
        rejectedAt: Value(DateTime.now().millisecondsSinceEpoch),
        completedAt: const Value(null),
        amountEarned: const Value(null),
        amountCollected: const Value(null),
        amountPending: const Value(null),
        completionNotes: const Value(null),
        imagePath: const Value(null),
      ),
    ).then((rows) => rows > 0);
  }

  Future<bool> reopenComplaint(int id) {
    return (update(complaints)..where((t) => t.id.equals(id))).write(
      const ComplaintsCompanion(
        status: Value('Pending'),
        completedAt: Value(null),
        rejectedAt: Value(null),
        amountEarned: Value(null),
        amountCollected: Value(null),
        amountPending: Value(null),
        completionNotes: Value(null),
        imagePath: Value(null),
      ),
    ).then((rows) => rows > 0);
  }

  // ===== DELETE =====

  Future<int> deleteComplaint(int id) {
    return (delete(complaints)..where((t) => t.id.equals(id))).go();
  }
}
