import 'package:equatable/equatable.dart';

enum ApplianceType {
  ac('AC'),
  fridge('Fridge'),
  washingMachine('Washing Machine');

  const ApplianceType(this.displayName);
  final String displayName;

  static ApplianceType fromString(String value) {
    return switch (value.toLowerCase()) {
      'ac' => ApplianceType.ac,
      'fridge' => ApplianceType.fridge,
      'washing machine' || 'washingmachine' => ApplianceType.washingMachine,
      _ => ApplianceType.ac,
    };
  }

  String toDbString() => displayName;
}

enum ComplaintStatus {
  pending('Pending'),
  completed('Completed'),
  rejected('Rejected');

  const ComplaintStatus(this.displayName);
  final String displayName;

  static ComplaintStatus fromString(String value) {
    return switch (value.toLowerCase()) {
      'pending' => ComplaintStatus.pending,
      'completed' => ComplaintStatus.completed,
      'rejected' => ComplaintStatus.rejected,
      _ => ComplaintStatus.pending,
    };
  }

  String toDbString() => displayName;
}

class Complaint extends Equatable {
  const Complaint({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.applianceTypes,
    this.notes,
    this.recordingPath,
    this.imagePath,
    required this.status,
    this.amountEarned,
    this.amountCollected,
    this.amountPending,
    this.completionNotes,
    required this.createdAt,
    this.completedAt,
    this.rejectedAt,
  });

  final int id;
  final String customerName;
  final String phoneNumber;
  final List<ApplianceType> applianceTypes;
  final String? notes;
  final String? recordingPath;
  final String? imagePath;
  final ComplaintStatus status;
  final double? amountEarned;
  final double? amountCollected;
  final double? amountPending;
  final String? completionNotes;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? rejectedAt;

  @override
  List<Object?> get props => [
        id,
        customerName,
        phoneNumber,
        applianceTypes,
        notes,
        recordingPath,
        imagePath,
        status,
        amountEarned,
        amountCollected,
        amountPending,
        completionNotes,
        createdAt,
        completedAt,
        rejectedAt,
      ];

  Complaint copyWith({
    int? id,
    String? customerName,
    String? phoneNumber,
    List<ApplianceType>? applianceTypes,
    String? notes,
    String? recordingPath,
    String? imagePath,
    ComplaintStatus? status,
    double? amountEarned,
    double? amountCollected,
    double? amountPending,
    String? completionNotes,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? rejectedAt,
  }) {
    return Complaint(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      applianceTypes: applianceTypes ?? this.applianceTypes,
      notes: notes ?? this.notes,
      recordingPath: recordingPath ?? this.recordingPath,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
      amountEarned: amountEarned ?? this.amountEarned,
      amountCollected: amountCollected ?? this.amountCollected,
      amountPending: amountPending ?? this.amountPending,
      completionNotes: completionNotes ?? this.completionNotes,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
    );
  }
}
