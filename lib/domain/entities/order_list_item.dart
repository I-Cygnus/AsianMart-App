import 'package:asian_mart_app/domain/enums/delivery_status.dart';
import 'package:asian_mart_app/domain/enums/order_status.dart';

class OrderListItem {
  const OrderListItem({
    required this.orderId,
    required this.orderNo,
    required this.orderStatus,
    required this.orderDate,
    required this.paymentAmount,
    this.deliveryStatus,
  });

  final int orderId;
  final String orderNo;
  final OrderStatus orderStatus;
  final DateTime orderDate;
  final double paymentAmount;
  final DeliveryStatus? deliveryStatus;

  factory OrderListItem.fromJson(Map<String, dynamic> json) {
    return OrderListItem(
      orderId: (json['orderId'] as num?)?.toInt() ?? 0,
      orderNo: json['orderNo'] as String? ?? '',
      orderStatus: OrderStatus.fromApi(json['orderStatus'] as String?),
      orderDate: DateTime.tryParse(json['orderDate'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      paymentAmount: (json['paymentAmount'] as num?)?.toDouble() ?? 0,
      deliveryStatus: DeliveryStatus.fromApi(json['deliveryStatus'] as String?),
    );
  }
}
