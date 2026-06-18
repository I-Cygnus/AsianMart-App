import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/state/app_controller.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/core/utils/formatters.dart';
import 'package:asian_mart_app/domain/entities/admin_order.dart';
import 'package:asian_mart_app/domain/enums/order_progress.dart';
import 'package:asian_mart_app/presentation/admin/admin_order_detail_page.dart';
import 'package:asian_mart_app/presentation/widgets/empty_state.dart';

/// 루트 관리자 주문 요청 화면.
/// 입금 대기(PLACED) + 입금 확인 대기(PAYMENT_PENDING) 주문을 함께 보여주고,
/// 입금 확인 대기 건은 "입금 확인"으로 주문을 확정(CONFIRMED)한다.
String _progressLabelKo(OrderProgress p) => switch (p) {
      OrderProgress.pendingDeposit => '입금 대기',
      OrderProgress.checkingDeposit => '주문',
      _ => '주문 요청',
    };
class AdminPaymentPage extends StatefulWidget {
  const AdminPaymentPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<AdminPaymentPage> createState() => _AdminPaymentPageState();
}

class _AdminPaymentPageState extends State<AdminPaymentPage> {
  static const Color _ink = Color(0xFF111111);

  AppController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    // 진입 시 최신 목록으로 갱신.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAdminOrders();
    });
  }

  /// 주문 확인 → 상세 화면(배송지·상품 리스트)으로 이동. 거기서 "주문 수락"으로 확정.
  Future<void> _openDetail(AdminOrder order) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            AdminOrderDetailPage(controller: controller, order: order),
      ),
    );
    if (mounted) controller.loadAdminOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleSpacing: 4,
        title: const Text('주문 요청',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _ink,
                letterSpacing: -0.4)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                size: 21, color: AppTheme.textSecondary),
            onPressed: controller.loadAdminOrders,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final orders = controller.adminOrders;
    if (controller.adminOrdersLoading && orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.adminOrdersError != null && orders.isEmpty) {
      return _ErrorPanel(
        message: controller.adminOrdersError!,
        onRetry: controller.loadAdminOrders,
      );
    }
    return RefreshIndicator(
      onRefresh: controller.loadAdminOrders,
      child: orders.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: '주문 요청이 없어요',
                  description: '새 주문이 들어오면 여기에 표시됩니다',
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              itemCount: orders.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                if (i == 0) {
                  final pending = orders.where((o) => o.canConfirm).length;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 6),
                    child: Row(
                      children: [
                        Text('총 ${orders.length}건',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary)),
                        if (pending > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.10),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: Text('확인 대기 $pending',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primary)),
                          ),
                        ],
                      ],
                    ),
                  );
                }
                final order = orders[i - 1];
                return _OrderCard(
                  order: order,
                  onConfirm: () => _openDetail(order),
                );
              },
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onConfirm});

  static const Color _ink = Color(0xFF111111);

  final AdminOrder order;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final actionable = order.canConfirm; // PAYMENT_PENDING
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onConfirm,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: actionable
                  ? AppTheme.primary.withValues(alpha: 0.4)
                  : AppTheme.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusTag(progress: order.progress),
                  const Spacer(),
                  if (order.orderDate != null)
                    Text(formatDate(order.orderDate!),
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textTertiary)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.recipientName,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _ink)),
                        const SizedBox(height: 3),
                        Text('주문 No. ${order.orderId}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textTertiary,
                                fontFeatures: [FontFeature.tabularFigures()])),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(formatPrice(order.paymentAmount.toDouble()),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: _ink,
                          letterSpacing: -0.4,
                          fontFeatures: [FontFeature.tabularFigures()])),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppTheme.divider),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Spacer(),
                  if (actionable) ...[
                    const Text('주문 확인',
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary)),
                    const SizedBox(width: 3),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 15, color: AppTheme.primary),
                  ] else
                    const Text('고객 입금 대기 중',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textTertiary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 절제된 상태 태그 — 단계 색 점 + 라벨, 채움 없는 헤어라인.
class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.progress});

  final OrderProgress progress;

  @override
  Widget build(BuildContext context) {
    final color = progress.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 6,
            height: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 6),
          Text(_progressLabelKo(progress),
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
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
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
