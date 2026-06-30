import 'package:drift/drift.dart';
import '../app_database.dart';

part 'recordings_dao.g.dart';

@DriftAccessor(tables: [ProcessedRecordings, DiscardedRecordings])
class RecordingsDao extends DatabaseAccessor<AppDatabase>
    with _$RecordingsDaoMixin {
  RecordingsDao(super.db);

  // ===== PROCESSED RECORDINGS =====

  Future<int> insertProcessedRecording(ProcessedRecordingsCompanion recording) {
    return into(processedRecordings).insert(recording);
  }

  Future<bool> isProcessed(String filePath) async {
    final result = await (select(processedRecordings)
          ..where((t) => t.filePath.equals(filePath)))
        .getSingleOrNull();
    return result != null;
  }

  Future<List<ProcessedRecording>> getAllProcessed() {
    return select(processedRecordings).get();
  }

  Future<Set<String>> getProcessedFilePaths() async {
    final results = await select(processedRecordings).get();
    return results.map((r) => r.filePath).toSet();
  }

  // ===== DISCARDED RECORDINGS =====

  Future<int> insertDiscardedRecording(DiscardedRecordingsCompanion recording) {
    return into(discardedRecordings).insert(recording);
  }

  Future<bool> isDiscarded(String filePath) async {
    final result = await (select(discardedRecordings)
          ..where((t) => t.filePath.equals(filePath)))
        .getSingleOrNull();
    return result != null;
  }

  Future<List<DiscardedRecording>> getAllDiscarded() {
    return select(discardedRecordings).get();
  }

  Future<Set<String>> getDiscardedFilePaths() async {
    final results = await select(discardedRecordings).get();
    return results.map((r) => r.filePath).toSet();
  }

  Future<int> removeDiscardedRecording(String filePath) {
    return (delete(discardedRecordings)..where((t) => t.filePath.equals(filePath))).go();
  }

  // ===== COMBINED CHECK =====

  Future<Set<String>> getAllKnownFilePaths() async {
    final processed = await getProcessedFilePaths();
    final discarded = await getDiscardedFilePaths();
    return {...processed, ...discarded};
  }
}
