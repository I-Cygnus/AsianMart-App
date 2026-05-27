import 'package:intl/intl.dart';

final _priceFormatter = NumberFormat('#,###', 'ko_KR');

String formatPrice(double value) => '${_priceFormatter.format(value.round())}원';

String formatDate(DateTime value) => DateFormat('yyyy.MM.dd').format(value);
