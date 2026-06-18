import 'package:flutter/material.dart';

/// 배송 기사 관점의 단계.
/// pending(접수 전) = 결제 완료됐지만 아직 배송 접수 안 함.
/// 이후 배송 흐름: accepted → preparing → inTransit → delivered
enum DeliveryStage {
  pending('PENDING', '접수 대기', Icons.inbox_rounded, -1),
  accepted('ACCEPTED', '배송접수', Icons.assignment_turned_in_rounded, 0),
  preparing('PREPARING', '배송준비', Icons.inventory_2_rounded, 1),
  inTransit('IN_TRANSIT', '배송중', Icons.local_shipping_rounded, 2),
  delivered('DELIVERED', '배송완료', Icons.check_circle_rounded, 3);

  const DeliveryStage(this.code, this.label, this.icon, this.flowIndex);

  final String code;
  final String label;
  final IconData icon;

  /// 배송 흐름 내 위치. 접수 전은 -1.
  final int flowIndex;

  /// 응답의 deliveryStatus(null=접수 전)를 단계로 변환.
  static DeliveryStage of(String? code) {
    if (code == null || code.isEmpty) return pending;
    return values.firstWhere((s) => s.code == code, orElse: () => pending);
  }

  /// 스텝퍼에 그릴 실제 배송 단계 (접수 전 제외).
  static const List<DeliveryStage> flow = [
    accepted,
    preparing,
    inTransit,
    delivered,
  ];

  Color get color {
    switch (this) {
      case DeliveryStage.pending:
        return const Color(0xFF8E8E93); // gray
      case DeliveryStage.accepted:
        return const Color(0xFF5856D6); // indigo
      case DeliveryStage.preparing:
        return const Color(0xFFFF9500); // orange
      case DeliveryStage.inTransit:
        return const Color(0xFF007AFF); // blue
      case DeliveryStage.delivered:
        return const Color(0xFF34C759); // green
    }
  }

  /// 다음 단계로 보내는 액션. 완료면 null.
  DeliveryAction? get nextAction {
    switch (this) {
      case DeliveryStage.pending:
        return const DeliveryAction('register', '배송 접수', accepted,
            isRegister: true);
      case DeliveryStage.accepted:
        return const DeliveryAction('prepare', '배송 준비 시작', preparing);
      case DeliveryStage.preparing:
        return const DeliveryAction('ship', '배송 시작', inTransit);
      case DeliveryStage.inTransit:
        return const DeliveryAction('complete', '배송 완료 처리', delivered);
      case DeliveryStage.delivered:
        return null;
    }
  }
}

class DeliveryAction {
  const DeliveryAction(this.endpoint, this.label, this.next,
      {this.isRegister = false});

  /// register | prepare | ship | complete
  final String endpoint;
  final String label;
  final DeliveryStage next;

  /// true면 orderId로 배송 접수(register), false면 deliveryId로 상태 전이.
  final bool isRegister;
}
