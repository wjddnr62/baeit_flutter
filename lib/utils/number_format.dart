import 'package:intl/intl.dart';

var numberFormat = new NumberFormat("#,###");

numberFormatter(int number) {
  return numberFormat.format(number);
}