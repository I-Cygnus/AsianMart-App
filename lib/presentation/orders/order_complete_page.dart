import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/core/utils/formatters.dart';
import 'package:asian_mart_app/domain/entities/order_detail.dart';
import 'package:asian_mart_app/presentation/orders/bank_account_card.dart';
import 'package:asian_mart_app/presentation/orders/order_status_chip.dart';
import 'package:asian_mart_app/presentation/widgets/product_image.dart';
import 'package:asian_mart_app/presentation/widgets/tab_header.dart';

class OrderCompletePage extends StatelessWidget {
  const OrderCompletePage({
    super.key,
    required this.order,
    required this.onContinueShopping,
    this.onViewOrders,
  });

  final OrderDetail order;
  final VoidCallback onContinueShopping;
  final VoidCallback? onViewOrders;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final orderNo = order.orderNo.isNotEmpty
        ? order.orderNo
        : (order.orderId > 0 ? '${order.orderId}' : '-');

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.orderCompleteTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          TabLayoutSpacing.horizontal,
          TabLayoutSpacing.contentTop,
          TabLayoutSpacing.horizontal,
          TabLayoutSpacing.contentBottom,
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppTheme.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.orderPlacedTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.orderPlacedDesc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                OrderStatusChip(
                  orderStatus: order.orderStatus,
                  deliveryStatus: order.deliveryStatus,
                ),
                const SizedBox(height: 12),
                Text(
                  '${l10n.orderNumber} $orderNo',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatDateTime(order.orderDate),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          BankAccountCard(paymentAmount: order.paymentAmount),
          const SizedBox(height: 12),
          _Section(
            title: l10n.orderItems,
            child: Column(
              children: [
                for (var i = 0; i < order.products.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _ProductRow(product: order.products[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Section(
            title: l10n.recipientInfo,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.recipientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (order.recipientPhone.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    order.recipientPhone,
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
                if (order.recipientAddress.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    order.recipientAddress,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Section(
            title: l10n.orderNoteLabel,
            child: Text(
              order.requestMessage.trim().isEmpty
                  ? l10n.noOrderNote
                  : order.requestMessage,
              style: TextStyle(
                color: order.requestMessage.trim().isEmpty
                    ? AppTheme.textTertiary
                    : AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Section(
            title: l10n.paymentAmount,
            child: Column(
              children: [
                _PriceRow(label: l10n.paymentMethod, value: l10n.bankTransfer),
                const SizedBox(height: 8),
                _PriceRow(
                  label: l10n.finalAmount,
                  value: formatPrice(order.paymentAmount),
                  bold: true,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(top: BorderSide(color: AppTheme.divider)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onViewOrders != null) ...[
                OutlinedButton(
                  onPressed: onViewOrders,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(l10n.orderInquiry),
                ),
                const SizedBox(height: 8),
              ],
              FilledButton(
                onPressed: onContinueShopping,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(l10n.continueShopping),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product});

  final OrderProduct product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: ProductImage(
            imageUrl: product.thumbnailUrl,
            label: product.productName,
            borderRadius: AppTheme.radiusMd,
            fontSize: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${l10n.itemQty(product.quantity)}  ${formatPrice(product.lineTotal)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: bold ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: bold ? 18 : 14,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
