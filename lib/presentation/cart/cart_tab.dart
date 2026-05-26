import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/core/utils/formatters.dart';
import 'package:asian_mart_app/domain/entities/cart_entry.dart';
import 'package:asian_mart_app/presentation/widgets/empty_state.dart';
import 'package:asian_mart_app/presentation/widgets/quantity_stepper.dart';

class CartTab extends StatelessWidget {
  const CartTab({
    super.key,
    required this.items,
    required this.isLoading,
    required this.errorMessage,
    required this.total,
    required this.onRefresh,
    required this.onDelete,
    required this.onQuantityChanged,
    required this.onSelectedChanged,
    required this.onCheckout,
    this.onSelectAll,
  });

  final List<CartEntry> items;
  final bool isLoading;
  final String? errorMessage;
  final double total;
  final Future<void> Function() onRefresh;
  final ValueChanged<int> onDelete;
  final void Function(int cartItemId, int quantity) onQuantityChanged;
  final void Function(int cartItemId, bool selected) onSelectedChanged;
  final Future<void> Function() onCheckout;
  final void Function(bool selectAll)? onSelectAll;

  bool get _allSelected =>
      items.isNotEmpty && items.every((item) => item.selected);
  int get _selectedCount => items.where((item) => item.selected).length;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget body;
    if (isLoading && items.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null && items.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, height: 1.5),
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
    } else if (items.isEmpty) {
      body = EmptyState(
        icon: Icons.shopping_bag_outlined,
        title: l10n.cartEmpty,
        description: l10n.cartEmptyDesc,
      );
    } else {
      body = Column(
        children: [
          _SelectAllBar(
            allSelected: _allSelected,
            selectedCount: _selectedCount,
            totalCount: items.length,
            onToggle: onSelectAll != null
                ? () => onSelectAll!(!_allSelected)
                : null,
          ),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Dismissible(
                    key: ValueKey(item.cartItemId),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
                          SizedBox(height: 2),
                          Text(
                            '삭제',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onDismissed: (_) => onDelete(item.cartItemId),
                    child: _CartItemCard(
                      item: item,
                      onDelete: () => onDelete(item.cartItemId),
                      onQuantityChanged: (quantity) =>
                          onQuantityChanged(item.cartItemId, quantity),
                      onSelectedChanged: (selected) =>
                          onSelectedChanged(item.cartItemId, selected),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Container(
          color: AppTheme.surface,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Row(
            children: [
              Text(
                l10n.cartTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              if (items.isNotEmpty)
                Text(
                  l10n.productCount(items.length),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(child: body),
        if (items.isNotEmpty) _CheckoutBar(total: total, onCheckout: onCheckout),
      ],
    );
  }
}

class _SelectAllBar extends StatelessWidget {
  const _SelectAllBar({
    required this.allSelected,
    required this.selectedCount,
    required this.totalCount,
    required this.onToggle,
  });

  final bool allSelected;
  final int selectedCount;
  final int totalCount;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: allSelected,
                    onChanged: onToggle != null ? (_) => onToggle!() : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    side: const BorderSide(color: AppTheme.border, width: 1.5),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '전체선택 ($selectedCount/$totalCount)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.onDelete,
    required this.onQuantityChanged,
    required this.onSelectedChanged,
  });

  final CartEntry item;
  final VoidCallback onDelete;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<bool> onSelectedChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: item.selected
            ? Border.all(color: AppTheme.primary.withValues(alpha: 0.3))
            : Border.all(color: Colors.transparent),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: item.selected,
              onChanged: (value) => onSelectedChanged(value ?? false),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              side: const BorderSide(color: AppTheme.border, width: 1.5),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 10),
          _ImageThumb(imageUrl: item.imageUrl, label: item.productName),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (item.inventoryStatusLabel.isNotEmpty)
                  Text(
                    item.inventoryStatusLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    QuantityStepper(
                      quantity: item.quantity,
                      onChanged: onQuantityChanged,
                    ),
                    const Spacer(),
                    Text(
                      formatPrice(item.itemTotalPrice),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.total, required this.onCheckout});

  final double total;
  final Future<void> Function() onCheckout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.orderAmount,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatPrice(total),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: onCheckout,
              style: FilledButton.styleFrom(
                minimumSize: const Size(140, 52),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: Text(l10n.placeOrder),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.imageUrl, required this.label});

  final String? imageUrl;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 68,
        height: 68,
        color: AppTheme.imagePlaceholder,
        alignment: Alignment.center,
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _FallbackLabel(label: label),
              )
            : _FallbackLabel(label: label),
      ),
    );
  }
}

class _FallbackLabel extends StatelessWidget {
  const _FallbackLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.isEmpty ? '?' : label.substring(0, 1),
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w900,
        color: AppTheme.textSecondary,
      ),
    );
  }
}
