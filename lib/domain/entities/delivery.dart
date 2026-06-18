/// 배송 기사 리스트 아이템 = 결제 완료(CONFIRMED) 주문 + (있으면) 배송 진행 상태.
///
/// [deliveryId] / [deliveryStatus] 가 null 이면 아직 "배송 접수 전" 상태다.
class Delivery {
  const Delivery({
    required this.orderId,
    required this.orderNo,
    required this.recipientName,
    required this.recipientPhone,
    required this.address,
    required this.totalAmount,
    required this.deliveryId,
    required this.deliveryStatus,
  });

  final int orderId;
  final String orderNo;
  final String recipientName;
  final String recipientPhone;
  final String address;
  final int totalAmount;
  final int? deliveryId; // null = 접수 전
  final String? deliveryStatus; // null = 접수 전

  bool get isAccepted => deliveryId != null;

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      orderId: (json['orderId'] as num?)?.toInt() ?? 0,
      orderNo: json['orderNo'] as String? ?? '',
      recipientName: json['recipientName'] as String? ?? '',
      recipientPhone: json['recipientPhone'] as String? ?? '',
      address: json['recipientAddress'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toInt() ?? 0,
      deliveryId: (json['deliveryId'] as num?)?.toInt(),
      deliveryStatus: json['deliveryStatus'] as String?,
    );
  }
}
