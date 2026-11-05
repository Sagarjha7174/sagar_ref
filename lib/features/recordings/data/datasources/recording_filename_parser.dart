import 'dart:io';
import 'package:path/path.dart' as p;
import '../../../../core/utils/phone_number_utils.dart';

class ParsedRecording {
  const ParsedRecording({
    required this.filePath,
    required this.phoneNumber,
    required this.recordedAt,
    required this.rawFilename,
    required this.contactName,
    this.fileModifiedAt,
  });

  final String filePath;

  /// Normalized phone number, or empty string when the filename does not
  /// contain one (e.g. "NAME YYYY-MM-DD HH-MM-SS" format). In that case the
  /// number is resolved later from the call log.
  final String phoneNumber;
  final DateTime recordedAt;
  final String rawFilename;
  final String contactName;

  /// File's last-modified time. The recorder finishes writing when the call
  /// ends, so this approximates the call end time; used to tell apart calls
  /// that are close together. Null if it could not be read.
  final DateTime? fileModifiedAt;
}

class RecordingFilenameParser {
  static const String unknownContact = 'Unknown Contact';

  // Current pattern: "{NAME} {YYYY-MM-DD} {HH-MM-SS}.{mp3|m4a}" (24-hour clock)
  // e.g. "Narayan Das Soni 2026-06-11 19-34-18.mp3"
  //      "+91 79745 05088 2026-06-11 07-05-09.mp3" (unsaved number as name)
  static final RegExp _nameDateTimePattern = RegExp(
    r'^(.+?)\s+(\d{4})-(\d{2})-(\d{2})\s+(\d{2})-(\d{2})-(\d{2})\.(?:mp3|m4a)$',
    caseSensitive: false,
  );

  // Legacy MIUI pattern: {name or phone}({phone})_{yyyyMMddHHmmss}.mp3
  // e.g. "Narayan Das Soni(00917974505088)_20260611193418.mp3"
  static final RegExp _miuiPattern = RegExp(
    r'^([^\(]+)\(([^)]+)\)_(\d{14})\.(?:mp3|m4a)$',
    caseSensitive: false,
  );

  // Legacy simple pattern: {phone}_{yyyyMMddHHmmss}.mp3
  static final RegExp _simplePattern = RegExp(
    r'^(\d+)_(\d{14})\.(?:mp3|m4a)$',
    caseSensitive: false,
  );

  // A "name" made only of phone-number characters with at least 7 digits.
  static final RegExp _phoneLike = RegExp(r'^[\d\s+\-()]+$');

  ParsedRecording? parse(String filePath) {
    final filename = p.basename(filePath);
    final modifiedAt = _lastModified(filePath);

    // Current format: NAME YYYY-MM-DD HH-MM-SS
    var match = _nameDateTimePattern.firstMatch(filename);
    if (match != null) {
      final recordedAt = _buildDateTime(
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        int.parse(match.group(4)!),
        int.parse(match.group(5)!),
        int.parse(match.group(6)!),
        int.parse(match.group(7)!),
      );
      if (recordedAt != null) {
        final name = match.group(1)!.trim();
        final nameIsPhone = _looksLikePhone(name);
        return ParsedRecording(
          filePath: filePath,
          phoneNumber: nameIsPhone ? PhoneNumberUtils.normalize(name) : '',
          recordedAt: recordedAt,
          rawFilename: filename,
          contactName: nameIsPhone ? unknownContact : name,
          fileModifiedAt: modifiedAt,
        );
      }
    }

    // Legacy MIUI format
    match = _miuiPattern.firstMatch(filename);
    if (match != null) {
      final name = match.group(1)!.trim();
      final parsed = _buildLegacy(
        filePath,
        filename,
        match.group(2)!,
        match.group(3)!,
        _looksLikePhone(name) ? unknownContact : name,
        modifiedAt,
      );
      if (parsed != null) return parsed;
    }

    // Legacy simple format
    match = _simplePattern.firstMatch(filename);
    if (match != null) {
      final parsed = _buildLegacy(
        filePath,
        filename,
        match.group(1)!,
        match.group(2)!,
        unknownContact,
        modifiedAt,
      );
      if (parsed != null) return parsed;
    }

    // Fallback: unknown format. Use a 10+ digit run as phone (if any) and the
    // file's modification time as the recording time.
    final digitMatch = RegExp(r'\d{10,}').firstMatch(filename);

    return ParsedRecording(
      filePath: filePath,
      phoneNumber: digitMatch != null
          ? PhoneNumberUtils.normalize(digitMatch.group(0)!)
          : '',
      recordedAt: modifiedAt ?? DateTime.now(),
      rawFilename: filename,
      contactName: unknownContact,
      fileModifiedAt: modifiedAt,
    );
  }

  DateTime? _lastModified(String filePath) {
    try {
      return File(filePath).lastModifiedSync();
    } catch (_) {
      return null;
    }
  }

  bool _looksLikePhone(String s) =>
      _phoneLike.hasMatch(s) && s.replaceAll(RegExp(r'\D'), '').length >= 7;

  ParsedRecording? _buildLegacy(
    String filePath,
    String filename,
    String rawPhone,
    String rawTimestamp,
    String contactName,
    DateTime? modifiedAt,
  ) {
    final recordedAt = _buildDateTime(
      int.parse(rawTimestamp.substring(0, 4)),
      int.parse(rawTimestamp.substring(4, 6)),
      int.parse(rawTimestamp.substring(6, 8)),
      int.parse(rawTimestamp.substring(8, 10)),
      int.parse(rawTimestamp.substring(10, 12)),
      int.parse(rawTimestamp.substring(12, 14)),
    );
    if (recordedAt == null) return null;

    return ParsedRecording(
      filePath: filePath,
      phoneNumber: PhoneNumberUtils.normalize(rawPhone),
      recordedAt: recordedAt,
      rawFilename: filename,
      contactName: contactName,
      fileModifiedAt: modifiedAt,
    );
  }

  /// Builds a local DateTime from 24-hour components. Returns null for
  /// invalid values (DateTime would otherwise silently roll them over,
  /// e.g. month 13 -> January of next year).
  DateTime? _buildDateTime(
    int year,
    int month,
    int day,
    int hour,
    int minute,
    int second,
  ) {
    if (month < 1 || month > 12 || hour > 23 || minute > 59 || second > 59) {
      return null;
    }
    final dt = DateTime(year, month, day, hour, minute, second);
    if (dt.month != month || dt.day != day) return null; // e.g. Feb 30
    return dt;
  }
}
