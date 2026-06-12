import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/core/utils/formatters.dart';
import 'package:asian_mart_app/domain/entities/wishlist_item.dart';
import 'package:asian_mart_app/presentation/widgets/empty_state.dart';
import 'package:asian_mart_app/presentation/widgets/product_image.dart';
import 'package:asian_mart_app/presentation/widgets/tab_header.dart';

class WishlistTab extends StatefulWidget {
  const WishlistTab({
    super.key,
    required this.isAuthenticated,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.errorMessage,
    required this.items,
    required this.totalCount,
    required this.onRequireLogin,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onRemove,
    required this.onAddToCart,
    required this.onOpenProduct,
  });

  final bool isAuthenticated;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final List<WishlistItem> items;
  final int totalCount;
  final VoidCallback onRequireLogin;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final ValueChanged<int> onRemove;
  final ValueChanged<int> onAddToCart;
  final ValueChanged<int> onOpenProduct;

  @override
  State<WishlistTab> createState() => _WishListTabState();
  
}

class _WishListTabState extends State<WishlistTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients ||
        widget.isLoadingMore ||
        !widget.hasMore) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 320) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget body;
    if (!widget.isAuthenticated) {
      body = _AuthPrompt(onRequireLogin: widget.onRequireLogin);
    } else if (widget.isLoading && widget.items.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (widget.errorMessage != null && widget.items.isEmpty) {
      body = _ErrorState(
        message: widget.errorMessage!,
        onRetry: widget.onRefresh,
      );
    } else if (widget.items.isEmpty) {
      body = EmptyState(
        icon: Icons.favorite_border_rounded,
        title: l10n.wishlistEmpty,
        description: l10n.wishlistEmptyDesc,
      );
    } else {
      body = RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(
            TabLayoutSpacing.horizontal,
            TabLayoutSpacing.contentTop,
            TabLayoutSpacing.horizontal,
            TabLayoutSpacing.contentBottom,
          ),
          itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= widget.items.length) {
              return _LoadMoreIndicator(loading: widget.isLoadingMore);
            }
            final item = widget.items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _WishlistItemCard(
                item: item,
                onTap: () => widget.onOpenProduct(item.productId),
                onRemove: () => widget.onRemove(item.productId),
                onAddToCart: () => widget.onAddToCart(item.productId),
              ),
            );
          },
        ),
      );
    }

    return Column(
      children: [
        TabHeader(
          title: l10n.wishlistTitle,
          badge: widget.totalCount > 0 ? '${widget.totalCount}' : null,
        ),
        Expanded(child: body),
      ],
    );
  }

  
}

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator({required this.loading});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              )
            : const SizedBox.shrink(),
      ),
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
