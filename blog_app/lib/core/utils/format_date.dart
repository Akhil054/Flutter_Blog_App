import 'package:intl/intl.dart';

String formatDateBydMMMYYY(DateTime dateTime) {
  return DateFormat('dd-MMM-yyyy').format(dateTime);
}