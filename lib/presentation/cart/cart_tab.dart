import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/core/utils/formatters.dart';
import 'package:asian_mart_app/domain/entities/cart_entry.dart';
import 'package:asian_mart_app/presentation/widgets/empty_state.dart';
import 'package:asian_mart_app/presentation/widgets/product_image.dart';
import 'package:asian_mart_app/presentation/widgets/quantity_stepper.dart';
import 'package:asian_mart_app/presentation/widgets/tab_header.dart';

class CartTab extends StatelessWidget {
  const CartTab({
    super.key,
    required this.isAuthenticated,
    required this.items,
    required this.isLoading,
    required this.errorMessage,
    required this.total,
    required this.onRefresh,
    required this.onDelete,
    required this.onQuantityChanged,
    required this.onSelectedChanged,
    required this.onCheckout,
    required this.onRequireLogin,
    this.onSelectAll,
    this.onGoShopping,
  });

  final bool isAuthenticated;
  final List<CartEntry> items;
  final bool isLoading;
  final String? errorMessage;
  final double total;
  final Future<void> Function() onRefresh;
  final ValueChanged<int> onDelete;
  final VoidCallback onRequireLogin;
  final VoidCallback? onGoShopping;
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
    } else if (!isAuthenticated && items.isEmpty) {
      body = _AuthPrompt(onRequireLogin: onRequireLogin);
    } else if (errorMessage != null && items.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48, color: AppTheme.error),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: AppTheme.textSecondary, height: 1.5),
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
        actionLabel: '쇼핑 시작하기',
        onAction: onGoShopping,
      );
    } else {
      body = Column(
        children: [
          const SizedBox(height: TabLayoutSpacing.contentTop),
          _SelectAllBar(
            allSelected: _allSelected,
            selectedCount: _selectedCount,
            totalCount: items.length,
            onToggle:
                onSelectAll != null ? () => onSelectAll!(!_allSelected) : null,
          ),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
                onRefresh: onRefresh,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    TabLayoutSpacing.horizontal,
                    10,
                    TabLayoutSpacing.horizontal,
                    TabLayoutSpacing.contentBottom,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
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
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              color: Colors.white, size: 22),
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
        TabHeader(
          title: l10n.cartTitle,
          badge: items.isNotEmpty ? '${items.length}' : null,
        ),
        Expanded(child: body),
        if (items.isNotEmpty)
          _CheckoutBar(total: total, onCheckout: onCheckout),
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
      padding: const EdgeInsets.symmetric(
        horizontal: TabLayoutSpacing.horizontal,
        vertical: 10,
      ),
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
                      borderRadius: BorderRadius.circular(AppTheme.radiusXs),
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
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
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

class _AuthPrompt extends StatelessWidget {
  const _AuthPrompt({required this.onRequireLogin});

  final VoidCallback onRequireLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 46,
                color: AppTheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.authRequiredTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.authRequiredDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textTertiary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: onRequireLogin,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(l10n.signIn),
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
    return SizedBox(
      width: 68,
      height: 68,
      child: ProductImage(
        imageUrl: imageUrl,
        label: label,
        borderRadius: AppTheme.radiusMd,
        fontSize: 26,
      ),
    );
  }
}
