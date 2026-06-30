import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../../core/utils/phone_number_utils.dart';

class ContactLookupService {
  final Map<String, String> _cache = {};

  Future<String> lookupContact(String phoneNumber) async {
    final normalized = PhoneNumberUtils.normalize(phoneNumber);

    // Check cache first
    if (_cache.containsKey(normalized)) {
      return _cache[normalized]!;
    }

    try {
      final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.phone},
      );

      for (final contact in contacts) {
        for (final phone in contact.phones) {
          final contactPhone = PhoneNumberUtils.normalize(phone.number);
          if (contactPhone == normalized) {
            _cache[normalized] = contact.displayName ?? 'Unknown';
            return contact.displayName ?? 'Unknown';
          }
        }
      }
    } catch (_) {
      // If contacts access fails, return Unknown
    }

    _cache[normalized] = 'Unknown';
    return 'Unknown';
  }

  void clearCache() {
    _cache.clear();
  }
}
