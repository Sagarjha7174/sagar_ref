import 'package:call_log/call_log.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/phone_number_utils.dart';
import 'recording_filename_parser.dart';

class MatchedRecording {
  const MatchedRecording({
    required this.parsed,
    required this.durationSeconds,
    required this.isIncoming,
  });

  final ParsedRecording parsed;
  final int durationSeconds;
  final bool isIncoming;
}

class CallLogMatcher {
  Future<List<MatchedRecording>> matchRecordings(
    List<ParsedRecording> recordings,
  ) async {
    if (recordings.isEmpty) return [];

    // Find the earliest recording to limit call log query
    final earliest = recordings.fold<DateTime>(
      recordings.first.recordedAt,
      (min, r) => r.recordedAt.isBefore(min) ? r.recordedAt : min,
    );

    // Query call logs from a day before earliest recording
    final fromDate = earliest.subtract(const Duration(days: 1));

    final Iterable<CallLogEntry> entries;
    try {
      entries = await CallLog.query(
        dateFrom: fromDate.millisecondsSinceEpoch,
      );
    } catch (_) {
      // If call log access fails, mark all as non-incoming
      return recordings
          .map((r) => MatchedRecording(
                parsed: r,
                durationSeconds: 0,
                isIncoming: false,
              ))
          .toList();
    }

    final results = <MatchedRecording>[];
    final entriesList = entries.toList();

    for (final recording in recordings) {
      final match = _findBestMatch(recording, entriesList);

      if (match != null && match.callType == CallType.incoming) {
        results.add(MatchedRecording(
          parsed: recording,
          durationSeconds: match.duration ?? 0,
          isIncoming: true,
        ));
      } else {
        results.add(MatchedRecording(
          parsed: recording,
          durationSeconds: match?.duration ?? 0,
          isIncoming: false,
        ));
      }
    }

    return results;
  }

  CallLogEntry? _findBestMatch(
    ParsedRecording recording,
    List<CallLogEntry> entries,
  ) {
    final windowMs = AppConstants.callLogMatchWindowSeconds * 1000;
    final recordingTimestamp = recording.recordedAt.millisecondsSinceEpoch;

    CallLogEntry? bestMatch;
    int bestDiff = windowMs + 1;

    for (final entry in entries) {
      if (entry.timestamp == null || entry.number == null) continue;

      // Check phone number match
      final entryPhone = PhoneNumberUtils.normalize(entry.number!);
      if (entryPhone != recording.phoneNumber) continue;

      // Check timestamp within window
      final diff = (entry.timestamp! - recordingTimestamp).abs();
      if (diff <= windowMs && diff < bestDiff) {
        bestDiff = diff;
        bestMatch = entry;
      }
    }

    return bestMatch;
  }
}
