import 'package:call_log/call_log.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/phone_number_utils.dart';
import 'contact_lookup_service.dart';
import 'recording_filename_parser.dart';

class MatchedRecording {
  const MatchedRecording({
    required this.parsed,
    required this.phoneNumber,
    required this.durationSeconds,
    required this.isIncoming,
    this.callLogName,
  });

  final ParsedRecording parsed;

  /// Phone number from the filename, or resolved from the matched call log
  /// entry when the filename has none (e.g. "NAME YYYY-MM-DD HH-MM-SS").
  /// Empty when no call could be matched unambiguously.
  final String phoneNumber;
  final int durationSeconds;
  final bool isIncoming;

  /// Cached contact name from the matched call log entry, if any.
  final String? callLogName;
}

class CallLogMatcher {
  CallLogMatcher({required ContactLookupService contactLookupService})
      : _contacts = contactLookupService;

  final ContactLookupService _contacts;

  /// How close the file's last-modified time must be to the call's end time
  /// (call start + duration) to count as "this recording's call".
  static const int _endTimeToleranceMs = 15 * 1000;

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

    final List<CallLogEntry> entries;
    try {
      entries = (await CallLog.query(
        dateFrom: fromDate.millisecondsSinceEpoch,
      ))
          .where((e) => e.timestamp != null && e.number != null)
          .toList();
    } catch (_) {
      // If call log access fails, mark all as non-incoming
      return recordings.map((r) => _unmatched(r)).toList();
    }

    // Pick up contacts added/renamed since the last scan.
    _contacts.invalidateNameIndex();

    final matches = <ParsedRecording, CallLogEntry?>{};
    final usedEntries = <CallLogEntry>{};

    // Pass 1: recordings whose filename has a phone number are unambiguous.
    // Claim their calls first so name-only recordings can't reuse them.
    for (final r in recordings.where((r) => r.phoneNumber.isNotEmpty)) {
      final entry = _closest(
        _inWindow(r, entries).where(
          (e) => PhoneNumberUtils.normalize(e.number!) == r.phoneNumber,
        ),
        r,
      );
      matches[r] = entry;
      if (entry != null) usedEntries.add(entry);
    }

    // Pass 2: name-only recordings, oldest first, each claiming its call.
    final nameOnly = recordings.where((r) => r.phoneNumber.isEmpty).toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    for (final r in nameOnly) {
      final candidates = _inWindow(r, entries)
          .where((e) => !usedEntries.contains(e))
          .toList();
      final entry = await _resolveByName(r, candidates);
      matches[r] = entry;
      if (entry != null) usedEntries.add(entry);
    }

    return recordings.map((r) {
      final entry = matches[r];
      if (entry == null) return _unmatched(r);
      return MatchedRecording(
        parsed: r,
        phoneNumber: r.phoneNumber.isNotEmpty
            ? r.phoneNumber
            : PhoneNumberUtils.normalize(entry.number!),
        durationSeconds: entry.duration ?? 0,
        isIncoming: entry.callType == CallType.incoming,
        callLogName: entry.name,
      );
    }).toList();
  }

  /// Picks the call for a recording that has only a name. Returns null when
  /// the call cannot be identified with confidence — a wrong number is worse
  /// than no match, since complaints are created against this number.
  Future<CallLogEntry?> _resolveByName(
    ParsedRecording r,
    List<CallLogEntry> candidates,
  ) async {
    if (candidates.isEmpty) return null;

    // 1. Narrow by name: call log's cached name, or numbers saved under this
    //    name in the device contacts. Calls that clearly belong to someone
    //    else (call log shows a different name) are ruled out.
    final wantedName = r.contactName == RecordingFilenameParser.unknownContact
        ? ''
        : ContactLookupService.normalizeName(r.contactName);
    var pool = candidates;
    if (wantedName.isNotEmpty) {
      final contactNumbers = await _contacts.lookupNumbersByName(r.contactName);
      bool isNamed(CallLogEntry e) {
        final logName = ContactLookupService.normalizeName(e.name ?? '');
        return logName == wantedName ||
            contactNumbers.contains(PhoneNumberUtils.normalize(e.number!));
      }

      bool isSomeoneElse(CallLogEntry e) {
        final logName = ContactLookupService.normalizeName(e.name ?? '');
        return logName.isNotEmpty && !isNamed(e);
      }

      final byName = candidates.where(isNamed).toList();
      pool = byName.isNotEmpty
          ? byName
          : candidates.where((e) => !isSomeoneElse(e)).toList();
      if (pool.isEmpty) return null;
    }

    // 2. Every remaining candidate is the same number -> same person; the
    //    closest in time is the right call.
    final numbers =
        pool.map((e) => PhoneNumberUtils.normalize(e.number!)).toSet();
    if (numbers.length == 1) return _closest(pool, r);

    // 3. Different numbers: use the file's last-modified time (≈ call end)
    //    to find the one call that ended when the recording did.
    final modifiedMs = r.fileModifiedAt?.millisecondsSinceEpoch;
    if (modifiedMs != null) {
      final endMatches = pool.where((e) {
        final endMs = e.timestamp! + (e.duration ?? 0) * 1000;
        return (endMs - modifiedMs).abs() <= _endTimeToleranceMs;
      }).toList();
      if (endMatches.length == 1) return endMatches.single;
    }

    // 4. Still ambiguous: don't guess.
    return null;
  }

  Iterable<CallLogEntry> _inWindow(
    ParsedRecording r,
    List<CallLogEntry> entries,
  ) {
    final windowMs = AppConstants.callLogMatchWindowSeconds * 1000;
    final ts = r.recordedAt.millisecondsSinceEpoch;
    return entries.where((e) => (e.timestamp! - ts).abs() <= windowMs);
  }

  CallLogEntry? _closest(Iterable<CallLogEntry> entries, ParsedRecording r) {
    final ts = r.recordedAt.millisecondsSinceEpoch;
    CallLogEntry? best;
    int? bestDiff;
    for (final e in entries) {
      final diff = (e.timestamp! - ts).abs();
      if (bestDiff == null || diff < bestDiff) {
        bestDiff = diff;
        best = e;
      }
    }
    return best;
  }

  MatchedRecording _unmatched(ParsedRecording r) => MatchedRecording(
        parsed: r,
        phoneNumber: r.phoneNumber,
        durationSeconds: 0,
        isIncoming: false,
      );
}
