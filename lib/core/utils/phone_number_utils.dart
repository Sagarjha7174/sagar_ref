  class PhoneNumberUtils {
    PhoneNumberUtils._();

    /// Normalize a phone number to 10-digit Indian local format.
    /// Strips: leading 0091, +91, 91 (if result is 10 digits).
    /// Returns original if cannot normalize.
    static String normalize(String raw) {
      String digits = raw.replaceAll(RegExp(r'\D'), '');
      if (digits.length == 14 && digits.startsWith('0091')) {
        digits = digits.substring(4);
      } else if (digits.length == 13 && digits.startsWith('091')) {
        digits = digits.substring(3);
      } else if (digits.length == 12 && digits.startsWith('91')) {
        digits = digits.substring(2);
      } else if (digits.length == 11 && digits.startsWith('0')) {
        digits = digits.substring(1);
      }
      return digits.length == 10 ? digits : raw;
    }

    /// Compare two phone numbers after normalization.
    static bool matches(String a, String b) {
      return normalize(a) == normalize(b);
    }

    /// Format phone number for display (add spaces)
    static String formatForDisplay(String number) {
      final normalized = normalize(number);
      if (normalized.length == 10) {
        return '${normalized.substring(0, 5)} ${normalized.substring(5)}';
      }
      return number;
    }
  }
