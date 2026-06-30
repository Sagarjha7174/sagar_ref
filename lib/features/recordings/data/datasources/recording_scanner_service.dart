import 'dart:io';
import 'package:logger/logger.dart';
import '../../../../core/database/daos/recordings_dao.dart';
import 'recording_filename_parser.dart';

class RecordingScannerService {
  RecordingScannerService({
    required RecordingFilenameParser parser,
    required RecordingsDao recordingsDao,
    Logger? logger,
  })  : _parser = parser,
        _recordingsDao = recordingsDao,
        _logger = logger ?? Logger();

  final RecordingFilenameParser _parser;
  final RecordingsDao _recordingsDao;
  final Logger _logger;

  /// Scans [folderPath] for new recording files.
  ///
  /// If [since] is provided, only files modified after [since] are considered,
  /// enabling fast incremental scans. Pass null for a full scan.
  Future<List<ParsedRecording>> scanFolder(
    String folderPath, {
    DateTime? since,
  }) async {
    if (folderPath.isEmpty) return [];

    _logger.d('Scanning folder: $folderPath (since: $since)');
    final dir = Directory(folderPath);
    if (!await dir.exists()) {
      _logger.w('Directory does not exist: $folderPath');
      return [];
    }

    // Get already processed and discarded file paths
    final knownPaths = await _recordingsDao.getAllKnownFilePaths();
    _logger.d('Found ${knownPaths.length} known (processed/discarded) recordings in database');

    final results = <ParsedRecording>[];

    try {
      final entities = dir.listSync(recursive: false);
      _logger.d('Directory listing returned ${entities.length} entities');

      for (final entity in entities) {
        if (entity is! File) continue;
        if (!entity.path.toLowerCase().endsWith('.mp3')) continue;

        // Skip already processed or discarded
        if (knownPaths.contains(entity.path)) {
          _logger.d('Skipped known: ${entity.path}');
          continue;
        }

        // Incremental: skip files older than `since`
        if (since != null) {
          try {
            final lastModified = entity.lastModifiedSync();
            if (lastModified.isBefore(since)) {
              continue; // File existed before last scan, skip silently
            }
          } catch (_) {
            // If we can't read lastModified, process the file anyway
          }
        }

        final parsed = _parser.parse(entity.path);
        if (parsed != null) {
          _logger.d('Parsed: ${parsed.contactName}, ${parsed.phoneNumber}');
          results.add(parsed);
        } else {
          _logger.d('Skipped: failed to parse ${entity.path}');
        }
      }
    } catch (e) {
      _logger.e('Failed to read folder entries: $e');
    }

    // Sort by recorded date, newest first
    results.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    _logger.d('Scan complete. Found ${results.length} new recordings.');
    return results;
  }
}

