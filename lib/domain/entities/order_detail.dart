/// 주문 상세 (GET /api/order/{orderId}).
/// 목록 응답과 달리 deliveryStatus는 포함되지 않으므로, 상태 표시는 호출부에서
/// 목록 아이템(OrderHistoryItem)의 progress를 그대로 넘겨 사용한다.
class OrderDetail {
  const OrderDetail({
    required this.products,
    required this.paymentAmount,
    required this.orderDate,
    required this.requestMessage,
    required this.orderStatus,
    required this.paymentType,
    required this.orderNo,
    required this.recipientName,
    required this.recipientPhone,
    required this.recipientAddress,
  });

  final List<OrderDetailProduct> products;
  final int paymentAmount;
  final DateTime? orderDate;
  final String? requestMessage;
  final String orderStatus;
  final String? paymentType;
  final String orderNo;
  final String recipientName;
  final String recipientPhone;
  final String recipientAddress;

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    final rawDate = json['orderDate'] as String?;
    final products = (json['products'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(OrderDetailProduct.fromJson)
            .toList() ??
        const [];
    return OrderDetail(
      products: products,
      paymentAmount: (json['paymentAmount'] as num?)?.toInt() ?? 0,
      orderDate: rawDate == null ? null : DateTime.tryParse(rawDate),
      requestMessage: json['requestMessage'] as String?,
      orderStatus: json['orderStatus'] as String? ?? '',
      paymentType: json['paymentType'] as String?,
      orderNo: json['orderNo'] as String? ?? '',
      recipientName: json['recipientName'] as String? ?? '',
      recipientPhone: json['recipientPhone'] as String? ?? '',
      recipientAddress: json['recipientAddress'] as String? ?? '',
    );
  }
}

class OrderDetailProduct {
  const OrderDetailProduct({
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.thumbnailUrl,
    required this.price,
    required this.quantity,
  });

  final int productId;
  final String? productName;
  final String? productDescription;
  final String? thumbnailUrl;
  final int price;
  final int quantity;

  factory OrderDetailProduct.fromJson(Map<String, dynamic> json) {
    return OrderDetailProduct(
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      productName: json['productName'] as String?,
      productDescription: json['productDescription'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      price: (json['price'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }
}
