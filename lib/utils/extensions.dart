import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String get yearMonthDay => this.toIso8601String().substring(0, 10);

  String get yearMonth => '${DateFormat("yyyy-MM").format(this)}';

  String get yearMonthDayHourMinuteSecond =>
      '${this.year}${this.month}${this.day}${this.hour}${this.minute}${this.second}';

  String get yearMonthDayHourMinute =>
      '${this.year}${this.month}${this.day}${this.hour}${this.minute}';
}

timeCalculationText(int minutes) {
  if (minutes < 60) {
    return '$minutes분전';
  } else if (minutes < 1440) {
    return '${(minutes / 60).toStringAsFixed(0)}시간전';
  } else {
    return '${(minutes / 1440).toStringAsFixed(0)}일전';
  }
}
