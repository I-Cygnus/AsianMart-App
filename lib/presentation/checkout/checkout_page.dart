import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/state/app_controller.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/core/utils/formatters.dart';
import 'package:asian_mart_app/presentation/profile/address_editor_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _noteController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppController controller) async {
    setState(() => _submitting = true);
    final error = await controller.placeOrder(
      requestMessage: _noteController.text,
    );
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('주문이 접수되었습니다'),
        content: const Text(
          '백엔드의 주문 생성 API와 연결되었습니다. 현재 백엔드에는 주문 조회 API가 없어 주문 목록 탭은 제거했습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final l10n = AppLocalizations.of(context);
    final address = controller.defaultAddress;
    final items = controller.selectedCartItems;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.checkoutTitle)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Section(
                title: l10n.shippingAddress,
                trailing: TextButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AddressEditorPage(
                          onSubmit: ({
                            required addressName,
                            required zipCode,
                            required address1,
                            required address2,
                            required isDefault,
                          }) {
                            return controller.addAddress(
                              addressName: addressName,
                              zipCode: zipCode,
                              address1: address1,
                              address2: address2,
                              isDefault: isDefault,
                            );
                          },
                        ),
                      ),
                    );
                  },
                  child: Text(l10n.changeAddress),
                ),
                child: address == null
                    ? Text(
                        l10n.noAddressesDesc,
                        style: const TextStyle(color: AppTheme.textSecondary),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address.addressName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            address.fullAddress,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              _Section(
                title: l10n.paymentMethod,
                child: Text(
                  l10n.bankTransfer,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _Section(
                title: l10n.orderNoteLabel,
                child: TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: l10n.orderNoteHint,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _Section(
                title: l10n.productCount(items.length),
                child: Column(
                  children: [
                    for (final item in items) ...[
                      Row(
                        children: [
                          Expanded(child: Text(item.productName)),
                          const SizedBox(width: 12),
                          Text(
                            '${l10n.itemQty(item.quantity)}  ${formatPrice(item.itemTotalPrice)}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Section(
                title: l10n.paymentAmount,
                child: Column(
                  children: [
                    _PriceRow(
                      label: l10n.productAmount,
                      value: formatPrice(controller.selectedCartTotal),
                    ),
                    const SizedBox(height: 8),
                    _PriceRow(
                      label: l10n.shippingFee,
                      value: l10n.free,
                    ),
                    const Divider(height: 24),
                    _PriceRow(
                      label: l10n.finalAmount,
                      value: formatPrice(controller.selectedCartTotal),
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
              child: FilledButton(
                onPressed: _submitting ? null : () => _submit(controller),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(
                  _submitting
                      ? '주문 처리 중...'
                      : '${l10n.payLabel}  ${formatPrice(controller.selectedCartTotal)}',
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
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
