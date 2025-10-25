import 'package:intl/intl.dart';

/// Utility methods to format dates and times consistently across the app.
class DateFormatter {
  DateFormatter._();

  static String friendlyDate(DateTime date) {
    return DateFormat.yMMMd().format(date.toLocal());
  }

  static String friendlyTime(DateTime date) {
    return DateFormat.jm().format(date.toLocal());
  }

  static String fullDateTime(DateTime date) {
    return DateFormat('EEE, MMM d • h:mm a').format(date.toLocal());
  }
}
