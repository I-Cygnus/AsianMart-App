import 'package:flutter/material.dart';

/// 고객 관점의 주문 진행 상태.
/// 백엔드의 orderStatus(PLACED|PAYMENT_PENDING|CONFIRMED|CANCELLED)와
/// deliveryStatus(ACCEPTED|PREPARING|IN_TRANSIT|DELIVERED|null)를 하나로 합친 표시용 단계.
enum OrderProgress {
  pendingDeposit, // PLACED — 입금 대기
  checkingDeposit, // PAYMENT_PENDING — 입금 확인중
  paid, // CONFIRMED + 배송 접수 전 — 결제 완료
  accepted, // CONFIRMED + ACCEPTED — 배송 접수
  preparing, // CONFIRMED + PREPARING — 배송 준비
  inTransit, // CONFIRMED + IN_TRANSIT — 배송 중
  delivered, // CONFIRMED + DELIVERED — 배송 완료
  cancelled; // CANCELLED — 주문 취소

  /// orderStatus + deliveryStatus 조합을 표시용 단계로 변환.
  static OrderProgress from(String orderStatus, String? deliveryStatus) {
    switch (orderStatus) {
      case 'PLACED':
        return OrderProgress.pendingDeposit;
      case 'PAYMENT_PENDING':
        return OrderProgress.checkingDeposit;
      case 'CANCELLED':
        return OrderProgress.cancelled;
      case 'CONFIRMED':
        switch (deliveryStatus) {
          case 'ACCEPTED':
            return OrderProgress.accepted;
          case 'PREPARING':
            return OrderProgress.preparing;
          case 'IN_TRANSIT':
            return OrderProgress.inTransit;
          case 'DELIVERED':
            return OrderProgress.delivered;
          default:
            return OrderProgress.paid;
        }
      default:
        return OrderProgress.pendingDeposit;
    }
  }

  /// 상태 점/태그에 쓰는 색. 절제된 팔레트.
  Color get color {
    switch (this) {
      case OrderProgress.pendingDeposit:
        return const Color(0xFFAAAAAA); // gray — 대기
      case OrderProgress.checkingDeposit:
        return const Color(0xFFC8861A); // amber — 확인중
      case OrderProgress.paid:
        return const Color(0xFF3B7BE0); // blue — 결제 완료
      case OrderProgress.accepted:
        return const Color(0xFF5856D6); // indigo
      case OrderProgress.preparing:
        return const Color(0xFFFF9500); // orange
      case OrderProgress.inTransit:
        return const Color(0xFF007AFF); // blue
      case OrderProgress.delivered:
        return const Color(0xFF34C759); // green — 완료
      case OrderProgress.cancelled:
        return const Color(0xFF8E8E93); // muted — 취소
    }
  }

  /// 진행이 끝난(취소/배송완료) 상태인지.
  bool get isTerminal =>
      this == OrderProgress.delivered || this == OrderProgress.cancelled;
}
