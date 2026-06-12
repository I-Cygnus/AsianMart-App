import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/core/utils/formatters.dart';
import 'package:asian_mart_app/domain/entities/wishlist_item.dart';
import 'package:asian_mart_app/presentation/widgets/empty_state.dart';
import 'package:asian_mart_app/presentation/widgets/product_image.dart';
import 'package:asian_mart_app/presentation/widgets/tab_header.dart';

class WishlistTab extends StatelessWidget {
  const WishlistTab({
    super.key,
    required this.isAuthenticated,
    required this.isLoading,
    required this.errorMessage,
    required this.items,
    required this.onRequireLogin,
    required this.onRefresh,
    required this.onRemove,
    required this.onAddToCart,
    required this.onOpenProduct,
  });

  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final List<WishlistItem> items;
  final VoidCallback onRequireLogin;
  final Future<void> Function() onRefresh;
  final ValueChanged<int> onRemove;
  final ValueChanged<int> onAddToCart;
  final ValueChanged<int> onOpenProduct;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget body;
    if (!isAuthenticated) {
      body = _AuthPrompt(onRequireLogin: onRequireLogin);
    } else if (isLoading && items.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null && items.isEmpty) {
      body = _ErrorState(
        message: errorMessage!,
        onRetry: onRefresh,
      );
    } else if (items.isEmpty) {
      body = EmptyState(
        icon: Icons.favorite_border_rounded,
        title: l10n.wishlistEmpty,
        description: l10n.wishlistEmptyDesc,
      );
    } else {
      body = RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            TabLayoutSpacing.horizontal,
            TabLayoutSpacing.contentTop,
            TabLayoutSpacing.horizontal,
            TabLayoutSpacing.contentBottom,
          ),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = items[index];
            return _WishlistItemCard(
              item: item,
              onTap: () => onOpenProduct(item.productId),
              onRemove: () => onRemove(item.productId),
              onAddToCart: () => onAddToCart(item.productId),
            );
          },
        ),
      );
    }

    return Column(
      children: [
        TabHeader(
          title: l10n.wishlistTitle,
          badge: items.isNotEmpty ? '${items.length}' : null,
        ),
        Expanded(child: body),
      ],
    );
  }
}

class _WishlistItemCard extends StatelessWidget {
  const _WishlistItemCard({
    required this.item,
    required this.onTap,
    required this.onRemove,
    required this.onAddToCart,
  });

  final WishlistItem item;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: ProductImage(
                  imageUrl: item.thumbnailUrl,
                  label: item.productName,
                  borderRadius: AppTheme.radiusMd,
                  fontSize: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.productDescription,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          formatPrice(item.sellingPrice),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: onRemove,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.favorite_rounded,
                              size: 20,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        FilledButton.tonal(
                          onPressed: item.isAvailable ? onAddToCart : null,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 34),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: Text(item.isAvailable ? '담기' : '품절'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                Icons.favorite_border_rounded,
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
              '찜 목록은 로그인 후 사용할 수 있어요.\n관심 상품을 저장하고 한번에 확인해 보세요.',
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
