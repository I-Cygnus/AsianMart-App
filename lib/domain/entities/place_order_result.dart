import 'package:asian_mart_app/domain/entities/order_detail.dart';

class PlaceOrderResult {
  const PlaceOrderResult({
    this.error,
    this.orderId,
    this.order,
  });

  final String? error;
  final int? orderId;
  final OrderDetail? order;

  bool get isSuccess => error == null && order != null;
}
