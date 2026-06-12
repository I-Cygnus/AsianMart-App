import 'dart:async';

import 'package:flutter/material.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/core/utils/formatters.dart';
import 'package:asian_mart_app/domain/entities/product.dart';
import 'package:asian_mart_app/domain/entities/product_category.dart';
import 'package:asian_mart_app/domain/enums/sort_mode.dart';
import 'package:asian_mart_app/presentation/widgets/empty_state.dart';
import 'package:asian_mart_app/presentation/widgets/product_image.dart';
import 'package:asian_mart_app/presentation/widgets/tab_header.dart';

// ── ProductListPage ───────────────────────────────────────────────────────────

/// '상품' 탭 본문. 검색 / 카테고리·정렬 필터·정렬은 모두 서버 API 호출로 처리되며,
/// 아래로 스크롤하면 다음 페이지를 요청하는 무한 스크롤 페이지네이션을 제공한다.
class ProductListPage extends StatefulWidget {
  const ProductListPage({
    super.key,
    required this.products,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.totalCount,
    required this.errorMessage,
    required this.categories,
    required this.selectedCategoryId,
    required this.searchQuery,
    required this.sortMode,
    required this.wishlistIds,
    required this.onRefresh,
    required this.onSearch,
    required this.onSelectCategory,
    required this.onSortChanged,
    required this.onLoadMore,
    required this.onProductTap,
    required this.onToggleWishlist,
    required this.onAddToCart,
  });

  final List<Product> products;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int totalCount;
  final String? errorMessage;
  final List<ProductCategory> categories;
  final int? selectedCategoryId;
  final String searchQuery;
  final SortMode sortMode;
  final Set<int> wishlistIds;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onSearch;
  final ValueChanged<int?> onSelectCategory;
  final ValueChanged<SortMode> onSortChanged;
  final Future<void> Function() onLoadMore;
  final ValueChanged<Product> onProductTap;
  final ValueChanged<int> onToggleWishlist;
  final ValueChanged<Product> onAddToCart;

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  static const Duration _searchDebounce = Duration(milliseconds: 400);

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }


  // ── Pagination (scroll-driven) ──────────────────────────────────────────────

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

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () {
      widget.onSearch(value.trim());
    });
  }

  void _selectCategory(ProductCategory cat) {
    if (cat.id == widget.selectedCategoryId) {
      return;
    }
    _debounce?.cancel();
    widget.onSelectCategory(cat.id);
  }

  void _showSortSheet(AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (_) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '정렬 기준',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
              ...SortMode.values.map((mode) {
                final isActive = widget.sortMode == mode;
                return ListTile(
                  dense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  title: Text(
                    l10n.sortModeLabel(mode),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                      color:
                          isActive ? AppTheme.primary : AppTheme.textPrimary,
                    ),
                  ),
                  trailing: isActive
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppTheme.primary,
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    if (mode != widget.sortMode) {
                      widget.onSortChanged(mode);
                    }
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        TabHeader(title: l10n.navProducts),
        Expanded(child: _buildBody(l10n)),
      ],
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (widget.isLoading && widget.products.isEmpty) {
      return const _ListLoadingSkeleton();
    }
    if (widget.errorMessage != null && widget.products.isEmpty) {
      return _ErrorPanel(message: widget.errorMessage!, onRetry: widget.onRefresh);
    }

    final products = widget.products;
    final displayCategories = [
        ProductCategory(id: null, name: '전체'),
        ...widget.categories
    ];
    final hasMore = widget.hasMore;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: _SearchBar(
              controller: _searchController,
              hintText: l10n.searchProductHint,
              onChanged: _onSearchChanged,
            ),
          ),
          if (displayCategories.length > 1)
            SliverToBoxAdapter(
              child: _CategoryFilterBar(
                categories: displayCategories,
                selected: widget.selectedCategoryId,
                allSelected: widget.selectedCategoryId == null,
                onSelect: _selectCategory,
              ),
            ),
          SliverToBoxAdapter(
            child: _ResultBar(
              count: widget.totalCount,
              sortMode: widget.sortMode,
              onSortTap: () => _showSortSheet(l10n),
              l10n: l10n,
            ),
          ),
          if (products.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: '검색 결과가 없어요',
                description: '다른 카테고리나 검색어를 사용해 보세요',
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= products.length) {
                    return _LoadMoreIndicator(loading: widget.isLoadingMore);
                  }
                  final product = products[index];
                  return RepaintBoundary(
                    child: _ProductListTile(
                      product: product,
                      isWishlisted: widget.wishlistIds.contains(product.id),
                      onTap: () => widget.onProductTap(product),
                      onWishlist: () => widget.onToggleWishlist(product.id),
                      onAddToCart: () => widget.onAddToCart(product),
                    ),
                  );
                },
                childCount: products.length + (hasMore ? 1 : 0),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ── Search Bar ──────────────────────────────────────────────────────────────

class _SearchBar extends StatefulWidget {
  const _SearchBar({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.border),
        ),
        child: TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          textInputAction: TextInputAction.search,
          style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle:
                const TextStyle(fontSize: 14, color: AppTheme.textTertiary),
            prefixIcon: const Icon(Icons.search_rounded,
                size: 20, color: AppTheme.textTertiary),
            suffixIcon: _hasText
                ? IconButton(
                    icon: const Icon(Icons.cancel_rounded,
                        size: 18, color: AppTheme.textTertiary),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            isDense: true,
          ),
        ),
      ),
    );
  }
}

// ── Category Filter Bar (chips) ───────────────────────────────────────────────

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.categories,
    required this.selected,
    required this.allSelected,
    required this.onSelect,
  });

  final List<ProductCategory> categories;
  final int? selected;
  final bool allSelected;
  final ValueChanged<ProductCategory> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.only(bottom: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: categories.map((cat) {
            final isActive = cat.id == null
                ? allSelected
                : (!allSelected && selected == cat.id);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelect(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primary : AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    border: Border.all(
                      color: isActive ? AppTheme.primary : AppTheme.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 6),
                      Text(
                        cat.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          color:
                              isActive ? Colors.white : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Result + Sort Bar ─────────────────────────────────────────────────────────

class _ResultBar extends StatelessWidget {
  const _ResultBar({
    required this.count,
    required this.sortMode,
    required this.onSortTap,
    required this.l10n,
  });

  final int count;
  final SortMode sortMode;
  final VoidCallback onSortTap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: AppTheme.background,
      child: Row(
        children: [
          Text(
            l10n.productCount(count),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSortTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tune_rounded,
                      size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    l10n.sortModeLabel(sortMode),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 16, color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Product List Tile ─────────────────────────────────────────────────────────

class _ProductListTile extends StatelessWidget {
  const _ProductListTile({
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

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 5, 16, 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                SizedBox(
                  width: 96,
                  height: 96,
                  child: ProductImage(
                    imageUrl: product.thumbnailUrl,
                    label: product.name,
                    unavailable: unavailable,
                    borderRadius: AppTheme.radiusMd,
                    fontSize: 36,
                  ),
                ),
                if (product.discountPercent > 0 && !unavailable)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppTheme.radiusMd),
                          bottomRight: Radius.circular(AppTheme.radiusSm),
                        ),
                      ),
                      child: Text(
                        '${product.discountPercent}%',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (unavailable)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '일시품절',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: SizedBox(
                height: 96,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                              height: 1.3,
                            ),
                          ),
                        ),
                        _HeartButton(
                          isWishlisted: isWishlisted,
                          onTap: onWishlist,
                        ),
                      ],
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
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (product.discountPercent > 0) ...[
                          Text(
                            '${product.discountPercent}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          formatPrice(product.sellingPrice),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const Spacer(),
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

class _HeartButton extends StatelessWidget {
  const _HeartButton({required this.isWishlisted, required this.onTap});

  final bool isWishlisted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Icon(
          isWishlisted
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          size: 20,
          color: isWishlisted ? AppTheme.primary : AppTheme.textTertiary,
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
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: const Icon(Icons.add_rounded, size: 19, color: Colors.white),
      ),
    );
  }
}

// ── Load More Indicator ───────────────────────────────────────────────────────

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
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppTheme.primary,
                ),
              )
            : const SizedBox(height: 22),
      ),
    );
  }
}

// ── Loading Skeleton ──────────────────────────────────────────────────────────

class _ListLoadingSkeleton extends StatelessWidget {
  const _ListLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (_, __) => const _ListSkeletonCard(),
    );
  }
}

class _ListSkeletonCard extends StatelessWidget {
  const _ListSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppTheme.imagePlaceholder,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(width: double.infinity, height: 13, radius: 4),
                SizedBox(height: 6),
                _SkeletonBox(width: 140, height: 13, radius: 4),
                SizedBox(height: 30),
                _SkeletonBox(width: 90, height: 18, radius: 4),
              ],
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
                Icons.error_outline_rounded,
                size: 38,
                color: Colors.red.shade300,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
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
