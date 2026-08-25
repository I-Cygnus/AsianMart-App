import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/core/utils/formatters.dart';
import 'package:asian_mart_app/domain/entities/order_detail.dart';
import 'package:asian_mart_app/domain/enums/order_status.dart';
import 'package:asian_mart_app/presentation/orders/bank_account_card.dart';
import 'package:asian_mart_app/presentation/orders/order_status_chip.dart';
import 'package:asian_mart_app/presentation/widgets/product_image.dart';
import 'package:asian_mart_app/presentation/widgets/tab_header.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.order,
    required this.onRefresh,
    this.onOpenProduct,
  });

  final bool isLoading;
  final String? errorMessage;
  final OrderDetail? order;
  final Future<void> Function() onRefresh;
  final ValueChanged<int>? onOpenProduct;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimary,
        scrolledUnderElevation: 0.5,
        title: Text(
          l10n.orderDetailTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.divider),
        ),
      ),
      body: _buildBody(context, l10n),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    if (isLoading && order == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null && order == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppTheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }
    if (order == null) {
      return const SizedBox.shrink();
    }

    final detail = order!;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          TabLayoutSpacing.horizontal,
          TabLayoutSpacing.contentTop,
          TabLayoutSpacing.horizontal,
          TabLayoutSpacing.contentBottom,
        ),
        children: [
          _Section(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrderStatusChip(
                  orderStatus: detail.orderStatus,
                  deliveryStatus: detail.deliveryStatus,
                ),
                const SizedBox(height: 14),
                _InfoRow(
                  label: l10n.orderNumber,
                  value: detail.orderNo,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: l10n.orderDateLabel,
                  value: formatDateTime(detail.orderDate),
                ),
              ],
            ),
          ),
          if (detail.orderStatus == OrderStatus.placed ||
              detail.orderStatus == OrderStatus.paymentPending) ...[
            const SizedBox(height: 12),
            BankAccountCard(paymentAmount: detail.paymentAmount),
          ],
          const SizedBox(height: 12),
          _Section(
            title: l10n.orderItems,
            child: Column(
              children: [
                for (var i = 0; i < detail.products.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _OrderProductRow(
                    product: detail.products[i],
                    onTap: onOpenProduct == null
                        ? null
                        : () => onOpenProduct!(detail.products[i].productId),
                  ),
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
                  detail.recipientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (detail.recipientPhone.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    detail.recipientPhone,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
                if (detail.recipientAddress.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    detail.recipientAddress,
                    style: const TextStyle(
                      fontSize: 14,
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
              detail.requestMessage.trim().isEmpty
                  ? l10n.noOrderNote
                  : detail.requestMessage,
              style: TextStyle(
                fontSize: 14,
                color: detail.requestMessage.trim().isEmpty
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
                _PriceRow(
                  label: l10n.paymentMethod,
                  value: l10n.bankTransfer,
                ),
                const SizedBox(height: 8),
                _PriceRow(
                  label: l10n.productAmount,
                  value: formatPrice(detail.paymentAmount),
                ),
                const SizedBox(height: 8),
                _PriceRow(
                  label: l10n.shippingFee,
                  value: l10n.free,
                ),
                const Divider(height: 24),
                _PriceRow(
                  label: l10n.finalAmount,
                  value: formatPrice(detail.paymentAmount),
                  bold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.child,
    this.title,
  });

  final Widget child;
  final String? title;

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
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textTertiary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderProductRow extends StatelessWidget {
  const _OrderProductRow({
    required this.product,
    this.onTap,
  });

  final OrderProduct product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final row = Row(
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: ProductImage(
            imageUrl: product.thumbnailUrl,
            label: product.productName,
            borderRadius: AppTheme.radiusMd,
            fontSize: 24,
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
                  color: AppTheme.textPrimary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.itemQty(product.quantity),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formatPrice(product.lineTotal),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (onTap == null) {
      return row;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: row,
      ),
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
