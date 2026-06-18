import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/state/app_controller.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/core/utils/formatters.dart';
import 'package:asian_mart_app/domain/entities/order_history_item.dart';
import 'package:asian_mart_app/domain/enums/order_progress.dart';
import 'package:asian_mart_app/presentation/orders/order_detail_page.dart';
import 'package:asian_mart_app/presentation/widgets/empty_state.dart';
import 'package:asian_mart_app/presentation/widgets/product_image.dart';

/// 내 정보 → 주문 내역. 내가 주문한 목록을 상태와 함께 보여준다.
class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  AppController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadOrders();
    });
  }

  void _openDetail(OrderHistoryItem order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderDetailPage(controller: controller, order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(l10n.orderHistory)),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => _buildBody(l10n),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    final orders = controller.orders;
    if (controller.ordersLoading && orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.ordersError != null && orders.isEmpty) {
      return _ErrorPanel(
        message: controller.ordersError!,
        retryLabel: l10n.retry,
        onRetry: controller.loadOrders,
      );
    }
    return RefreshIndicator(
      onRefresh: controller.loadOrders,
      child: orders.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 100),
                EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: l10n.orderHistoryEmpty,
                  description: l10n.orderHistoryEmptyDesc,
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _OrderCard(
                order: orders[i],
                onTap: () => _openDetail(orders[i]),
              ),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final OrderHistoryItem order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  OrderStatusBadge(progress: order.progress, label: l10n.orderStatusLabel(order.progress)),
                  const Spacer(),
                  if (order.orderDate != null)
                    Text(formatDate(order.orderDate!),
                        style: const TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.textTertiary,
                            fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 14),
              // 대표 상품 썸네일 + 요약
              Row(
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: ProductImage(
                      imageUrl: order.thumbnailUrl,
                      label: order.representativeProductName ?? '',
                      borderRadius: AppTheme.radiusMd,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.summaryLabel,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                                height: 1.35)),
                        const SizedBox(height: 4),
                        Text('${l10n.orderNumberLabel}  ${order.orderNo}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textTertiary,
                                fontWeight: FontWeight.w500,
                                fontFeatures: [FontFeature.tabularFigures()])),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppTheme.border),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(formatPrice(order.paymentAmount.toDouble()),
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          fontFeatures: [FontFeature.tabularFigures()])),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded,
                      size: 20, color: AppTheme.textTertiary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 주문 상태 배지 — 단계 색의 옅은 틴트 + 점.
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({
    super.key,
    required this.progress,
    required this.label,
  });

  final OrderProgress progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = progress.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color)),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 44, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}
