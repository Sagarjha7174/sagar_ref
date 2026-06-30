import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/recording_item.dart';

class RecordingScanCacheService {
  RecordingScanCacheService({
    required SharedPreferences prefs,
    Logger? logger,
  })  : _prefs = prefs,
        _logger = logger ?? Logger();

  final SharedPreferences _prefs;
  final Logger _logger;

  static const String _cacheKey = 'recording_scan_cache';
  static const String _timestampKey = 'recording_scan_timestamp';
  static const String _folderPathKey = 'recording_scan_folder_path';

  /// Returns cached recording items from last successful scan.
  /// Returns empty list if no cache exists.
  List<RecordingItem> getCachedRecordings() {
    try {
      final jsonStr = _prefs.getString(_cacheKey);
      if (jsonStr == null || jsonStr.isEmpty) return [];

      final List<dynamic> jsonList = json.decode(jsonStr) as List<dynamic>;
      final results = jsonList
          .map((e) => RecordingItem.fromJson(e as Map<String, dynamic>))
          .toList();

      _logger.d('Loaded ${results.length} recordings from cache');
      return results;
    } catch (e) {
      _logger.e('Failed to load recordings cache: $e');
      return [];
    }
  }

  /// Persists the current scan results and updates the timestamp.
  Future<void> cacheRecordings(
    List<RecordingItem> recordings,
    String folderPath,
  ) async {
    try {
      final jsonStr = json.encode(
        recordings.map((r) => r.toJson()).toList(),
      );
      await _prefs.setString(_cacheKey, jsonStr);
      await _prefs.setInt(
        _timestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      await _prefs.setString(_folderPathKey, folderPath);

      _logger.d('Cached ${recordings.length} recordings');
    } catch (e) {
      _logger.e('Failed to cache recordings: $e');
    }
  }

  /// Returns the timestamp of the last successful scan, or null if never scanned.
  DateTime? getLastScanTimestamp() {
    final ms = _prefs.getInt(_timestampKey);
    if (ms == null || ms == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// Returns the folder path from the last scan, or null if never scanned.
  String? getCachedFolderPath() {
    return _prefs.getString(_folderPathKey);
  }

  /// Checks if the cache is valid for the given folder path.
  /// Cache is invalid if folder path changed or no cache exists.
  bool isCacheValid(String currentFolderPath) {
    final cachedPath = getCachedFolderPath();
    if (cachedPath == null || cachedPath != currentFolderPath) return false;
    final timestamp = getLastScanTimestamp();
    return timestamp != null;
  }

  /// Clears all cached data. Call when recording folder changes.
  Future<void> clearCache() async {
    await _prefs.remove(_cacheKey);
    await _prefs.remove(_timestampKey);
    await _prefs.remove(_folderPathKey);
    _logger.d('Recording scan cache cleared');
  }
}
