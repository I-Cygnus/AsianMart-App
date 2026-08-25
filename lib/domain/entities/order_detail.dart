import 'package:asian_mart_app/domain/enums/delivery_status.dart';
import 'package:asian_mart_app/domain/enums/order_status.dart';

class OrderProduct {
  const OrderProduct({
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.price,
    required this.quantity,
    this.thumbnailUrl,
  });

  final int productId;
  final String productName;
  final String productDescription;
  final double price;
  final int quantity;
  final String? thumbnailUrl;

  double get lineTotal => price * quantity;

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      productName: json['productName'] as String? ?? '',
      productDescription: json['productDescription'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productDescription': productDescription,
      'price': price,
      'quantity': quantity,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}

class OrderDetail {
  const OrderDetail({
    required this.orderId,
    required this.orderNo,
    required this.orderStatus,
    required this.orderDate,
    required this.paymentAmount,
    required this.paymentType,
    required this.requestMessage,
    required this.recipientName,
    required this.recipientPhone,
    required this.recipientAddress,
    required this.products,
    this.deliveryStatus,
  });

  final int orderId;
  final String orderNo;
  final OrderStatus orderStatus;
  final DateTime orderDate;
  final double paymentAmount;
  final String paymentType;
  final String requestMessage;
  final String recipientName;
  final String recipientPhone;
  final String recipientAddress;
  final List<OrderProduct> products;
  final DeliveryStatus? deliveryStatus;

  factory OrderDetail.fromJson(
    Map<String, dynamic> json, {
    required int orderId,
  }) {
    final products = (json['products'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(OrderProduct.fromJson)
        .toList();

    return OrderDetail(
      orderId: (json['orderId'] as num?)?.toInt() ?? orderId,
      orderNo: json['orderNo'] as String? ?? '',
      orderStatus: OrderStatus.fromApi(json['orderStatus'] as String?),
      orderDate: DateTime.tryParse(json['orderDate'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      paymentAmount: (json['paymentAmount'] as num?)?.toDouble() ?? 0,
      paymentType: json['paymentType'] as String? ?? 'BANK_TRANSFER',
      requestMessage: json['requestMessage'] as String? ?? '',
      recipientName: json['recipientName'] as String? ?? '',
      recipientPhone: json['recipientPhone'] as String? ?? '',
      recipientAddress: json['recipientAddress'] as String? ?? '',
      products: products,
      deliveryStatus: DeliveryStatus.fromApi(json['deliveryStatus'] as String?),
    );
  }

  OrderDetail copyWith({
    int? orderId,
    String? orderNo,
    OrderStatus? orderStatus,
    DateTime? orderDate,
    double? paymentAmount,
    String? paymentType,
    String? requestMessage,
    String? recipientName,
    String? recipientPhone,
    String? recipientAddress,
    List<OrderProduct>? products,
    DeliveryStatus? deliveryStatus,
  }) {
    return OrderDetail(
      orderId: orderId ?? this.orderId,
      orderNo: orderNo ?? this.orderNo,
      orderStatus: orderStatus ?? this.orderStatus,
      orderDate: orderDate ?? this.orderDate,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentType: paymentType ?? this.paymentType,
      requestMessage: requestMessage ?? this.requestMessage,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      recipientAddress: recipientAddress ?? this.recipientAddress,
      products: products ?? this.products,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'orderNo': orderNo,
      'orderStatus': orderStatus.apiValue,
      'orderDate': orderDate.toIso8601String(),
      'paymentAmount': paymentAmount,
      'paymentType': paymentType,
      'requestMessage': requestMessage,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'recipientAddress': recipientAddress,
      'products': products.map((item) => item.toJson()).toList(),
      'deliveryStatus': deliveryStatus?.apiValue,
    };
  }
}
