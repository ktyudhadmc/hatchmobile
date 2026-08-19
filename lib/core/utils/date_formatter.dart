import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

class DateFormatter {
  DateFormatter._();

  static String format(DateTime date) => DateFormat(AppConstants.dateFormat).format(date);

  static String formatDateTime(DateTime date) => DateFormat(AppConstants.dateTimeFormat).format(date);

  static String toApiFormat(DateTime date) => DateFormat(AppConstants.apiDateFormat).format(date);

  static DateTime? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  /// e.g. "Baru saja", "5 menit yang lalu", "3 jam yang lalu", "2 hari yang lalu".
  static String relative(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 30) return '${diff.inDays} hari yang lalu';

    return format(date);
  }
}
