import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../../core/utils/phone_number_utils.dart';

/// Looks up device contacts by number or by name.
///
/// Contacts are loaded once into an in-memory index (instead of once per
/// lookup) and refreshed on every recordings scan via [invalidateNameIndex].
class ContactLookupService {
  /// normalized phone number -> display name
  Map<String, String>? _nameByNumber;

  /// normalized display name -> normalized phone numbers saved under it
  Map<String, Set<String>>? _numbersByName;

  Future<void>? _loading;

  Future<void> _ensureLoaded() {
    if (_nameByNumber != null && _numbersByName != null) {
      return Future.value();
    }
    return _loading ??= _load().whenComplete(() => _loading = null);
  }

  Future<void> _load() async {
    final byNumber = <String, String>{};
    final byName = <String, Set<String>>{};
    try {
      final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.phone},
      );
      for (final contact in contacts) {
        final displayName = contact.displayName?.trim() ?? '';
        final nameKey = normalizeName(displayName);
        for (final phone in contact.phones) {
          final number = PhoneNumberUtils.normalize(phone.number);
          if (number.isEmpty) continue;
          if (displayName.isNotEmpty) byNumber.putIfAbsent(number, () => displayName);
          if (nameKey.isNotEmpty) {
            byName.putIfAbsent(nameKey, () => <String>{}).add(number);
          }
        }
      }
    } catch (_) {
      // Contacts unavailable (e.g. permission denied): empty index.
    }
    _nameByNumber = byNumber;
    _numbersByName = byName;
  }

  /// Display name saved for [phoneNumber], or 'Unknown'.
  Future<String> lookupContact(String phoneNumber) async {
    final normalized = PhoneNumberUtils.normalize(phoneNumber);
    if (normalized.isEmpty) return 'Unknown';
    await _ensureLoaded();
    return _nameByNumber![normalized] ?? 'Unknown';
  }

  /// All normalized phone numbers of contacts whose display name equals
  /// [name] (case/whitespace-insensitive).
  Future<Set<String>> lookupNumbersByName(String name) async {
    final key = normalizeName(name);
    if (key.isEmpty) return const {};
    await _ensureLoaded();
    return _numbersByName![key] ?? const {};
  }

  static String normalizeName(String name) =>
      name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// Forces the contacts index to be reloaded on next use (picks up contacts
  /// added or renamed since the last scan).
  void invalidateNameIndex() {
    _nameByNumber = null;
    _numbersByName = null;
  }

  void clearCache() => invalidateNameIndex();
}
