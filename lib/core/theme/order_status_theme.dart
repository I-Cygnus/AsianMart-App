import 'package:flutter/material.dart';
import 'package:asian_mart_app/domain/enums/order_status.dart';

extension OrderStatusTheme on OrderStatus {
  Color get color => switch (this) {
        OrderStatus.pendingPayment => const Color(0xFFFF4747),
        OrderStatus.preparing => const Color(0xFFF0A500),
        OrderStatus.shipping => const Color(0xFF3B78C7),
        OrderStatus.delivered => const Color(0xFF27AE60),
      };
}
