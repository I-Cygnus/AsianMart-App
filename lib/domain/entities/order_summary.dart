import 'package:asian_mart_app/domain/enums/order_status.dart';

class OrderSummary {
  OrderSummary({
    required this.orderNumber,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
    required this.totalPrice,
  });

  final String orderNumber;
  final String title;
  final String description;
  final DateTime date;
  final OrderStatus status;
  final double totalPrice;

  OrderSummary copyWith({
    String? orderNumber,
    String? title,
    String? description,
    DateTime? date,
    OrderStatus? status,
    double? totalPrice,
  }) {
    return OrderSummary(
      orderNumber: orderNumber ?? this.orderNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
