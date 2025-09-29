import 'package:intl/intl.dart';

class DateUtilsCustom {
  static String format(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}
