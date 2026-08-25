import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/domain/enums/delivery_status.dart';
import 'package:asian_mart_app/domain/enums/order_status.dart';

extension OrderStatusTheme on OrderStatus {
  Color get color => switch (this) {
        OrderStatus.placed => const Color(0xFF3B78C7),
        OrderStatus.paymentPending => const Color(0xFFFF4747),
        OrderStatus.confirmed => const Color(0xFFF0A500),
        OrderStatus.cancelled => AppTheme.textTertiary,
      };
}

extension DeliveryStatusTheme on DeliveryStatus {
  Color get color => switch (this) {
        DeliveryStatus.accepted => const Color(0xFF3B78C7),
        DeliveryStatus.preparing => const Color(0xFFF0A500),
        DeliveryStatus.inTransit => const Color(0xFF3B78C7),
        DeliveryStatus.delivered => const Color(0xFF27AE60),
      };
}
