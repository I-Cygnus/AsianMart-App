import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/core/utils/formatters.dart';
import 'package:asian_mart_app/domain/entities/app_user.dart';
import 'package:asian_mart_app/domain/entities/order_history_item.dart';
import 'package:asian_mart_app/presentation/orders/order_history_page.dart'
    show OrderStatusBadge;
import 'package:asian_mart_app/presentation/widgets/product_image.dart';
import 'package:asian_mart_app/presentation/widgets/tab_header.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.isAuthenticated,
    required this.user,
    required this.onRequireLogin,
    required this.onRefresh,
    required this.onLogout,
    required this.onOpenAddressManage,
    required this.onOpenWishlist,
    required this.onOpenCart,
    required this.onOpenOrderInquiry,
    required this.recentOrders,
    required this.ordersLoading,
    required this.onLoadOrders,
    required this.onOpenOrder,
  });

  final bool isAuthenticated;
  final AppUser? user;
  final VoidCallback onRequireLogin;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLogout;
  final VoidCallback onOpenAddressManage;
  final VoidCallback onOpenWishlist;
  final VoidCallback onOpenCart;
  final VoidCallback onOpenOrderInquiry;

  /// 최근 주문(쿠팡식 가로 스트립용). shell이 controller.orders를 주입.
  final List<OrderHistoryItem> recentOrders;
  final bool ordersLoading;
  final Future<void> Function() onLoadOrders;
  final void Function(OrderHistoryItem order) onOpenOrder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        TabHeader(
          title: l10n.profileTitle,
        ),
        Expanded(
          child: isAuthenticated
              ? _AuthenticatedView(
                  user: user,
                  onRefresh: onRefresh,
                  onLogout: onLogout,
                  onOpenAddressManage: onOpenAddressManage,
                  onOpenWishlist: onOpenWishlist,
                  onOpenCart: onOpenCart,
                  onOpenOrderInquiry: onOpenOrderInquiry,
                  recentOrders: recentOrders,
                  ordersLoading: ordersLoading,
                  onLoadOrders: onLoadOrders,
                  onOpenOrder: onOpenOrder,
                )
              : _GuestView(onRequireLogin: onRequireLogin),
        ),
      ],
    );
  }
}

class _GuestView extends StatelessWidget {
  const _GuestView({required this.onRequireLogin});

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
                Icons.person_outline_rounded,
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
              l10n.profileGuestDesc,
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

class _AuthenticatedView extends StatelessWidget {
  const _AuthenticatedView({
    required this.user,
    required this.onRefresh,
    required this.onLogout,
    required this.onOpenAddressManage,
    required this.onOpenWishlist,
    required this.onOpenCart,
    required this.onOpenOrderInquiry,
    required this.recentOrders,
    required this.ordersLoading,
    required this.onLoadOrders,
    required this.onOpenOrder,
  });

  final AppUser? user;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLogout;
  final VoidCallback onOpenAddressManage;
  final VoidCallback onOpenWishlist;
  final VoidCallback onOpenCart;
  final VoidCallback onOpenOrderInquiry;
  final List<OrderHistoryItem> recentOrders;
  final bool ordersLoading;
  final Future<void> Function() onLoadOrders;
  final void Function(OrderHistoryItem order) onOpenOrder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
          _UserCard(user: user, onLogout: onLogout),
          const SizedBox(height: 20),
          _OrderDeliveryStrip(
            orders: recentOrders,
            loading: ordersLoading,
            onLoadOrders: onLoadOrders,
            onOpenOrder: onOpenOrder,
            onSeeAll: onOpenOrderInquiry,
          ),
          const SizedBox(height: 20),
          _ProfileMenuList(
            items: [
              _ProfileMenuItem(
                icon: Icons.location_on_outlined,
                label: l10n.changeAddress,
                onTap: onOpenAddressManage,
              ),
              _ProfileMenuItem(
                icon: Icons.favorite_border_rounded,
                label: l10n.navWishlist,
                onTap: onOpenWishlist,
              ),
              _ProfileMenuItem(
                icon: Icons.shopping_bag_outlined,
                label: l10n.navCart,
                onTap: onOpenCart,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuList extends StatelessWidget {
  const _ProfileMenuList({required this.items});

  final List<_ProfileMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppTheme.divider),
            items[i],
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppTheme.textSecondary),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppTheme.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 쿠팡식 주문/배송 가로 스트립. 마운트되면 최근 주문을 로드하고,
/// 카드(이미지 + 배송상태)를 좌우 스크롤로 보여준다. 카드 탭 → 주문 상세.
class _OrderDeliveryStrip extends StatefulWidget {
  const _OrderDeliveryStrip({
    required this.orders,
    required this.loading,
    required this.onLoadOrders,
    required this.onOpenOrder,
    required this.onSeeAll,
  });

  final List<OrderHistoryItem> orders;
  final bool loading;
  final Future<void> Function() onLoadOrders;
  final void Function(OrderHistoryItem order) onOpenOrder;
  final VoidCallback onSeeAll;

  @override
  State<_OrderDeliveryStrip> createState() => _OrderDeliveryStripState();
}

class _OrderDeliveryStripState extends State<_OrderDeliveryStrip> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onLoadOrders());
  }

  static const double _stripHeight = 184;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // 최근 주문 위주(최대 10건). 가로 스크롤이라 너무 많지 않게 자른다.
    final orders = widget.orders.length > 10
        ? widget.orders.sublist(0, 10)
        : widget.orders;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 12),
          child: Row(
            children: [
              Text(
                l10n.orderDeliverySection,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: widget.onSeeAll,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        l10n.seeAll,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          size: 18, color: AppTheme.textTertiary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildContent(l10n, orders),
      ],
    );
  }

  Widget _buildContent(AppLocalizations l10n, List<OrderHistoryItem> orders) {
    if (orders.isEmpty) {
      if (widget.loading) {
        return const SizedBox(
          height: _stripHeight,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return _EmptyOrderHint(message: l10n.orderHistoryEmpty);
    }
    return SizedBox(
      height: _stripHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) => _OrderStripCard(
          order: orders[i],
          onTap: () => widget.onOpenOrder(orders[i]),
        ),
      ),
    );
  }
}

class _OrderStripCard extends StatelessWidget {
  const _OrderStripCard({required this.order, required this.onTap});

  final OrderHistoryItem order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: 150,
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusLg),
                  ),
                  child: SizedBox(
                    height: 96,
                    width: double.infinity,
                    child: ProductImage(
                      imageUrl: order.thumbnailUrl,
                      label: order.representativeProductName ?? '',
                      borderRadius: 0,
                      fontSize: 24,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 배송상태 위주 — 진행 단계 배지를 가장 먼저.
                      OrderStatusBadge(
                        progress: order.progress,
                        label: l10n.orderStatusLabel(order.progress),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order.summaryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      if (order.orderDate != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          formatDate(order.orderDate!),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyOrderHint extends StatelessWidget {
  const _EmptyOrderHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 32, color: AppTheme.textTertiary.withValues(alpha: 0.6)),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppTheme.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.onLogout});

  final AppUser? user;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppTheme.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? '',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if ((user?.phone ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    user!.phone,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onLogout,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              side: const BorderSide(color: AppTheme.border),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }
}
