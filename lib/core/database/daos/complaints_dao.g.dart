// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaints_dao.dart';

// ignore_for_file: type=lint
mixin _$ComplaintsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ComplaintsTable get complaints => attachedDatabase.complaints;
  ComplaintsDaoManager get managers => ComplaintsDaoManager(this);
}

class ComplaintsDaoManager {
  final _$ComplaintsDaoMixin _db;
  ComplaintsDaoManager(this._db);
  $$ComplaintsTableTableManager get complaints =>
      $$ComplaintsTableTableManager(_db.attachedDatabase, _db.complaints);
}
