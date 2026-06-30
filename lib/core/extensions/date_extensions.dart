import 'package:intl/intl.dart';

extension DateFormatting on DateTime {
  String toDisplayDate() => DateFormat('dd MMM yyyy').format(this);
  String toDisplayTime() => DateFormat('hh:mm a').format(this);
  String toDisplayDateTime() => DateFormat('dd MMM yyyy, hh:mm a').format(this);
  String toMonthYear() => DateFormat('MMM yyyy').format(this);
  String toMonthAbbr() => DateFormat('MMM').format(this);
  String toFileTimestamp() => DateFormat('yyyyMMdd_HHmmss').format(this);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool isSameWeek(DateTime other) {
    final thisMonday = subtract(Duration(days: weekday - 1));
    final otherMonday = other.subtract(Duration(days: other.weekday - 1));
    return thisMonday.isSameDay(otherMonday);
  }

  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  bool isInRange(DateTime start, DateTime end) {
    final dayStart = DateTime(start.year, start.month, start.day);
    final dayEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
        isBefore(dayEnd.add(const Duration(seconds: 1)));
  }
}
