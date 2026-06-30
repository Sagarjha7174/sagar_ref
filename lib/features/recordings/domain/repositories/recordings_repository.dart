import '../../domain/entities/recording_item.dart';
import '../../../../core/errors/result.dart';

abstract class RecordingsRepository {
  /// Full rescan of the recordings folder (ignores cache).
  Future<Result<List<RecordingItem>>> scanRecordings();

  /// Returns cached recordings from the last scan (instant, no disk I/O).
  Future<Result<List<RecordingItem>>> getCachedRecordings();

  /// Incremental scan: only processes files newer than the last scan.
  /// Returns the full merged list (cached + new).
  Future<Result<List<RecordingItem>>> scanNewRecordings();

  Future<Result<void>> discardRecording(RecordingItem recording);
  Future<Result<void>> markRecordingProcessed(RecordingItem recording, int complaintId);
  Future<Result<List<RecordingItem>>> getDiscardedRecordings();
  Future<Result<void>> restoreRecording(String filePath);

  /// Clears the scan cache (call when folder path changes).
  Future<void> clearScanCache();
}

