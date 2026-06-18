import 'package:asian_mart_app/domain/enums/order_progress.dart';

/// 고객 주문 내역 리스트 아이템 (GET /api/order).
class OrderHistoryItem {
  const OrderHistoryItem({
    required this.orderId,
    required this.orderNo,
    required this.orderStatus,
    required this.deliveryStatus,
    required this.orderDate,
    required this.paymentAmount,
    required this.thumbnailUrl,
    required this.representativeProductName,
    required this.itemCount,
  });

  final int orderId;
  final String orderNo;
  final String orderStatus; // PLACED | PAYMENT_PENDING | CONFIRMED | CANCELLED
  final String? deliveryStatus; // ACCEPTED | PREPARING | IN_TRANSIT | DELIVERED | null
  final DateTime? orderDate;
  final int paymentAmount;
  final String? thumbnailUrl; // 대표 상품 이미지
  final String? representativeProductName; // 대표 상품명
  final int itemCount; // 주문 상품 종류 수

  OrderProgress get progress => OrderProgress.from(orderStatus, deliveryStatus);

  /// "다진 마늘 500g 외 2건" 형태의 요약 라벨.
  String get summaryLabel {
    final name = representativeProductName;
    if (name == null || name.isEmpty) return '상품 $itemCount건';
    if (itemCount <= 1) return name;
    return '$name 외 ${itemCount - 1}건';
  }

  factory OrderHistoryItem.fromJson(Map<String, dynamic> json) {
    final rawDate = json['orderDate'] as String?;
    return OrderHistoryItem(
      orderId: (json['orderId'] as num?)?.toInt() ?? 0,
      orderNo: json['orderNo'] as String? ?? '',
      orderStatus: json['orderStatus'] as String? ?? '',
      deliveryStatus: json['deliveryStatus'] as String?,
      orderDate: rawDate == null ? null : DateTime.tryParse(rawDate),
      paymentAmount: (json['paymentAmount'] as num?)?.toInt() ?? 0,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      representativeProductName: json['representativeProductName'] as String?,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
    );
  }
}
