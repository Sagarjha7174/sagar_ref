// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ComplaintsTable extends Complaints
    with TableInfo<$ComplaintsTable, Complaint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComplaintsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _applianceTypeMeta = const VerificationMeta(
    'applianceType',
  );
  @override
  late final GeneratedColumn<String> applianceType = GeneratedColumn<String>(
    'appliance_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordingPathMeta = const VerificationMeta(
    'recordingPath',
  );
  @override
  late final GeneratedColumn<String> recordingPath = GeneratedColumn<String>(
    'recording_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Pending'),
  );
  static const VerificationMeta _amountEarnedMeta = const VerificationMeta(
    'amountEarned',
  );
  @override
  late final GeneratedColumn<double> amountEarned = GeneratedColumn<double>(
    'amount_earned',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountCollectedMeta = const VerificationMeta(
    'amountCollected',
  );
  @override
  late final GeneratedColumn<double> amountCollected = GeneratedColumn<double>(
    'amount_collected',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountPendingMeta = const VerificationMeta(
    'amountPending',
  );
  @override
  late final GeneratedColumn<double> amountPending = GeneratedColumn<double>(
    'amount_pending',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completionNotesMeta = const VerificationMeta(
    'completionNotes',
  );
  @override
  late final GeneratedColumn<String> completionNotes = GeneratedColumn<String>(
    'completion_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rejectedAtMeta = const VerificationMeta(
    'rejectedAt',
  );
  @override
  late final GeneratedColumn<int> rejectedAt = GeneratedColumn<int>(
    'rejected_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerName,
    phoneNumber,
    applianceType,
    notes,
    recordingPath,
    status,
    amountEarned,
    amountCollected,
    amountPending,
    completionNotes,
    imagePath,
    createdAt,
    completedAt,
    rejectedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'complaints';
  @override
  VerificationContext validateIntegrity(
    Insertable<Complaint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('appliance_type')) {
      context.handle(
        _applianceTypeMeta,
        applianceType.isAcceptableOrUnknown(
          data['appliance_type']!,
          _applianceTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_applianceTypeMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('recording_path')) {
      context.handle(
        _recordingPathMeta,
        recordingPath.isAcceptableOrUnknown(
          data['recording_path']!,
          _recordingPathMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('amount_earned')) {
      context.handle(
        _amountEarnedMeta,
        amountEarned.isAcceptableOrUnknown(
          data['amount_earned']!,
          _amountEarnedMeta,
        ),
      );
    }
    if (data.containsKey('amount_collected')) {
      context.handle(
        _amountCollectedMeta,
        amountCollected.isAcceptableOrUnknown(
          data['amount_collected']!,
          _amountCollectedMeta,
        ),
      );
    }
    if (data.containsKey('amount_pending')) {
      context.handle(
        _amountPendingMeta,
        amountPending.isAcceptableOrUnknown(
          data['amount_pending']!,
          _amountPendingMeta,
        ),
      );
    }
    if (data.containsKey('completion_notes')) {
      context.handle(
        _completionNotesMeta,
        completionNotes.isAcceptableOrUnknown(
          data['completion_notes']!,
          _completionNotesMeta,
        ),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('rejected_at')) {
      context.handle(
        _rejectedAtMeta,
        rejectedAt.isAcceptableOrUnknown(data['rejected_at']!, _rejectedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Complaint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Complaint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      )!,
      applianceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}appliance_type'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      recordingPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recording_path'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      amountEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_earned'],
      ),
      amountCollected: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_collected'],
      ),
      amountPending: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_pending'],
      ),
      completionNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completion_notes'],
      ),
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      rejectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rejected_at'],
      ),
    );
  }

  @override
  $ComplaintsTable createAlias(String alias) {
    return $ComplaintsTable(attachedDatabase, alias);
  }
}

class Complaint extends DataClass implements Insertable<Complaint> {
  final int id;
  final String customerName;
  final String phoneNumber;
  final String applianceType;
  final String? notes;
  final String? recordingPath;
  final String status;
  final double? amountEarned;
  final double? amountCollected;
  final double? amountPending;
  final String? completionNotes;
  final String? imagePath;
  final int createdAt;
  final int? completedAt;
  final int? rejectedAt;
  const Complaint({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.applianceType,
    this.notes,
    this.recordingPath,
    required this.status,
    this.amountEarned,
    this.amountCollected,
    this.amountPending,
    this.completionNotes,
    this.imagePath,
    required this.createdAt,
    this.completedAt,
    this.rejectedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_name'] = Variable<String>(customerName);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['appliance_type'] = Variable<String>(applianceType);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || recordingPath != null) {
      map['recording_path'] = Variable<String>(recordingPath);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || amountEarned != null) {
      map['amount_earned'] = Variable<double>(amountEarned);
    }
    if (!nullToAbsent || amountCollected != null) {
      map['amount_collected'] = Variable<double>(amountCollected);
    }
    if (!nullToAbsent || amountPending != null) {
      map['amount_pending'] = Variable<double>(amountPending);
    }
    if (!nullToAbsent || completionNotes != null) {
      map['completion_notes'] = Variable<String>(completionNotes);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    if (!nullToAbsent || rejectedAt != null) {
      map['rejected_at'] = Variable<int>(rejectedAt);
    }
    return map;
  }

  ComplaintsCompanion toCompanion(bool nullToAbsent) {
    return ComplaintsCompanion(
      id: Value(id),
      customerName: Value(customerName),
      phoneNumber: Value(phoneNumber),
      applianceType: Value(applianceType),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      recordingPath: recordingPath == null && nullToAbsent
          ? const Value.absent()
          : Value(recordingPath),
      status: Value(status),
      amountEarned: amountEarned == null && nullToAbsent
          ? const Value.absent()
          : Value(amountEarned),
      amountCollected: amountCollected == null && nullToAbsent
          ? const Value.absent()
          : Value(amountCollected),
      amountPending: amountPending == null && nullToAbsent
          ? const Value.absent()
          : Value(amountPending),
      completionNotes: completionNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(completionNotes),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      rejectedAt: rejectedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(rejectedAt),
    );
  }

  factory Complaint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Complaint(
      id: serializer.fromJson<int>(json['id']),
      customerName: serializer.fromJson<String>(json['customerName']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      applianceType: serializer.fromJson<String>(json['applianceType']),
      notes: serializer.fromJson<String?>(json['notes']),
      recordingPath: serializer.fromJson<String?>(json['recordingPath']),
      status: serializer.fromJson<String>(json['status']),
      amountEarned: serializer.fromJson<double?>(json['amountEarned']),
      amountCollected: serializer.fromJson<double?>(json['amountCollected']),
      amountPending: serializer.fromJson<double?>(json['amountPending']),
      completionNotes: serializer.fromJson<String?>(json['completionNotes']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      rejectedAt: serializer.fromJson<int?>(json['rejectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerName': serializer.toJson<String>(customerName),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'applianceType': serializer.toJson<String>(applianceType),
      'notes': serializer.toJson<String?>(notes),
      'recordingPath': serializer.toJson<String?>(recordingPath),
      'status': serializer.toJson<String>(status),
      'amountEarned': serializer.toJson<double?>(amountEarned),
      'amountCollected': serializer.toJson<double?>(amountCollected),
      'amountPending': serializer.toJson<double?>(amountPending),
      'completionNotes': serializer.toJson<String?>(completionNotes),
      'imagePath': serializer.toJson<String?>(imagePath),
      'createdAt': serializer.toJson<int>(createdAt),
      'completedAt': serializer.toJson<int?>(completedAt),
      'rejectedAt': serializer.toJson<int?>(rejectedAt),
    };
  }

  Complaint copyWith({
    int? id,
    String? customerName,
    String? phoneNumber,
    String? applianceType,
    Value<String?> notes = const Value.absent(),
    Value<String?> recordingPath = const Value.absent(),
    String? status,
    Value<double?> amountEarned = const Value.absent(),
    Value<double?> amountCollected = const Value.absent(),
    Value<double?> amountPending = const Value.absent(),
    Value<String?> completionNotes = const Value.absent(),
    Value<String?> imagePath = const Value.absent(),
    int? createdAt,
    Value<int?> completedAt = const Value.absent(),
    Value<int?> rejectedAt = const Value.absent(),
  }) => Complaint(
    id: id ?? this.id,
    customerName: customerName ?? this.customerName,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    applianceType: applianceType ?? this.applianceType,
    notes: notes.present ? notes.value : this.notes,
    recordingPath: recordingPath.present
        ? recordingPath.value
        : this.recordingPath,
    status: status ?? this.status,
    amountEarned: amountEarned.present ? amountEarned.value : this.amountEarned,
    amountCollected: amountCollected.present
        ? amountCollected.value
        : this.amountCollected,
    amountPending: amountPending.present
        ? amountPending.value
        : this.amountPending,
    completionNotes: completionNotes.present
        ? completionNotes.value
        : this.completionNotes,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    rejectedAt: rejectedAt.present ? rejectedAt.value : this.rejectedAt,
  );
  Complaint copyWithCompanion(ComplaintsCompanion data) {
    return Complaint(
      id: data.id.present ? data.id.value : this.id,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      applianceType: data.applianceType.present
          ? data.applianceType.value
          : this.applianceType,
      notes: data.notes.present ? data.notes.value : this.notes,
      recordingPath: data.recordingPath.present
          ? data.recordingPath.value
          : this.recordingPath,
      status: data.status.present ? data.status.value : this.status,
      amountEarned: data.amountEarned.present
          ? data.amountEarned.value
          : this.amountEarned,
      amountCollected: data.amountCollected.present
          ? data.amountCollected.value
          : this.amountCollected,
      amountPending: data.amountPending.present
          ? data.amountPending.value
          : this.amountPending,
      completionNotes: data.completionNotes.present
          ? data.completionNotes.value
          : this.completionNotes,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      rejectedAt: data.rejectedAt.present
          ? data.rejectedAt.value
          : this.rejectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Complaint(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('applianceType: $applianceType, ')
          ..write('notes: $notes, ')
          ..write('recordingPath: $recordingPath, ')
          ..write('status: $status, ')
          ..write('amountEarned: $amountEarned, ')
          ..write('amountCollected: $amountCollected, ')
          ..write('amountPending: $amountPending, ')
          ..write('completionNotes: $completionNotes, ')
          ..write('imagePath: $imagePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rejectedAt: $rejectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerName,
    phoneNumber,
    applianceType,
    notes,
    recordingPath,
    status,
    amountEarned,
    amountCollected,
    amountPending,
    completionNotes,
    imagePath,
    createdAt,
    completedAt,
    rejectedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Complaint &&
          other.id == this.id &&
          other.customerName == this.customerName &&
          other.phoneNumber == this.phoneNumber &&
          other.applianceType == this.applianceType &&
          other.notes == this.notes &&
          other.recordingPath == this.recordingPath &&
          other.status == this.status &&
          other.amountEarned == this.amountEarned &&
          other.amountCollected == this.amountCollected &&
          other.amountPending == this.amountPending &&
          other.completionNotes == this.completionNotes &&
          other.imagePath == this.imagePath &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt &&
          other.rejectedAt == this.rejectedAt);
}

class ComplaintsCompanion extends UpdateCompanion<Complaint> {
  final Value<int> id;
  final Value<String> customerName;
  final Value<String> phoneNumber;
  final Value<String> applianceType;
  final Value<String?> notes;
  final Value<String?> recordingPath;
  final Value<String> status;
  final Value<double?> amountEarned;
  final Value<double?> amountCollected;
  final Value<double?> amountPending;
  final Value<String?> completionNotes;
  final Value<String?> imagePath;
  final Value<int> createdAt;
  final Value<int?> completedAt;
  final Value<int?> rejectedAt;
  const ComplaintsCompanion({
    this.id = const Value.absent(),
    this.customerName = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.applianceType = const Value.absent(),
    this.notes = const Value.absent(),
    this.recordingPath = const Value.absent(),
    this.status = const Value.absent(),
    this.amountEarned = const Value.absent(),
    this.amountCollected = const Value.absent(),
    this.amountPending = const Value.absent(),
    this.completionNotes = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rejectedAt = const Value.absent(),
  });
  ComplaintsCompanion.insert({
    this.id = const Value.absent(),
    required String customerName,
    required String phoneNumber,
    required String applianceType,
    this.notes = const Value.absent(),
    this.recordingPath = const Value.absent(),
    this.status = const Value.absent(),
    this.amountEarned = const Value.absent(),
    this.amountCollected = const Value.absent(),
    this.amountPending = const Value.absent(),
    this.completionNotes = const Value.absent(),
    this.imagePath = const Value.absent(),
    required int createdAt,
    this.completedAt = const Value.absent(),
    this.rejectedAt = const Value.absent(),
  }) : customerName = Value(customerName),
       phoneNumber = Value(phoneNumber),
       applianceType = Value(applianceType),
       createdAt = Value(createdAt);
  static Insertable<Complaint> custom({
    Expression<int>? id,
    Expression<String>? customerName,
    Expression<String>? phoneNumber,
    Expression<String>? applianceType,
    Expression<String>? notes,
    Expression<String>? recordingPath,
    Expression<String>? status,
    Expression<double>? amountEarned,
    Expression<double>? amountCollected,
    Expression<double>? amountPending,
    Expression<String>? completionNotes,
    Expression<String>? imagePath,
    Expression<int>? createdAt,
    Expression<int>? completedAt,
    Expression<int>? rejectedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerName != null) 'customer_name': customerName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (applianceType != null) 'appliance_type': applianceType,
      if (notes != null) 'notes': notes,
      if (recordingPath != null) 'recording_path': recordingPath,
      if (status != null) 'status': status,
      if (amountEarned != null) 'amount_earned': amountEarned,
      if (amountCollected != null) 'amount_collected': amountCollected,
      if (amountPending != null) 'amount_pending': amountPending,
      if (completionNotes != null) 'completion_notes': completionNotes,
      if (imagePath != null) 'image_path': imagePath,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rejectedAt != null) 'rejected_at': rejectedAt,
    });
  }

  ComplaintsCompanion copyWith({
    Value<int>? id,
    Value<String>? customerName,
    Value<String>? phoneNumber,
    Value<String>? applianceType,
    Value<String?>? notes,
    Value<String?>? recordingPath,
    Value<String>? status,
    Value<double?>? amountEarned,
    Value<double?>? amountCollected,
    Value<double?>? amountPending,
    Value<String?>? completionNotes,
    Value<String?>? imagePath,
    Value<int>? createdAt,
    Value<int?>? completedAt,
    Value<int?>? rejectedAt,
  }) {
    return ComplaintsCompanion(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      applianceType: applianceType ?? this.applianceType,
      notes: notes ?? this.notes,
      recordingPath: recordingPath ?? this.recordingPath,
      status: status ?? this.status,
      amountEarned: amountEarned ?? this.amountEarned,
      amountCollected: amountCollected ?? this.amountCollected,
      amountPending: amountPending ?? this.amountPending,
      completionNotes: completionNotes ?? this.completionNotes,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (applianceType.present) {
      map['appliance_type'] = Variable<String>(applianceType.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (recordingPath.present) {
      map['recording_path'] = Variable<String>(recordingPath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (amountEarned.present) {
      map['amount_earned'] = Variable<double>(amountEarned.value);
    }
    if (amountCollected.present) {
      map['amount_collected'] = Variable<double>(amountCollected.value);
    }
    if (amountPending.present) {
      map['amount_pending'] = Variable<double>(amountPending.value);
    }
    if (completionNotes.present) {
      map['completion_notes'] = Variable<String>(completionNotes.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (rejectedAt.present) {
      map['rejected_at'] = Variable<int>(rejectedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComplaintsCompanion(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('applianceType: $applianceType, ')
          ..write('notes: $notes, ')
          ..write('recordingPath: $recordingPath, ')
          ..write('status: $status, ')
          ..write('amountEarned: $amountEarned, ')
          ..write('amountCollected: $amountCollected, ')
          ..write('amountPending: $amountPending, ')
          ..write('completionNotes: $completionNotes, ')
          ..write('imagePath: $imagePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rejectedAt: $rejectedAt')
          ..write(')'))
        .toString();
  }
}

class $ProcessedRecordingsTable extends ProcessedRecordings
    with TableInfo<$ProcessedRecordingsTable, ProcessedRecording> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProcessedRecordingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<int> recordedAt = GeneratedColumn<int>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _complaintIdMeta = const VerificationMeta(
    'complaintId',
  );
  @override
  late final GeneratedColumn<int> complaintId = GeneratedColumn<int>(
    'complaint_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES complaints (id)',
    ),
  );
  static const VerificationMeta _markedAtMeta = const VerificationMeta(
    'markedAt',
  );
  @override
  late final GeneratedColumn<int> markedAt = GeneratedColumn<int>(
    'marked_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    filePath,
    phoneNumber,
    recordedAt,
    complaintId,
    markedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'processed_recordings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProcessedRecording> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('complaint_id')) {
      context.handle(
        _complaintIdMeta,
        complaintId.isAcceptableOrUnknown(
          data['complaint_id']!,
          _complaintIdMeta,
        ),
      );
    }
    if (data.containsKey('marked_at')) {
      context.handle(
        _markedAtMeta,
        markedAt.isAcceptableOrUnknown(data['marked_at']!, _markedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_markedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProcessedRecording map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProcessedRecording(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recorded_at'],
      )!,
      complaintId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}complaint_id'],
      ),
      markedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}marked_at'],
      )!,
    );
  }

  @override
  $ProcessedRecordingsTable createAlias(String alias) {
    return $ProcessedRecordingsTable(attachedDatabase, alias);
  }
}

class ProcessedRecording extends DataClass
    implements Insertable<ProcessedRecording> {
  final int id;
  final String filePath;
  final String phoneNumber;
  final int recordedAt;
  final int? complaintId;
  final int markedAt;
  const ProcessedRecording({
    required this.id,
    required this.filePath,
    required this.phoneNumber,
    required this.recordedAt,
    this.complaintId,
    required this.markedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['file_path'] = Variable<String>(filePath);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['recorded_at'] = Variable<int>(recordedAt);
    if (!nullToAbsent || complaintId != null) {
      map['complaint_id'] = Variable<int>(complaintId);
    }
    map['marked_at'] = Variable<int>(markedAt);
    return map;
  }

  ProcessedRecordingsCompanion toCompanion(bool nullToAbsent) {
    return ProcessedRecordingsCompanion(
      id: Value(id),
      filePath: Value(filePath),
      phoneNumber: Value(phoneNumber),
      recordedAt: Value(recordedAt),
      complaintId: complaintId == null && nullToAbsent
          ? const Value.absent()
          : Value(complaintId),
      markedAt: Value(markedAt),
    );
  }

  factory ProcessedRecording.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProcessedRecording(
      id: serializer.fromJson<int>(json['id']),
      filePath: serializer.fromJson<String>(json['filePath']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      recordedAt: serializer.fromJson<int>(json['recordedAt']),
      complaintId: serializer.fromJson<int?>(json['complaintId']),
      markedAt: serializer.fromJson<int>(json['markedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'filePath': serializer.toJson<String>(filePath),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'recordedAt': serializer.toJson<int>(recordedAt),
      'complaintId': serializer.toJson<int?>(complaintId),
      'markedAt': serializer.toJson<int>(markedAt),
    };
  }

  ProcessedRecording copyWith({
    int? id,
    String? filePath,
    String? phoneNumber,
    int? recordedAt,
    Value<int?> complaintId = const Value.absent(),
    int? markedAt,
  }) => ProcessedRecording(
    id: id ?? this.id,
    filePath: filePath ?? this.filePath,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    recordedAt: recordedAt ?? this.recordedAt,
    complaintId: complaintId.present ? complaintId.value : this.complaintId,
    markedAt: markedAt ?? this.markedAt,
  );
  ProcessedRecording copyWithCompanion(ProcessedRecordingsCompanion data) {
    return ProcessedRecording(
      id: data.id.present ? data.id.value : this.id,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      complaintId: data.complaintId.present
          ? data.complaintId.value
          : this.complaintId,
      markedAt: data.markedAt.present ? data.markedAt.value : this.markedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProcessedRecording(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('complaintId: $complaintId, ')
          ..write('markedAt: $markedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, filePath, phoneNumber, recordedAt, complaintId, markedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProcessedRecording &&
          other.id == this.id &&
          other.filePath == this.filePath &&
          other.phoneNumber == this.phoneNumber &&
          other.recordedAt == this.recordedAt &&
          other.complaintId == this.complaintId &&
          other.markedAt == this.markedAt);
}

class ProcessedRecordingsCompanion extends UpdateCompanion<ProcessedRecording> {
  final Value<int> id;
  final Value<String> filePath;
  final Value<String> phoneNumber;
  final Value<int> recordedAt;
  final Value<int?> complaintId;
  final Value<int> markedAt;
  const ProcessedRecordingsCompanion({
    this.id = const Value.absent(),
    this.filePath = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.complaintId = const Value.absent(),
    this.markedAt = const Value.absent(),
  });
  ProcessedRecordingsCompanion.insert({
    this.id = const Value.absent(),
    required String filePath,
    required String phoneNumber,
    required int recordedAt,
    this.complaintId = const Value.absent(),
    required int markedAt,
  }) : filePath = Value(filePath),
       phoneNumber = Value(phoneNumber),
       recordedAt = Value(recordedAt),
       markedAt = Value(markedAt);
  static Insertable<ProcessedRecording> custom({
    Expression<int>? id,
    Expression<String>? filePath,
    Expression<String>? phoneNumber,
    Expression<int>? recordedAt,
    Expression<int>? complaintId,
    Expression<int>? markedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (filePath != null) 'file_path': filePath,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (complaintId != null) 'complaint_id': complaintId,
      if (markedAt != null) 'marked_at': markedAt,
    });
  }

  ProcessedRecordingsCompanion copyWith({
    Value<int>? id,
    Value<String>? filePath,
    Value<String>? phoneNumber,
    Value<int>? recordedAt,
    Value<int?>? complaintId,
    Value<int>? markedAt,
  }) {
    return ProcessedRecordingsCompanion(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      recordedAt: recordedAt ?? this.recordedAt,
      complaintId: complaintId ?? this.complaintId,
      markedAt: markedAt ?? this.markedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<int>(recordedAt.value);
    }
    if (complaintId.present) {
      map['complaint_id'] = Variable<int>(complaintId.value);
    }
    if (markedAt.present) {
      map['marked_at'] = Variable<int>(markedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProcessedRecordingsCompanion(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('complaintId: $complaintId, ')
          ..write('markedAt: $markedAt')
          ..write(')'))
        .toString();
  }
}

class $DiscardedRecordingsTable extends DiscardedRecordings
    with TableInfo<$DiscardedRecordingsTable, DiscardedRecording> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiscardedRecordingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<int> recordedAt = GeneratedColumn<int>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discardedAtMeta = const VerificationMeta(
    'discardedAt',
  );
  @override
  late final GeneratedColumn<int> discardedAt = GeneratedColumn<int>(
    'discarded_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    filePath,
    phoneNumber,
    recordedAt,
    discardedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'discarded_recordings';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiscardedRecording> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('discarded_at')) {
      context.handle(
        _discardedAtMeta,
        discardedAt.isAcceptableOrUnknown(
          data['discarded_at']!,
          _discardedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_discardedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiscardedRecording map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiscardedRecording(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recorded_at'],
      )!,
      discardedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discarded_at'],
      )!,
    );
  }

  @override
  $DiscardedRecordingsTable createAlias(String alias) {
    return $DiscardedRecordingsTable(attachedDatabase, alias);
  }
}

class DiscardedRecording extends DataClass
    implements Insertable<DiscardedRecording> {
  final int id;
  final String filePath;
  final String phoneNumber;
  final int recordedAt;
  final int discardedAt;
  const DiscardedRecording({
    required this.id,
    required this.filePath,
    required this.phoneNumber,
    required this.recordedAt,
    required this.discardedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['file_path'] = Variable<String>(filePath);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['recorded_at'] = Variable<int>(recordedAt);
    map['discarded_at'] = Variable<int>(discardedAt);
    return map;
  }

  DiscardedRecordingsCompanion toCompanion(bool nullToAbsent) {
    return DiscardedRecordingsCompanion(
      id: Value(id),
      filePath: Value(filePath),
      phoneNumber: Value(phoneNumber),
      recordedAt: Value(recordedAt),
      discardedAt: Value(discardedAt),
    );
  }

  factory DiscardedRecording.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiscardedRecording(
      id: serializer.fromJson<int>(json['id']),
      filePath: serializer.fromJson<String>(json['filePath']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      recordedAt: serializer.fromJson<int>(json['recordedAt']),
      discardedAt: serializer.fromJson<int>(json['discardedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'filePath': serializer.toJson<String>(filePath),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'recordedAt': serializer.toJson<int>(recordedAt),
      'discardedAt': serializer.toJson<int>(discardedAt),
    };
  }

  DiscardedRecording copyWith({
    int? id,
    String? filePath,
    String? phoneNumber,
    int? recordedAt,
    int? discardedAt,
  }) => DiscardedRecording(
    id: id ?? this.id,
    filePath: filePath ?? this.filePath,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    recordedAt: recordedAt ?? this.recordedAt,
    discardedAt: discardedAt ?? this.discardedAt,
  );
  DiscardedRecording copyWithCompanion(DiscardedRecordingsCompanion data) {
    return DiscardedRecording(
      id: data.id.present ? data.id.value : this.id,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      discardedAt: data.discardedAt.present
          ? data.discardedAt.value
          : this.discardedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiscardedRecording(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('discardedAt: $discardedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, filePath, phoneNumber, recordedAt, discardedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiscardedRecording &&
          other.id == this.id &&
          other.filePath == this.filePath &&
          other.phoneNumber == this.phoneNumber &&
          other.recordedAt == this.recordedAt &&
          other.discardedAt == this.discardedAt);
}

class DiscardedRecordingsCompanion extends UpdateCompanion<DiscardedRecording> {
  final Value<int> id;
  final Value<String> filePath;
  final Value<String> phoneNumber;
  final Value<int> recordedAt;
  final Value<int> discardedAt;
  const DiscardedRecordingsCompanion({
    this.id = const Value.absent(),
    this.filePath = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.discardedAt = const Value.absent(),
  });
  DiscardedRecordingsCompanion.insert({
    this.id = const Value.absent(),
    required String filePath,
    required String phoneNumber,
    required int recordedAt,
    required int discardedAt,
  }) : filePath = Value(filePath),
       phoneNumber = Value(phoneNumber),
       recordedAt = Value(recordedAt),
       discardedAt = Value(discardedAt);
  static Insertable<DiscardedRecording> custom({
    Expression<int>? id,
    Expression<String>? filePath,
    Expression<String>? phoneNumber,
    Expression<int>? recordedAt,
    Expression<int>? discardedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (filePath != null) 'file_path': filePath,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (discardedAt != null) 'discarded_at': discardedAt,
    });
  }

  DiscardedRecordingsCompanion copyWith({
    Value<int>? id,
    Value<String>? filePath,
    Value<String>? phoneNumber,
    Value<int>? recordedAt,
    Value<int>? discardedAt,
  }) {
    return DiscardedRecordingsCompanion(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      recordedAt: recordedAt ?? this.recordedAt,
      discardedAt: discardedAt ?? this.discardedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<int>(recordedAt.value);
    }
    if (discardedAt.present) {
      map['discarded_at'] = Variable<int>(discardedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiscardedRecordingsCompanion(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('discardedAt: $discardedAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  final int updatedAt;
  const AppSetting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? value, int? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ComplaintsTable complaints = $ComplaintsTable(this);
  late final $ProcessedRecordingsTable processedRecordings =
      $ProcessedRecordingsTable(this);
  late final $DiscardedRecordingsTable discardedRecordings =
      $DiscardedRecordingsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final ComplaintsDao complaintsDao = ComplaintsDao(this as AppDatabase);
  late final RecordingsDao recordingsDao = RecordingsDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    complaints,
    processedRecordings,
    discardedRecordings,
    appSettings,
  ];
}

typedef $$ComplaintsTableCreateCompanionBuilder = ComplaintsCompanion Function({
  Value<int> id,
  required String customerName,
  required String phoneNumber,
  required String applianceType,
  Value<String?> notes,
  Value<String?> recordingPath,
  Value<String> status,
  Value<double?> amountEarned,
  Value<double?> amountCollected,
  Value<double?> amountPending,
  Value<String?> completionNotes,
  Value<String?> imagePath,
  required int createdAt,
  Value<int?> completedAt,
  Value<int?> rejectedAt,
});
typedef $$ComplaintsTableUpdateCompanionBuilder = ComplaintsCompanion Function({
  Value<int> id,
  Value<String> customerName,
  Value<String> phoneNumber,
  Value<String> applianceType,
  Value<String?> notes,
  Value<String?> recordingPath,
  Value<String> status,
  Value<double?> amountEarned,
  Value<double?> amountCollected,
  Value<double?> amountPending,
  Value<String?> completionNotes,
  Value<String?> imagePath,
  Value<int> createdAt,
  Value<int?> completedAt,
  Value<int?> rejectedAt,
});

final class $$ComplaintsTableReferences
    extends BaseReferences<_$AppDatabase, $ComplaintsTable, Complaint> {
  $$ComplaintsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $ProcessedRecordingsTable,
    List<ProcessedRecording>
  >
  _processedRecordingsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.processedRecordings,
        aliasName: 'complaints__id__processed_recordings__complaint_id',
      );

  $$ProcessedRecordingsTableProcessedTableManager get processedRecordingsRefs {
    final manager = $$ProcessedRecordingsTableTableManager(
      $_db,
      $_db.processedRecordings,
    ).filter((f) => f.complaintId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _processedRecordingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ComplaintsTableFilterComposer
    extends Composer<_$AppDatabase, $ComplaintsTable> {
  $$ComplaintsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get applianceType => $composableBuilder(
    column: $table.applianceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordingPath => $composableBuilder(
    column: $table.recordingPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountEarned => $composableBuilder(
    column: $table.amountEarned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountCollected => $composableBuilder(
    column: $table.amountCollected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountPending => $composableBuilder(
    column: $table.amountPending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completionNotes => $composableBuilder(
    column: $table.completionNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rejectedAt => $composableBuilder(
    column: $table.rejectedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> processedRecordingsRefs(
    Expression<bool> Function($$ProcessedRecordingsTableFilterComposer f) f,
  ) {
    final $$ProcessedRecordingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.processedRecordings,
      getReferencedColumn: (t) => t.complaintId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProcessedRecordingsTableFilterComposer(
            $db: $db,
            $table: $db.processedRecordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ComplaintsTableOrderingComposer
    extends Composer<_$AppDatabase, $ComplaintsTable> {
  $$ComplaintsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get applianceType => $composableBuilder(
    column: $table.applianceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordingPath => $composableBuilder(
    column: $table.recordingPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountEarned => $composableBuilder(
    column: $table.amountEarned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountCollected => $composableBuilder(
    column: $table.amountCollected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountPending => $composableBuilder(
    column: $table.amountPending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completionNotes => $composableBuilder(
    column: $table.completionNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rejectedAt => $composableBuilder(
    column: $table.rejectedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ComplaintsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ComplaintsTable> {
  $$ComplaintsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get applianceType => $composableBuilder(
    column: $table.applianceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get recordingPath => $composableBuilder(
    column: $table.recordingPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get amountEarned => $composableBuilder(
    column: $table.amountEarned,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountCollected => $composableBuilder(
    column: $table.amountCollected,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountPending => $composableBuilder(
    column: $table.amountPending,
    builder: (column) => column,
  );

  GeneratedColumn<String> get completionNotes => $composableBuilder(
    column: $table.completionNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rejectedAt => $composableBuilder(
    column: $table.rejectedAt,
    builder: (column) => column,
  );

  Expression<T> processedRecordingsRefs<T extends Object>(
    Expression<T> Function($$ProcessedRecordingsTableAnnotationComposer a) f,
  ) {
    final $$ProcessedRecordingsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.processedRecordings,
          getReferencedColumn: (t) => t.complaintId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProcessedRecordingsTableAnnotationComposer(
                $db: $db,
                $table: $db.processedRecordings,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ComplaintsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ComplaintsTable,
          Complaint,
          $$ComplaintsTableFilterComposer,
          $$ComplaintsTableOrderingComposer,
          $$ComplaintsTableAnnotationComposer,
          $$ComplaintsTableCreateCompanionBuilder,
          $$ComplaintsTableUpdateCompanionBuilder,
          (Complaint, $$ComplaintsTableReferences),
          Complaint,
          PrefetchHooks Function({bool processedRecordingsRefs})
        > {
  $$ComplaintsTableTableManager(_$AppDatabase db, $ComplaintsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComplaintsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComplaintsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComplaintsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<String> phoneNumber = const Value.absent(),
                Value<String> applianceType = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> recordingPath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double?> amountEarned = const Value.absent(),
                Value<double?> amountCollected = const Value.absent(),
                Value<double?> amountPending = const Value.absent(),
                Value<String?> completionNotes = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int?> rejectedAt = const Value.absent(),
              }) => ComplaintsCompanion(
                id: id,
                customerName: customerName,
                phoneNumber: phoneNumber,
                applianceType: applianceType,
                notes: notes,
                recordingPath: recordingPath,
                status: status,
                amountEarned: amountEarned,
                amountCollected: amountCollected,
                amountPending: amountPending,
                completionNotes: completionNotes,
                imagePath: imagePath,
                createdAt: createdAt,
                completedAt: completedAt,
                rejectedAt: rejectedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String customerName,
                required String phoneNumber,
                required String applianceType,
                Value<String?> notes = const Value.absent(),
                Value<String?> recordingPath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double?> amountEarned = const Value.absent(),
                Value<double?> amountCollected = const Value.absent(),
                Value<double?> amountPending = const Value.absent(),
                Value<String?> completionNotes = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                required int createdAt,
                Value<int?> completedAt = const Value.absent(),
                Value<int?> rejectedAt = const Value.absent(),
              }) => ComplaintsCompanion.insert(
                id: id,
                customerName: customerName,
                phoneNumber: phoneNumber,
                applianceType: applianceType,
                notes: notes,
                recordingPath: recordingPath,
                status: status,
                amountEarned: amountEarned,
                amountCollected: amountCollected,
                amountPending: amountPending,
                completionNotes: completionNotes,
                imagePath: imagePath,
                createdAt: createdAt,
                completedAt: completedAt,
                rejectedAt: rejectedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ComplaintsTable, Complaint>(table),
                  $$ComplaintsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({processedRecordingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (processedRecordingsRefs) db.processedRecordings,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (processedRecordingsRefs)
                    await $_getPrefetchedDataByColumns<
                      Complaint,
                      $ComplaintsTable,
                      ProcessedRecording,
                      $ProcessedRecordingsTable
                    >(
                      currentTable: table,
                      referencedTable: $$ComplaintsTableReferences
                          ._processedRecordingsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ComplaintsTableReferences(
                            db,
                            table,
                            p0,
                          ).processedRecordingsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'complaint_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ComplaintsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ComplaintsTable,
      Complaint,
      $$ComplaintsTableFilterComposer,
      $$ComplaintsTableOrderingComposer,
      $$ComplaintsTableAnnotationComposer,
      $$ComplaintsTableCreateCompanionBuilder,
      $$ComplaintsTableUpdateCompanionBuilder,
      (Complaint, $$ComplaintsTableReferences),
      Complaint,
      PrefetchHooks Function({bool processedRecordingsRefs})
    >;
typedef $$ProcessedRecordingsTableCreateCompanionBuilder =
    ProcessedRecordingsCompanion Function({
      Value<int> id,
      required String filePath,
      required String phoneNumber,
      required int recordedAt,
      Value<int?> complaintId,
      required int markedAt,
    });
typedef $$ProcessedRecordingsTableUpdateCompanionBuilder =
    ProcessedRecordingsCompanion Function({
      Value<int> id,
      Value<String> filePath,
      Value<String> phoneNumber,
      Value<int> recordedAt,
      Value<int?> complaintId,
      Value<int> markedAt,
    });

final class $$ProcessedRecordingsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ProcessedRecordingsTable,
          ProcessedRecording
        > {
  $$ProcessedRecordingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ComplaintsTable _complaintIdTable(_$AppDatabase db) => db.complaints
      .createAlias('processed_recordings__complaint_id__complaints__id');

  $$ComplaintsTableProcessedTableManager? get complaintId {
    final $_column = $_itemColumn<int>('complaint_id');
    if ($_column == null) return null;
    final manager = $$ComplaintsTableTableManager(
      $_db,
      $_db.complaints,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_complaintIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProcessedRecordingsTableFilterComposer
    extends Composer<_$AppDatabase, $ProcessedRecordingsTable> {
  $$ProcessedRecordingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get markedAt => $composableBuilder(
    column: $table.markedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ComplaintsTableFilterComposer get complaintId {
    final $$ComplaintsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.complaintId,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComplaintsTableFilterComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProcessedRecordingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProcessedRecordingsTable> {
  $$ProcessedRecordingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get markedAt => $composableBuilder(
    column: $table.markedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ComplaintsTableOrderingComposer get complaintId {
    final $$ComplaintsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.complaintId,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComplaintsTableOrderingComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProcessedRecordingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProcessedRecordingsTable> {
  $$ProcessedRecordingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get markedAt =>
      $composableBuilder(column: $table.markedAt, builder: (column) => column);

  $$ComplaintsTableAnnotationComposer get complaintId {
    final $$ComplaintsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.complaintId,
      referencedTable: $db.complaints,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComplaintsTableAnnotationComposer(
            $db: $db,
            $table: $db.complaints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProcessedRecordingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProcessedRecordingsTable,
          ProcessedRecording,
          $$ProcessedRecordingsTableFilterComposer,
          $$ProcessedRecordingsTableOrderingComposer,
          $$ProcessedRecordingsTableAnnotationComposer,
          $$ProcessedRecordingsTableCreateCompanionBuilder,
          $$ProcessedRecordingsTableUpdateCompanionBuilder,
          (ProcessedRecording, $$ProcessedRecordingsTableReferences),
          ProcessedRecording,
          PrefetchHooks Function({bool complaintId})
        > {
  $$ProcessedRecordingsTableTableManager(
    _$AppDatabase db,
    $ProcessedRecordingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProcessedRecordingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProcessedRecordingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProcessedRecordingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> phoneNumber = const Value.absent(),
                Value<int> recordedAt = const Value.absent(),
                Value<int?> complaintId = const Value.absent(),
                Value<int> markedAt = const Value.absent(),
              }) => ProcessedRecordingsCompanion(
                id: id,
                filePath: filePath,
                phoneNumber: phoneNumber,
                recordedAt: recordedAt,
                complaintId: complaintId,
                markedAt: markedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String filePath,
                required String phoneNumber,
                required int recordedAt,
                Value<int?> complaintId = const Value.absent(),
                required int markedAt,
              }) => ProcessedRecordingsCompanion.insert(
                id: id,
                filePath: filePath,
                phoneNumber: phoneNumber,
                recordedAt: recordedAt,
                complaintId: complaintId,
                markedAt: markedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProcessedRecordingsTable, ProcessedRecording>(
                    table,
                  ),
                  $$ProcessedRecordingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({complaintId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (complaintId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.complaintId,
                        referencedTable: $$ProcessedRecordingsTableReferences
                            ._complaintIdTable(db),
                        referencedColumn: $$ProcessedRecordingsTableReferences
                            ._complaintIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProcessedRecordingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProcessedRecordingsTable,
      ProcessedRecording,
      $$ProcessedRecordingsTableFilterComposer,
      $$ProcessedRecordingsTableOrderingComposer,
      $$ProcessedRecordingsTableAnnotationComposer,
      $$ProcessedRecordingsTableCreateCompanionBuilder,
      $$ProcessedRecordingsTableUpdateCompanionBuilder,
      (ProcessedRecording, $$ProcessedRecordingsTableReferences),
      ProcessedRecording,
      PrefetchHooks Function({bool complaintId})
    >;
typedef $$DiscardedRecordingsTableCreateCompanionBuilder =
    DiscardedRecordingsCompanion Function({
      Value<int> id,
      required String filePath,
      required String phoneNumber,
      required int recordedAt,
      required int discardedAt,
    });
typedef $$DiscardedRecordingsTableUpdateCompanionBuilder =
    DiscardedRecordingsCompanion Function({
      Value<int> id,
      Value<String> filePath,
      Value<String> phoneNumber,
      Value<int> recordedAt,
      Value<int> discardedAt,
    });

class $$DiscardedRecordingsTableFilterComposer
    extends Composer<_$AppDatabase, $DiscardedRecordingsTable> {
  $$DiscardedRecordingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discardedAt => $composableBuilder(
    column: $table.discardedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DiscardedRecordingsTableOrderingComposer
    extends Composer<_$AppDatabase, $DiscardedRecordingsTable> {
  $$DiscardedRecordingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discardedAt => $composableBuilder(
    column: $table.discardedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DiscardedRecordingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiscardedRecordingsTable> {
  $$DiscardedRecordingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discardedAt => $composableBuilder(
    column: $table.discardedAt,
    builder: (column) => column,
  );
}

class $$DiscardedRecordingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DiscardedRecordingsTable,
          DiscardedRecording,
          $$DiscardedRecordingsTableFilterComposer,
          $$DiscardedRecordingsTableOrderingComposer,
          $$DiscardedRecordingsTableAnnotationComposer,
          $$DiscardedRecordingsTableCreateCompanionBuilder,
          $$DiscardedRecordingsTableUpdateCompanionBuilder,
          (
            DiscardedRecording,
            BaseReferences<
              _$AppDatabase,
              $DiscardedRecordingsTable,
              DiscardedRecording
            >,
          ),
          DiscardedRecording,
          PrefetchHooks Function()
        > {
  $$DiscardedRecordingsTableTableManager(
    _$AppDatabase db,
    $DiscardedRecordingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiscardedRecordingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiscardedRecordingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DiscardedRecordingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> phoneNumber = const Value.absent(),
                Value<int> recordedAt = const Value.absent(),
                Value<int> discardedAt = const Value.absent(),
              }) => DiscardedRecordingsCompanion(
                id: id,
                filePath: filePath,
                phoneNumber: phoneNumber,
                recordedAt: recordedAt,
                discardedAt: discardedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String filePath,
                required String phoneNumber,
                required int recordedAt,
                required int discardedAt,
              }) => DiscardedRecordingsCompanion.insert(
                id: id,
                filePath: filePath,
                phoneNumber: phoneNumber,
                recordedAt: recordedAt,
                discardedAt: discardedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DiscardedRecordingsTable, DiscardedRecording>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $DiscardedRecordingsTable,
                    DiscardedRecording
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DiscardedRecordingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DiscardedRecordingsTable,
      DiscardedRecording,
      $$DiscardedRecordingsTableFilterComposer,
      $$DiscardedRecordingsTableOrderingComposer,
      $$DiscardedRecordingsTableAnnotationComposer,
      $$DiscardedRecordingsTableCreateCompanionBuilder,
      $$DiscardedRecordingsTableUpdateCompanionBuilder,
      (
        DiscardedRecording,
        BaseReferences<
          _$AppDatabase,
          $DiscardedRecordingsTable,
          DiscardedRecording
        >,
      ),
      DiscardedRecording,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ComplaintsTableTableManager get complaints =>
      $$ComplaintsTableTableManager(_db, _db.complaints);
  $$ProcessedRecordingsTableTableManager get processedRecordings =>
      $$ProcessedRecordingsTableTableManager(_db, _db.processedRecordings);
  $$DiscardedRecordingsTableTableManager get discardedRecordings =>
      $$DiscardedRecordingsTableTableManager(_db, _db.discardedRecordings);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
