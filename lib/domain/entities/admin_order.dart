import 'package:asian_mart_app/domain/enums/order_progress.dart';

/// 관리자 주문 요청 리스트 아이템 = 입금 대기(PLACED) 또는 입금 확인 대기(PAYMENT_PENDING) 주문.
///
/// 입금 확인 대기 건은 관리자가 "입금 확인"을 누르면 주문이 확정(CONFIRMED)된다.
class AdminOrder {
  const AdminOrder({
    required this.orderId,
    required this.orderNo,
    required this.orderStatus,
    required this.recipientName,
    required this.recipientPhone,
    required this.recipientAddress,
    required this.paymentAmount,
    required this.paymentType,
    required this.orderDate,
    required this.guestEmail,
  });

  final int orderId;
  final String orderNo;
  final String orderStatus; // PLACED | PAYMENT_PENDING
  final String recipientName;
  final String recipientPhone;
  final String recipientAddress;
  final int paymentAmount;
  final String? paymentType;
  final DateTime? orderDate;
  final String? guestEmail;

  OrderProgress get progress => OrderProgress.from(orderStatus, null);

  /// 입금 확인(확정) 가능한 상태인지 = 고객이 입금 통보한 PAYMENT_PENDING.
  bool get canConfirm => orderStatus == 'PAYMENT_PENDING';

  factory AdminOrder.fromJson(Map<String, dynamic> json) {
    final rawDate = json['orderDate'] as String?;
    return AdminOrder(
      orderId: (json['orderId'] as num?)?.toInt() ?? 0,
      orderNo: json['orderNo'] as String? ?? '',
      orderStatus: json['orderStatus'] as String? ?? '',
      recipientName: json['recipientName'] as String? ?? '',
      recipientPhone: json['recipientPhone'] as String? ?? '',
      recipientAddress: json['recipientAddress'] as String? ?? '',
      paymentAmount: (json['paymentAmount'] as num?)?.toInt() ?? 0,
      paymentType: json['paymentType'] as String?,
      orderDate: rawDate == null ? null : DateTime.tryParse(rawDate),
      guestEmail: json['guestEmail'] as String?,
    );
  }
}
