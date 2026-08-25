import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/core/theme/order_status_theme.dart';
import 'package:asian_mart_app/domain/enums/delivery_status.dart';
import 'package:asian_mart_app/domain/enums/order_status.dart';

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({
    super.key,
    required this.orderStatus,
    this.deliveryStatus,
  });

  final OrderStatus orderStatus;
  final DeliveryStatus? deliveryStatus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = _label(l10n);
    final color = _color();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  String _label(AppLocalizations l10n) {
    if (orderStatus == OrderStatus.cancelled) {
      return l10n.orderStatusLabel(orderStatus);
    }
    if (orderStatus == OrderStatus.paymentPending) {
      return l10n.orderStatusLabel(orderStatus);
    }
    if (deliveryStatus != null && orderStatus == OrderStatus.confirmed) {
      return l10n.deliveryStatusLabel(deliveryStatus!);
    }
    return l10n.orderStatusLabel(orderStatus);
  }

  Color _color() {
    if (orderStatus == OrderStatus.cancelled ||
        orderStatus == OrderStatus.paymentPending ||
        deliveryStatus == null ||
        orderStatus != OrderStatus.confirmed) {
      return orderStatus.color;
    }
    return deliveryStatus!.color;
  }
}
