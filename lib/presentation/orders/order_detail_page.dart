import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/state/app_controller.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/core/utils/formatters.dart';
import 'package:asian_mart_app/domain/entities/order_detail.dart';
import 'package:asian_mart_app/domain/entities/order_history_item.dart';
import 'package:asian_mart_app/domain/enums/order_progress.dart';
import 'package:asian_mart_app/presentation/checkout/payment_page.dart';
import 'package:asian_mart_app/presentation/orders/order_history_page.dart'
    show OrderStatusBadge;
import 'package:asian_mart_app/presentation/widgets/product_image.dart';

/// 주문 상세. 헤더 상태/금액은 목록 아이템([order])을 그대로 쓰고,
/// 상품·배송 정보는 상세 API로 불러온다.
class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({
    super.key,
    required this.controller,
    required this.order,
  });

  final AppController controller;
  final OrderHistoryItem order;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  OrderDetail? _detail;

  /// 입금 대기(PLACED) 주문이면 입금 안내 + "입금 완료" 노출.
  bool get _awaitingDeposit =>
      widget.order.progress == OrderProgress.pendingDeposit;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await widget.controller.loadOrderDetail(widget.order.orderId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _detail = result.detail;
      _error = result.error;
    });
  }

  /// 고객 무통장 입금 통보: PLACED → PAYMENT_PENDING.
  Future<void> _reportPayment(AppLocalizations l10n) async {
    setState(() => _submitting = true);
    final error = await widget.controller.reportPayment(widget.order.orderId);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    // 목록 상태(입금 확인중)를 갱신해두고, 안내 후 목록으로 복귀.
    await widget.controller.loadOrders();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.depositReportedTitle),
        content: Text(l10n.depositReportedDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final showDepositBar =
        !_loading && _error == null && _detail != null && _awaitingDeposit;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(l10n.orderDetailTitle)),
      body: _buildBody(l10n),
      bottomNavigationBar:
          showDepositBar ? _DepositBar(submitting: _submitting, label: l10n.depositComplete, onPressed: () => _reportPayment(l10n)) : null,
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 44, color: AppTheme.textTertiary),
              const SizedBox(height: 16),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.textSecondary)),
              const SizedBox(height: 20),
              OutlinedButton(onPressed: _load, child: Text(l10n.retry)),
            ],
          ),
        ),
      );
    }

    final detail = _detail!;
    final order = widget.order;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // 상태 헤더
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderStatusBadge(
                progress: order.progress,
                label: l10n.orderStatusLabel(order.progress),
              ),
              const SizedBox(height: 14),
              _MetaRow(label: l10n.orderNumberLabel, value: detail.orderNo),
              if (order.orderDate != null)
                _MetaRow(
                    label: l10n.orderDateLabel,
                    value: formatDateTime(order.orderDate!)),
            ],
          ),
        ),
        // 입금 대기 주문: 입금 안내 카드
        if (_awaitingDeposit) ...[
          const SizedBox(height: 12),
          _SectionTitle(l10n.depositGuide),
          const SizedBox(height: 8),
          _DepositGuideCard(l10n: l10n),
        ],
        const SizedBox(height: 12),
        // 주문 상품
        _SectionTitle(l10n.orderItems),
        const SizedBox(height: 8),
        _Card(
          child: Column(
            children: [
              for (var i = 0; i < detail.products.length; i++) ...[
                if (i > 0) const Divider(height: 20, color: AppTheme.divider),
                _ProductRow(product: detail.products[i], l10n: l10n),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 받는 분
        _SectionTitle(l10n.orderRecipient),
        const SizedBox(height: 8),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MetaRow(
                label: l10n.orderRecipient,
                value: '${detail.recipientName}  ·  ${detail.recipientPhone}',
              ),
              _MetaRow(
                  label: l10n.shippingAddress, value: detail.recipientAddress),
              if ((detail.requestMessage ?? '').isNotEmpty)
                _MetaRow(
                    label: l10n.orderRequestMessage,
                    value: detail.requestMessage!),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 결제 금액
        _Card(
          child: Row(
            children: [
              Text(l10n.paymentAmount,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary)),
              const Spacer(),
              Text(formatPrice(detail.paymentAmount.toDouble()),
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                      fontFeatures: [FontFeature.tabularFigures()])),
            ],
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.textSecondary,
              letterSpacing: 0.1)),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product, required this.l10n});

  final OrderDetailProduct product;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final lineTotal = product.price * product.quantity;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 52,
          height: 52,
          child: ProductImage(
            imageUrl: product.thumbnailUrl,
            label: product.productName ?? '',
            borderRadius: AppTheme.radiusMd,
            fontSize: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.productName ?? '-',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      height: 1.3)),
              const SizedBox(height: 4),
              Text(
                '${formatPrice(product.price.toDouble())} · ${l10n.itemQty(product.quantity)}',
                style: const TextStyle(
                    fontSize: 12.5, color: AppTheme.textTertiary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(formatPrice(lineTotal.toDouble()),
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                fontFeatures: [FontFeature.tabularFigures()])),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value, this.trailing});

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textTertiary,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13.5,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.4)),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// 입금 대기 주문의 계좌 안내 (매장 고정 계좌). 계좌번호는 복사 가능.
class _DepositGuideCard extends StatelessWidget {
  const _DepositGuideCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetaRow(label: l10n.bankLabel, value: PaymentPage.bankName),
          _MetaRow(
            label: l10n.accountNumberLabel,
            value: PaymentPage.accountNo,
            trailing: GestureDetector(
              onTap: () {
                Clipboard.setData(
                    const ClipboardData(text: PaymentPage.accountNo));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.copiedAccount)),
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(Icons.copy_rounded,
                    size: 17, color: AppTheme.primary),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: _MetaRow(
                label: l10n.accountHolderLabel,
                value: PaymentPage.accountHolder),
          ),
        ],
      ),
    );
  }
}

/// 하단 "입금 완료" 액션 바.
class _DepositBar extends StatelessWidget {
  const _DepositBar({
    required this.submitting,
    required this.label,
    required this.onPressed,
  });

  final bool submitting;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.divider)),
        ),
        child: FilledButton(
          onPressed: submitting ? null : onPressed,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
          child: submitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : Text(label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}
