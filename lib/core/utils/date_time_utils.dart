import 'package:intl/intl.dart';

class DateTimeUtils {
  const DateTimeUtils._();

  static String formatDate(DateTime? value) {
    if (value == null) return '—';
    return DateFormat('dd MMM yyyy').format(value.toLocal());
  }

  static String formatTime(DateTime? value) {
    if (value == null) return '—';
    return DateFormat('hh:mm a').format(value.toLocal());
  }

  static String ymd(DateTime value) => DateFormat('yyyy-MM-dd').format(value);

  static DateTime? tryParse(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
