import 'dart:io';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/recordings_dao.dart';
import '../../../../core/database/daos/settings_dao.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/permissions/permission_service.dart';
import '../../domain/entities/recording_item.dart';
import '../../domain/repositories/recordings_repository.dart';
import '../datasources/recording_scanner_service.dart';
import '../datasources/recording_scan_cache_service.dart';
import '../datasources/recording_filename_parser.dart';
import '../datasources/call_log_matcher.dart';
import '../datasources/contact_lookup_service.dart';

class RecordingsRepositoryImpl implements RecordingsRepository {
  RecordingsRepositoryImpl({
    required RecordingScannerService scannerService,
    required RecordingScanCacheService cacheService,
    required CallLogMatcher callLogMatcher,
    required ContactLookupService contactLookupService,
    required RecordingsDao recordingsDao,
    required SettingsDao settingsDao,
    required PermissionService permissionService,
  })  : _scannerService = scannerService,
        _cacheService = cacheService,
        _callLogMatcher = callLogMatcher,
        _contactLookupService = contactLookupService,
        _recordingsDao = recordingsDao,
        _settingsDao = settingsDao,
        _permissionService = permissionService;

  final RecordingScannerService _scannerService;
  final RecordingScanCacheService _cacheService;
  final CallLogMatcher _callLogMatcher;
  final ContactLookupService _contactLookupService;
  final RecordingsDao _recordingsDao;
  final SettingsDao _settingsDao;
  final PermissionService _permissionService;

  // ===== CACHED (instant) =====

  @override
  Future<Result<List<RecordingItem>>> getCachedRecordings() async {
    try {
      final folderPath = await _settingsDao.getValue(
        AppConstants.keyRecordingFolderPath,
      );
      if (folderPath == null || folderPath.isEmpty) {
        return Result.success([]);
      }

      if (!_cacheService.isCacheValid(folderPath)) {
        return Result.success([]);
      }

      final cached = _cacheService.getCachedRecordings().where((r) => r.isIncoming).toList();
      return Result.success(cached);
    } catch (e) {
      return Result.success([]); // Cache miss is not an error
    }
  }

  // ===== INCREMENTAL SCAN =====

  @override
  Future<Result<List<RecordingItem>>> scanNewRecordings() async {
    try {
      // Check permissions
      final hasPerms = await _permissionService.hasAllRequiredPermissions();
      if (!hasPerms) {
        return Result.failure(const PermissionDeniedFailure(
          'Required permissions are not granted. Please grant storage, call log, and contacts permissions.',
        ));
      }

      // Get recording folder path
      final folderPath = await _settingsDao.getValue(
        AppConstants.keyRecordingFolderPath,
      );
      if (folderPath == null || folderPath.isEmpty) {
        return Result.success([]);
      }

      // Get cached data, dropping recordings whose file was deleted
      final cachedAll = _cacheService.isCacheValid(folderPath)
          ? _cacheService.getCachedRecordings()
          : <RecordingItem>[];
      final cachedRecordings =
          cachedAll.where((r) => File(r.filePath).existsSync()).toList();
      final lastScan = _cacheService.getLastScanTimestamp();

      // Incremental scan with a 1-day look-back: a recording can appear
      // before its call-log entry is written, so files that could not be
      // matched on an earlier scan get another chance.
      final existingPaths = cachedRecordings.map((r) => r.filePath).toSet();
      final parsedRecordings = (await _scannerService.scanFolder(
        folderPath,
        since: lastScan?.subtract(const Duration(days: 1)),
      ))
          .where((r) => !existingPaths.contains(r.filePath))
          .toList();

      if (parsedRecordings.isEmpty) {
        // No new files — return cached as-is, but update cache timestamp
        await _cacheService.cacheRecordings(cachedRecordings, folderPath);
        return Result.success(cachedRecordings);
      }

      // Process only the new recordings
      final newItems = await _processRecordings(parsedRecordings);

      final merged = [...newItems, ...cachedRecordings];
      // Sort by recorded date, newest first
      merged.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

      // Update cache
      await _cacheService.cacheRecordings(merged, folderPath);

      return Result.success(merged);
    } catch (e) {
      return Result.failure(DatabaseFailure('Incremental scan failed: $e'));
    }
  }

  // ===== FULL RESCAN =====

  @override
  Future<Result<List<RecordingItem>>> scanRecordings() async {
    try {
      // Check permissions
      final hasPerms = await _permissionService.hasAllRequiredPermissions();
      if (!hasPerms) {
        return Result.failure(const PermissionDeniedFailure(
          'Required permissions are not granted. Please grant storage, call log, and contacts permissions.',
        ));
      }

      // Get recording folder path
      final folderPath = await _settingsDao.getValue(
        AppConstants.keyRecordingFolderPath,
      );
      if (folderPath == null || folderPath.isEmpty) {
        return Result.success([]);
      }

      // Full scan (no `since`)
      final parsedRecordings = await _scannerService.scanFolder(folderPath);
      if (parsedRecordings.isEmpty) {
        await _cacheService.cacheRecordings([], folderPath);
        return Result.success([]);
      }

      final results = await _processRecordings(parsedRecordings);

      // Update cache with full results
      await _cacheService.cacheRecordings(results, folderPath);

      return Result.success(results);
    } catch (e) {
      return Result.failure(DatabaseFailure('Scan failed: $e'));
    }
  }

  // ===== SHARED PROCESSING =====

  /// Process parsed recordings: match with call logs + contact lookup.
  Future<List<RecordingItem>> _processRecordings(
    List<ParsedRecording> parsedRecordings,
  ) async {
    final matchedRecordings =
        await _callLogMatcher.matchRecordings(parsedRecordings);

    final results = <RecordingItem>[];
    for (final matched in matchedRecordings) {
      if (!matched.isIncoming) continue;
      var contactName = matched.phoneNumber.isNotEmpty
          ? await _contactLookupService.lookupContact(matched.phoneNumber)
          : 'Unknown';
      if (contactName == 'Unknown') {
        // Fall back to the name in the filename, then the call log's name.
        final callLogName = matched.callLogName?.trim() ?? '';
        contactName = matched.parsed.contactName !=
                    RecordingFilenameParser.unknownContact ||
                callLogName.isEmpty
            ? matched.parsed.contactName
            : callLogName;
      }
      results.add(RecordingItem(
        filePath: matched.parsed.filePath,
        phoneNumber: matched.phoneNumber,
        contactName: contactName,
        recordedAt: matched.parsed.recordedAt,
        durationSeconds: matched.durationSeconds,
        isIncoming: matched.isIncoming,
      ));
    }

    return results;
  }

  // ===== CACHE MANAGEMENT =====

  @override
  Future<void> clearScanCache() async {
    await _cacheService.clearCache();
  }

  // ===== EXISTING METHODS (unchanged) =====

  @override
  Future<Result<void>> discardRecording(RecordingItem recording) async {
    try {
      await _recordingsDao.insertDiscardedRecording(
        DiscardedRecordingsCompanion.insert(
          filePath: recording.filePath,
          phoneNumber: recording.phoneNumber,
          recordedAt: recording.recordedAt.millisecondsSinceEpoch,
          discardedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      // Also remove from cache
      final folderPath = await _settingsDao.getValue(
        AppConstants.keyRecordingFolderPath,
      );
      if (folderPath != null && _cacheService.isCacheValid(folderPath)) {
        final cached = _cacheService.getCachedRecordings();
        final updated =
            cached.where((r) => r.filePath != recording.filePath).toList();
        await _cacheService.cacheRecordings(updated, folderPath);
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to discard: $e'));
    }
  }

  @override
  Future<Result<void>> markRecordingProcessed(
    RecordingItem recording,
    int complaintId,
  ) async {
    try {
      await _recordingsDao.insertProcessedRecording(
        ProcessedRecordingsCompanion.insert(
          filePath: recording.filePath,
          phoneNumber: recording.phoneNumber,
          recordedAt: recording.recordedAt.millisecondsSinceEpoch,
          complaintId: Value(complaintId),
          markedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      // Also remove from cache
      final folderPath = await _settingsDao.getValue(
        AppConstants.keyRecordingFolderPath,
      );
      if (folderPath != null && _cacheService.isCacheValid(folderPath)) {
        final cached = _cacheService.getCachedRecordings();
        final updated =
            cached.where((r) => r.filePath != recording.filePath).toList();
        await _cacheService.cacheRecordings(updated, folderPath);
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to mark processed: $e'));
    }
  }

  @override
  Future<Result<List<RecordingItem>>> getDiscardedRecordings() async {
    try {
      final dbItems = await _recordingsDao.getAllDiscarded();
      final results = <RecordingItem>[];
      for (final item in dbItems) {
        var contactName = await _contactLookupService.lookupContact(item.phoneNumber);
        if (contactName == 'Unknown') {
          contactName = 'Unknown Contact';
        }
        results.add(RecordingItem(
          filePath: item.filePath,
          phoneNumber: item.phoneNumber,
          contactName: contactName,
          recordedAt: DateTime.fromMillisecondsSinceEpoch(item.recordedAt),
          durationSeconds: 0,
          isIncoming: true,
        ));
      }
      return Result.success(results);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to fetch discarded recordings: $e'));
    }
  }

  @override
  Future<Result<void>> restoreRecording(String filePath) async {
    try {
      await _recordingsDao.removeDiscardedRecording(filePath);
      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to restore recording: $e'));
    }
  }
}
