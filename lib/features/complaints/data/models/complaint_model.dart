import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../domain/entities/complaint.dart';

extension ComplaintMapper on db.Complaint {
  Complaint toDomain() {
    return Complaint(
      id: id,
      customerName: customerName,
      phoneNumber: phoneNumber,
      applianceTypes: applianceType.isEmpty
          ? <ApplianceType>[]
          : applianceType
              .split(',')
              .map((s) => ApplianceType.fromString(s.trim()))
              .toList(),
      notes: notes,
      recordingPath: recordingPath,
      imagePath: imagePath,
      status: ComplaintStatus.fromString(status),
      amountEarned: amountEarned,
      amountCollected: amountCollected,
      amountPending: amountPending,
      completionNotes: completionNotes,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      completedAt: completedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(completedAt!)
          : null,
      rejectedAt: rejectedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(rejectedAt!)
          : null,
    );
  }
}

extension ComplaintDomainMapper on Complaint {
  db.ComplaintsCompanion toCompanion() {
    return db.ComplaintsCompanion(
      customerName: Value(customerName),
      phoneNumber: Value(phoneNumber),
      applianceType: Value(applianceTypes.map((e) => e.toDbString()).join(',')),
      notes: Value(notes),
      recordingPath: Value(recordingPath),
      imagePath: Value(imagePath),
      status: Value(status.toDbString()),
      amountEarned: Value(amountEarned),
      amountCollected: Value(amountCollected),
      amountPending: Value(amountPending),
      completionNotes: Value(completionNotes),
      createdAt: Value(createdAt.millisecondsSinceEpoch),
      completedAt: Value(completedAt?.millisecondsSinceEpoch),
      rejectedAt: Value(rejectedAt?.millisecondsSinceEpoch),
    );
  }
}
