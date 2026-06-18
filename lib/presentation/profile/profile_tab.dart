import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/domain/entities/address.dart';
import 'package:asian_mart_app/presentation/widgets/tab_header.dart';
import 'package:asian_mart_app/domain/entities/app_user.dart';
import 'package:asian_mart_app/presentation/profile/address_editor_page.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.isAuthenticated,
    required this.user,
    required this.addresses,
    required this.isLoading,
    required this.errorMessage,
    required this.onRequireLogin,
    required this.onRefresh,
    required this.onLogout,
    required this.onAddAddress,
    required this.onSetDefault,
    required this.onDeleteAddress,
    required this.onOpenLanguageSettings,
    required this.onOpenOrders,
  });

  final bool isAuthenticated;
  final AppUser? user;
  final List<Address> addresses;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRequireLogin;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLogout;
  final Future<String?> Function({
    required String addressName,
    required String zipCode,
    required String address1,
    required String address2,
    required bool isDefault,
  }) onAddAddress;
  final ValueChanged<int> onSetDefault;
  final ValueChanged<int> onDeleteAddress;
  final VoidCallback onOpenLanguageSettings;
  final VoidCallback onOpenOrders;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        TabHeader(
          title: l10n.profileTitle,
          action: GestureDetector(
            onTap: onOpenLanguageSettings,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.settings_outlined,
                size: 20,
                color: AppTheme.textTertiary,
              ),
            ),
          ),
        ),
        Expanded(
          child: isAuthenticated
              ? _AuthenticatedView(
                  user: user,
                  addresses: addresses,
                  isLoading: isLoading,
                  errorMessage: errorMessage,
                  onRefresh: onRefresh,
                  onLogout: onLogout,
                  onAddAddress: onAddAddress,
                  onSetDefault: onSetDefault,
                  onDeleteAddress: onDeleteAddress,
                  onOpenOrders: onOpenOrders,
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
    required this.addresses,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.onLogout,
    required this.onAddAddress,
    required this.onSetDefault,
    required this.onDeleteAddress,
    required this.onOpenOrders,
  });

  final AppUser? user;
  final List<Address> addresses;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLogout;
  final Future<String?> Function({
    required String addressName,
    required String zipCode,
    required String address1,
    required String address2,
    required bool isDefault,
  }) onAddAddress;
  final ValueChanged<int> onSetDefault;
  final ValueChanged<int> onDeleteAddress;
  final VoidCallback onOpenOrders;

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
          const SizedBox(height: 12),
          _MenuRow(
            icon: Icons.receipt_long_outlined,
            title: l10n.orderHistory,
            subtitle: l10n.orderHistoryMenuDesc,
            onTap: onOpenOrders,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                l10n.addressManage,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AddressEditorPage(
                        onSubmit: onAddAddress,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.addAddress),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (isLoading && addresses.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (errorMessage != null && addresses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else if (addresses.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 36,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.noAddresses,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.noAddressesDesc,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            )
          else
            for (final address in addresses) ...[
              _AddressCard(
                address: address,
                onSetDefault: () => onSetDefault(address.id),
                onDelete: () => onDeleteAddress(address.id),
              ),
              const SizedBox(height: 10),
            ],
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

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppTheme.textTertiary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 20, color: AppTheme.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onSetDefault,
    required this.onDelete,
  });

  final Address address;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: address.isDefault
            ? Border.all(
                color: AppTheme.primary.withValues(alpha: 0.3),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      address.addressName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Text(
                          l10n.defaultAddress,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: AppTheme.textTertiary,
                ),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            address.fullAddress,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          if (!address.isDefault) ...[
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: onSetDefault,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 34),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                foregroundColor: AppTheme.textSecondary,
                side: const BorderSide(color: AppTheme.border),
              ),
              child: Text(l10n.setDefaultAddress),
            ),
          ],
        ],
      ),
    );
  }
}
