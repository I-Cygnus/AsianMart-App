import 'package:intl/intl.dart';

final _priceFormatter = NumberFormat.currency(
  locale: 'en_US',
  symbol: '\$',
  decimalDigits: 2,
);

String formatPrice(double value) => _priceFormatter.format(value);

String formatDate(DateTime value) => DateFormat('yyyy.MM.dd').format(value);
