import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/presentation/widgets/tab_header.dart';
import 'package:asian_mart_app/domain/entities/app_user.dart';

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
  });

  final AppUser? user;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLogout;
  final VoidCallback onOpenAddressManage;
  final VoidCallback onOpenWishlist;
  final VoidCallback onOpenCart;
  final VoidCallback onOpenOrderInquiry;

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
              _ProfileMenuItem(
                icon: Icons.receipt_long_outlined,
                label: l10n.orderInquiry,
                onTap: onOpenOrderInquiry,
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
