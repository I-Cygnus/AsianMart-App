import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/state/app_controller.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/core/utils/formatters.dart';
import 'package:asian_mart_app/domain/entities/admin_order.dart';
import 'package:asian_mart_app/domain/entities/order_detail.dart';
import 'package:asian_mart_app/presentation/widgets/product_image.dart';

const _ink = AppTheme.textPrimary;
const _sub = AppTheme.textSecondary;
const _faint = AppTheme.textTertiary;
const _line = AppTheme.border;

/// 루트 관리자 주문 상세 — 배송지·상품을 확인하고 "주문 수락"으로 확정한다.
class AdminOrderDetailPage extends StatefulWidget {
  const AdminOrderDetailPage({
    super.key,
    required this.controller,
    required this.order,
  });

  final AppController controller;
  final AdminOrder order;

  @override
  State<AdminOrderDetailPage> createState() => _AdminOrderDetailPageState();
}

class _AdminOrderDetailPageState extends State<AdminOrderDetailPage> {
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  OrderDetail? _detail;

  AppController get controller => widget.controller;

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
    final result = await controller.loadAdminOrderDetail(widget.order.orderId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _detail = result.detail;
      _error = result.error;
    });
  }

  Future<void> _accept() async {
    setState(() => _submitting = true);
    final error = await controller.confirmDeposit(widget.order.orderId);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('주문 수락 완료'),
        content: Text('주문 #${widget.order.orderId} 을(를) 확정했습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: const Text('주문 상세',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: _ink)),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
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
              const Icon(Icons.error_outline_rounded, size: 44, color: _faint),
              const SizedBox(height: 16),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: _sub)),
              const SizedBox(height: 20),
              OutlinedButton(onPressed: _load, child: const Text('다시 시도')),
            ],
          ),
        ),
      );
    }

    final order = widget.order;
    final detail = _detail;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 헤더 — 주문번호 / 일시
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('주문 #${order.orderId}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _ink)),
                  const Spacer(),
                  if (order.orderDate != null)
                    Text(formatDate(order.orderDate!),
                        style: const TextStyle(fontSize: 12.5, color: _faint)),
                ],
              ),
              const SizedBox(height: 6),
              Text(order.orderNo,
                  style: const TextStyle(fontSize: 12.5, color: _faint)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 배송지
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('배송지'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(detail?.recipientName ?? order.recipientName,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _ink)),
                  const SizedBox(width: 8),
                  Text(detail?.recipientPhone ?? order.recipientPhone,
                      style: const TextStyle(fontSize: 13, color: _faint)),
                ],
              ),
              const SizedBox(height: 6),
              Text(detail?.recipientAddress ?? order.recipientAddress,
                  style: const TextStyle(
                      fontSize: 14, color: _sub, height: 1.45)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 상품 리스트
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('상품 ${detail?.products.length ?? 0}건'),
              const SizedBox(height: 6),
              if (detail != null)
                for (var i = 0; i < detail.products.length; i++) ...[
                  if (i > 0) const Divider(height: 24, color: _line),
                  _ProductRow(product: detail.products[i]),
                ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 결제 금액
        _Card(
          child: Row(
            children: [
              const Text('결제 금액',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: _ink)),
              const Spacer(),
              Text(formatPrice(order.paymentAmount.toDouble()),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: _ink)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final canAccept = widget.order.canConfirm; // PAYMENT_PENDING
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: _line)),
        ),
        child: canAccept
            ? FilledButton(
                onPressed: _submitting ? null : _accept,
                style: FilledButton.styleFrom(
                  backgroundColor: _ink,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('주문 수락',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: _line),
                ),
                child: const Text('고객 입금 대기 중',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: _faint)),
              ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: _line),
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
    return Text(text,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w800, color: _sub));
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product});
  final OrderDetailProduct product;

  @override
  Widget build(BuildContext context) {
    final lineTotal = product.price * product.quantity;
    return Row(
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
                      color: _ink,
                      height: 1.3)),
              const SizedBox(height: 4),
              Text('${formatPrice(product.price.toDouble())} · ${product.quantity}개',
                  style: const TextStyle(fontSize: 12.5, color: _faint)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(formatPrice(lineTotal.toDouble()),
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800, color: _ink)),
      ],
    );
  }
}
