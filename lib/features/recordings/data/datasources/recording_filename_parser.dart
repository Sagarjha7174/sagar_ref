import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import '../../../../core/utils/phone_number_utils.dart';

class ParsedRecording {
  const ParsedRecording({
    required this.filePath,
    required this.phoneNumber,
    required this.recordedAt,
    required this.rawFilename,
    required this.contactName,
  });

  final String filePath;
  final String phoneNumber;
  final DateTime recordedAt;
  final String rawFilename;
  final String contactName;
}

class RecordingFilenameParser {
  // MIUI pattern: {name or phone}({phone})_{yyyyMMddHHmmss}.mp3
  // e.g. "Narayan Das Soni(00917974505088)_20260611193418.mp3" or "00917974505088(00917974505088)_20260611193418.mp3"
  static final RegExp _miuiPattern = RegExp(
    r'^([^\(]+)\(([^)]+)\)_(\d{14})\.mp3$',
    caseSensitive: false,
  );

  // Alternate simpler pattern: {phone}_{yyyyMMddHHmmss}.mp3
  static final RegExp _simplePattern = RegExp(
    r'^(\d+)_(\d{14})\.mp3$',
    caseSensitive: false,
  );

  static final DateFormat _timestampFormat = DateFormat('yyyyMMddHHmmss');

  ParsedRecording? parse(String filePath) {
    final filename = p.basename(filePath);

    // Try MIUI pattern first
    var match = _miuiPattern.firstMatch(filename);
    if (match != null) {
      return _buildParsed(
        filePath,
        filename,
        match.group(2)!,
        match.group(3)!,
      );
    }

    // Try simple pattern
    match = _simplePattern.firstMatch(filename);
    if (match != null) {
      return _buildParsed(filePath, filename, match.group(1)!, match.group(2)!);
    }

    // Fallback: match any .mp3 file
    // Extract any sequence of digits (preferring 10+ digits for local numbers)
    final digitMatch = RegExp(r'\d{10,}').firstMatch(filename) ?? RegExp(r'\d+').firstMatch(filename);
    final phone = digitMatch?.group(0) ?? 'Unknown';

    DateTime recordedAt;
    try {
      recordedAt = File(filePath).lastModifiedSync();
    } catch (_) {
      recordedAt = DateTime.now();
    }

    return ParsedRecording(
      filePath: filePath,
      phoneNumber: PhoneNumberUtils.normalize(phone),
      recordedAt: recordedAt,
      rawFilename: filename,
      contactName: 'Unknown Contact',
    );
  }

  ParsedRecording? _buildParsed(
    String filePath,
    String filename,
    String rawPhone,
    String rawTimestamp,
  ) {
    try {
      final phoneNumber = PhoneNumberUtils.normalize(rawPhone);
      
      // Manually parse 14-digit timestamp to avoid locale-specific DateFormat parsing issues
      final year = int.parse(rawTimestamp.substring(0, 4));
      final month = int.parse(rawTimestamp.substring(4, 6));
      final day = int.parse(rawTimestamp.substring(6, 8));
      final hour = int.parse(rawTimestamp.substring(8, 10));
      final minute = int.parse(rawTimestamp.substring(10, 12));
      final second = int.parse(rawTimestamp.substring(12, 14));
      final recordedAt = DateTime(year, month, day, hour, minute, second);

      return ParsedRecording(
        filePath: filePath,
        phoneNumber: phoneNumber,
        recordedAt: recordedAt,
        rawFilename: filename,
        contactName: 'Unknown Contact',
      );
    } catch (e) {
      print('Error in _buildParsed: $e for rawPhone: $rawPhone, rawTimestamp: $rawTimestamp');
      return null;
    }
  }
}
