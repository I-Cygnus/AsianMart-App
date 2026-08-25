import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/core/utils/formatters.dart';
import 'package:asian_mart_app/domain/entities/order_list_item.dart';
import 'package:asian_mart_app/presentation/orders/order_status_chip.dart';
import 'package:asian_mart_app/presentation/widgets/tab_header.dart';

class GuestOrderInquiryPage extends StatefulWidget {
  const GuestOrderInquiryPage({
    super.key,
    required this.onLookup,
    required this.onOpenOrder,
    required this.onBack,
  });

  final Future<({List<OrderListItem> items, String? error})> Function({
    required String orderNo,
    required String recipientPhone,
  }) onLookup;
  final ValueChanged<OrderListItem> onOpenOrder;
  final VoidCallback onBack;

  @override
  State<GuestOrderInquiryPage> createState() => _GuestOrderInquiryPageState();
}

class _GuestOrderInquiryPageState extends State<GuestOrderInquiryPage> {
  final _orderNoController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _searching = false;
  String? _error;
  List<OrderListItem> _items = const [];
  bool _searched = false;

  @override
  void dispose() {
    _orderNoController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _searching = true;
      _error = null;
    });
    final result = await widget.onLookup(
      orderNo: _orderNoController.text,
      recipientPhone: _phoneController.text,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _searching = false;
      _searched = true;
      _error = result.error;
      _items = result.items;
    });
    if (result.error == null && result.items.length == 1) {
      widget.onOpenOrder(result.items.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          TabHeader(
            leading: Row(
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  iconSize: 20,
                  color: AppTheme.textPrimary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.guestOrderInquiry,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                TabLayoutSpacing.horizontal,
                TabLayoutSpacing.contentTop,
                TabLayoutSpacing.horizontal,
                TabLayoutSpacing.contentBottom,
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.guestOrderInquiryDesc,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _orderNoController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.orderNumber,
                          prefixIcon: const Icon(Icons.confirmation_number_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _searching ? null : _submit(),
                        decoration: InputDecoration(
                          labelText: l10n.phoneLabel,
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _searching ? null : _submit,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        child: Text(
                          _searching ? l10n.lookingUpOrder : l10n.lookupOrder,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: AppTheme.error,
                      height: 1.45,
                    ),
                  ),
                ],
                if (_searched && _error == null && _items.isEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.guestOrderNotFound,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
                if (_items.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  for (final item in _items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ResultCard(
                        item: item,
                        onTap: () => widget.onOpenOrder(item),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.item,
    required this.onTap,
  });

  final OrderListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDate(item.orderDate),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.orderNumber} ${item.orderNo}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatPrice(item.paymentAmount),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              OrderStatusChip(
                orderStatus: item.orderStatus,
                deliveryStatus: item.deliveryStatus,
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
