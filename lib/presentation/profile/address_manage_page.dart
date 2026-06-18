import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/domain/entities/address.dart';
import 'package:asian_mart_app/presentation/profile/address_editor_page.dart';
import 'package:asian_mart_app/presentation/widgets/tab_header.dart';

class AddressManagePage extends StatelessWidget {
  const AddressManagePage({
    super.key,
    required this.addresses,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.onAddAddress,
    required this.onSetDefault,
    required this.onDeleteAddress,
  });

  final List<Address> addresses;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRefresh;
  final Future<String?> Function({
    required String addressName,
    required String zipCode,
    required String address1,
    required String address2,
    required bool isDefault,
  }) onAddAddress;
  final ValueChanged<int> onSetDefault;
  final ValueChanged<int> onDeleteAddress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimary,
        scrolledUnderElevation: 0.5,
        title: Text(
          l10n.changeAddress,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.divider),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            TabLayoutSpacing.horizontal,
            TabLayoutSpacing.contentTop,
            TabLayoutSpacing.horizontal,
            TabLayoutSpacing.contentBottom,
          ),
          children: [
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
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
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
