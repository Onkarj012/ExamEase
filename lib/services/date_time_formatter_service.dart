import 'dart:ui';

import 'package:intl/intl.dart';

class DateTimeFormatterService {

  static String formatDate(DateTime date, {Locale? locale}) {
    final now = DateTime.now();
    final difference = now.difference(date);

    final timeFormatter = DateFormat.Hm(locale?.toLanguageTag() ?? 'en_US');
    final dateFormatter = DateFormat('d MMM yyyy, H:mm', locale?.toLanguageTag() ?? 'en_US');

    if (difference.inDays == 0) {
      return "Today, ${timeFormatter.format(date)}";
    } else if (difference.inDays == 1) {
      return "Yesterday, ${timeFormatter.format(date)}";
    } else if (difference.inDays == -1) {
      return "Tomorrow, ${timeFormatter.format(date)}";
    } else {
      return dateFormatter.format(date);
    }
  }
}
