import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/core/utils/formatters.dart';
import 'package:asian_mart_app/domain/entities/product.dart';
import 'package:asian_mart_app/domain/enums/sort_mode.dart';
import 'package:asian_mart_app/presentation/widgets/empty_state.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.products,
    required this.isLoading,
    required this.errorMessage,
    required this.searchQuery,
    required this.sortMode,
    required this.currentUserName,
    required this.isAuthenticated,
    required this.wishlistIds,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onRefresh,
    required this.onOpenAuth,
    required this.onProductTap,
    required this.onToggleWishlist,
    required this.onAddToCart,
  });

  final List<Product> products;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final SortMode sortMode;
  final String? currentUserName;
  final bool isAuthenticated;
  final Set<int> wishlistIds;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<SortMode> onSortChanged;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenAuth;
  final ValueChanged<Product> onProductTap;
  final ValueChanged<int> onToggleWishlist;
  final ValueChanged<Product> onAddToCart;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(HomeTab old) {
    super.didUpdateWidget(old);
    if (old.searchQuery != widget.searchQuery &&
        _searchController.text != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _SearchHeader(
          controller: _searchController,
          hintText: l10n.searchProductHint,
          onChanged: widget.onSearchChanged,
          isAuthenticated: widget.isAuthenticated,
          onOpenAuth: widget.onOpenAuth,
        ),
        const Divider(height: 1),
        Expanded(child: _buildBody(l10n)),
      ],
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (widget.isLoading && widget.products.isEmpty) {
      return const _GridLoadingSkeleton();
    }
    if (widget.errorMessage != null && widget.products.isEmpty) {
      return _ErrorPanel(
        message: widget.errorMessage!,
        onRetry: widget.onRefresh,
      );
    }
    if (widget.products.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        title: '등록된 상품이 없어요',
        description: l10n.pullToRefresh,
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        slivers: [
          if (widget.searchQuery.isEmpty)
            SliverToBoxAdapter(
              child: _BannerSection(
                isAuthenticated: widget.isAuthenticated,
                userName: widget.currentUserName,
                onOpenAuth: widget.onOpenAuth,
              ),
            ),
          SliverToBoxAdapter(
            child: _FilterBar(
              productCount: widget.products.length,
              sortMode: widget.sortMode,
              onSortChanged: widget.onSortChanged,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 32),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = widget.products[index];
                  return RepaintBoundary(
                    child: _GridProductCard(
                      product: product,
                      isWishlisted: widget.wishlistIds.contains(product.id),
                      onTap: () => widget.onProductTap(product),
                      onWishlist: () => widget.onToggleWishlist(product.id),
                      onAddToCart: () => widget.onAddToCart(product),
                    ),
                  );
                },
                childCount: widget.products.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search Header ─────────────────────────────────────────────────────────────

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.isAuthenticated,
    required this.onOpenAuth,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final bool isAuthenticated;
  final VoidCallback onOpenAuth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: SearchBar(
              controller: controller,
              hintText: hintText,
              leading: const Padding(
                padding: EdgeInsets.only(left: 2),
                child: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppTheme.textTertiary,
                ),
              ),
              onChanged: onChanged,
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor:
                  const WidgetStatePropertyAll(AppTheme.background),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppTheme.border),
                ),
              ),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 4),
              ),
              constraints: const BoxConstraints(minHeight: 44),
            ),
          ),
          if (!isAuthenticated) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onOpenAuth,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.signIn,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Banner ────────────────────────────────────────────────────────────────────

class _BannerSection extends StatelessWidget {
  const _BannerSection({
    required this.isAuthenticated,
    required this.userName,
    required this.onOpenAuth,
  });

  final bool isAuthenticated;
  final String? userName;
  final VoidCallback onOpenAuth;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD80027), Color(0xFFFF4F4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: -24,
            bottom: -28,
            child: Icon(
              Icons.storefront_rounded,
              size: 150,
              color: Colors.white.withValues(alpha: 0.09),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 100, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isAuthenticated
                      ? '${userName ?? ''}님, 안녕하세요! 👋'
                      : '신선한 아시안 식품',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isAuthenticated
                      ? '오늘도 좋은 쇼핑 되세요.'
                      : '로그인하고 찜 목록과 주문을 이용해 보세요.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                if (!isAuthenticated) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: onOpenAuth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            '로그인',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 10,
                            color: Colors.white,
                          ),
                        ],
                      ),
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

// ── Filter Bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.productCount,
    required this.sortMode,
    required this.onSortChanged,
  });

  final int productCount;
  final SortMode sortMode;
  final ValueChanged<SortMode> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
      child: Row(
        children: [
          Text(
            '총 $productCount개',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textTertiary,
            ),
          ),
          const Spacer(),
          DropdownButton<SortMode>(
            value: sortMode,
            underline: const SizedBox.shrink(),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppTheme.textSecondary,
            ),
            onChanged: (value) {
              if (value != null) onSortChanged(value);
            },
            items: SortMode.values
                .map(
                  (mode) => DropdownMenuItem(
                    value: mode,
                    child: Text(l10n.sortModeLabel(mode)),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Grid Product Card ─────────────────────────────────────────────────────────

class _GridProductCard extends StatelessWidget {
  const _GridProductCard({
    required this.product,
    required this.isWishlisted,
    required this.onTap,
    required this.onWishlist,
    required this.onAddToCart,
  });

  final Product product;
  final bool isWishlisted;
  final VoidCallback onTap;
  final VoidCallback onWishlist;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final unavailable = !product.isOrderable;

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area ──────────────────────────────
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    color: unavailable
                        ? const Color(0xFFEEEEEE)
                        : AppTheme.imagePlaceholder,
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: unavailable ? 0.35 : 1.0,
                      child: Text(
                        product.name.isEmpty ? '?' : product.name.substring(0, 1),
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
                if (product.discountPercent > 0 && !unavailable)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Text(
                        '${product.discountPercent}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                if (unavailable)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.03),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '일시품절',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    elevation: 1.5,
                    shadowColor: Colors.black.withValues(alpha: 0.12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: onWishlist,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          isWishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color: isWishlisted
                              ? AppTheme.primary
                              : AppTheme.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // ── Info area ───────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        height: 1.35,
                      ),
                    ),
                    const Spacer(),
                    if (product.discountPercent > 0)
                      Text(
                        formatPrice(product.listPrice),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textTertiary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            formatPrice(product.sellingPrice),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        if (!unavailable) _AddButton(onPressed: onAddToCart),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primary,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(7),
          child: Icon(Icons.add_rounded, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

// ── Loading Skeleton ──────────────────────────────────────────────────────────

class _GridLoadingSkeleton extends StatelessWidget {
  const _GridLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const _GridSkeletonCard(),
    );
  }
}

class _GridSkeletonCard extends StatelessWidget {
  const _GridSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.imagePlaceholder,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(
                    width: double.infinity,
                    height: 12,
                    radius: 4,
                  ),
                  const SizedBox(height: 5),
                  _SkeletonBox(width: 80, height: 12, radius: 4),
                  const Spacer(),
                  _SkeletonBox(width: 64, height: 16, radius: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.imagePlaceholder,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Error Panel ───────────────────────────────────────────────────────────────

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 38,
                color: Colors.red.shade300,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '불러오는 데 실패했어요',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textTertiary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
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
