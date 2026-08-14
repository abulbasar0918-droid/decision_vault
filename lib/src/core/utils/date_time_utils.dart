/// Date-time utilities for Decision Vault.
///
/// These helpers keep formatting and parsing logic centralized so any date-time
/// handling is easy to manage and test.
class DateTimeUtils {
  DateTimeUtils._();

  static String formatIso8601(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  static DateTime parseIso8601(String raw) {
    return DateTime.parse(raw);
  }
}
