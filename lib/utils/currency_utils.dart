import 'package:intl/intl.dart';

String formatCurrency(double value) {
  final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
  return format.format(value);
}
