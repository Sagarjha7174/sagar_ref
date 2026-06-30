// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recordings_dao.dart';

// ignore_for_file: type=lint
mixin _$RecordingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ComplaintsTable get complaints => attachedDatabase.complaints;
  $ProcessedRecordingsTable get processedRecordings =>
      attachedDatabase.processedRecordings;
  $DiscardedRecordingsTable get discardedRecordings =>
      attachedDatabase.discardedRecordings;
  RecordingsDaoManager get managers => RecordingsDaoManager(this);
}

class RecordingsDaoManager {
  final _$RecordingsDaoMixin _db;
  RecordingsDaoManager(this._db);
  $$ComplaintsTableTableManager get complaints =>
      $$ComplaintsTableTableManager(_db.attachedDatabase, _db.complaints);
  $$ProcessedRecordingsTableTableManager get processedRecordings =>
      $$ProcessedRecordingsTableTableManager(
        _db.attachedDatabase,
        _db.processedRecordings,
      );
  $$DiscardedRecordingsTableTableManager get discardedRecordings =>
      $$DiscardedRecordingsTableTableManager(
        _db.attachedDatabase,
        _db.discardedRecordings,
      );
}
