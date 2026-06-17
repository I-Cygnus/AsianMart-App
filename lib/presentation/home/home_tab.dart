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

const _kCategoryIcons = <int, String>{
  1: '🌾',
  2: '🫙',
  3: '🍘',
  4: '🧃',
  5: '🍜',
  6: '🥬',
  7: '🧊',
  8: '🐟',
  9: '🥛',
  10: '🌿',
};

String _categoryIcon(ProductCategory category) {
  if (category.id == null) {
    return '🛒';
  }
  return _kCategoryIcons[category.id] ?? '📦';
}

// ── Banner data ───────────────────────────────────────────────────────────────

class _BannerData {
  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
  });
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;
}

const _kBanners = [
  _BannerData(
    title: '신선한 아시안 식품',
    subtitle: '전통의 맛을 집에서 간편하게',
    gradient: [Color(0xFFD80027), Color(0xFFFF6B6B)],
    icon: Icons.storefront_rounded,
  ),
  _BannerData(
    title: '이번 주 특가 상품',
    subtitle: '최대 30% 할인 · 한정 수량',
    gradient: [Color(0xFF1565C0), Color(0xFF42A5F5)],
    icon: Icons.local_offer_rounded,
  ),
  _BannerData(
    title: '무료배송 이벤트',
    subtitle: '30,000원 이상 구매 시 무료배송',
    gradient: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
    icon: Icons.local_shipping_rounded,
  ),
];

// ── HomeTab ───────────────────────────────────────────────────────────────────

class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.products,
    required this.recommendedProducts,
    required this.popularProducts,
    required this.isLoading,
    required this.isHomeSectionsLoading,
    required this.errorMessage,
    required this.homeSectionsError,
    required this.searchQuery,
    required this.sortMode,
    required this.currentUserName,
    required this.isAuthenticated,
    required this.wishlistIds,
    required this.cartCount,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onRefresh,
    required this.onOpenAuth,
    required this.onProfileTap,
    required this.onCartTap,
    required this.onProductTap,
    required this.onToggleWishlist,
    required this.onAddToCart,
    required this.onOpenLanguageSettings,
    required this.rootCategories,
    required this.onCategoryTap,
  });

  final List<Product> products;
  final List<Product> recommendedProducts;
  final List<Product> popularProducts;
  final bool isLoading;
  final bool isHomeSectionsLoading;
  final String? errorMessage;
  final String? homeSectionsError;
  final String searchQuery;
  final SortMode sortMode;
  final String? currentUserName;
  final bool isAuthenticated;
  final Set<int> wishlistIds;
  final int cartCount;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<SortMode> onSortChanged;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenAuth;
  final VoidCallback onProfileTap;
  final VoidCallback onCartTap;
  final VoidCallback onOpenLanguageSettings;
  final ValueChanged<Product> onProductTap;
  final ValueChanged<int> onToggleWishlist;
  final ValueChanged<Product> onAddToCart;
  final List<ProductCategory> rootCategories;
  final ValueChanged<ProductCategory> onCategoryTap;

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

  void _showSortSheet(AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '정렬 기준',
                    style: const TextStyle(
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
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w400,
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
                    widget.onSortChanged(mode);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        TabHeader(
          leading: const _HomeLogo(),
          action: _HomeActions(
            cartCount: widget.cartCount,
            isAuthenticated: widget.isAuthenticated,
            userName: widget.currentUserName,
            onCartTap: widget.onCartTap,
            onOpenAuth: widget.onOpenAuth,
            onProfileTap: widget.onProfileTap,
            onOpenLanguageSettings: widget.onOpenLanguageSettings,
          ),
        ),
        Expanded(child: _buildBody(l10n)),
      ],
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    final isSearching = widget.searchQuery.isNotEmpty;

    if (isSearching) {
      return _buildSearchBody(l10n);
    }
    return _buildHomeBody(l10n);
  }

  Widget _buildSearchBody(AppLocalizations l10n) {
    if (widget.isLoading && widget.products.isEmpty) {
      return const _GridLoadingSkeleton();
    }
    if (widget.errorMessage != null && widget.products.isEmpty) {
      return _ErrorPanel(
        message: widget.errorMessage!,
        onRetry: widget.onRefresh,
      );
    }

    final shown = widget.products;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HomeSearchBar(
              controller: _searchController,
              hintText: l10n.searchProductHint,
              onChanged: widget.onSearchChanged,
            ),
          ),
          SliverToBoxAdapter(
            child: _SortBar(
              productCount: shown.length,
              sortMode: widget.sortMode,
              onSortTap: () => _showSortSheet(l10n),
              l10n: l10n,
            ),
          ),
          if (shown.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: '검색 결과가 없어요',
                description: '다른 카테고리나 검색어를 사용해 보세요',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 40),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.56,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = shown[index];
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
                  childCount: shown.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHomeBody(AppLocalizations l10n) {
    if (widget.isHomeSectionsLoading &&
        widget.recommendedProducts.isEmpty &&
        widget.popularProducts.isEmpty) {
      return const _GridLoadingSkeleton();
    }
    if (widget.homeSectionsError != null &&
        widget.recommendedProducts.isEmpty &&
        widget.popularProducts.isEmpty) {
      return _ErrorPanel(
        message: widget.homeSectionsError!,
        onRetry: widget.onRefresh,
      );
    }

    final popular = widget.popularProducts;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HomeSearchBar(
              controller: _searchController,
              hintText: l10n.searchProductHint,
              onChanged: widget.onSearchChanged,
            ),
          ),
          const SliverToBoxAdapter(child: _BannerCarousel()),
          if (widget.rootCategories.length > 1)
            SliverToBoxAdapter(
              child: _QuickCategories(
                categories: widget.rootCategories,
                onSelect: widget.onCategoryTap,
              ),
            ),
          if (widget.recommendedProducts.isNotEmpty)
            SliverToBoxAdapter(
              child: _RecommendSection(
                products: widget.recommendedProducts,
                wishlistIds: widget.wishlistIds,
                onProductTap: widget.onProductTap,
                onToggleWishlist: widget.onToggleWishlist,
                onAddToCart: widget.onAddToCart,
              ),
            ),
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: '인기 상품',
              trailing: popular.isNotEmpty ? '${popular.length}개' : null,
            ),
          ),
          if (popular.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 40),
                child: Text(
                  '등록된 인기 상품이 없어요',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 40),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.56,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = popular[index];
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
                  childCount: popular.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Home Header Widgets ───────────────────────────────────────────────────────

class _HomeLogo extends StatelessWidget {
  const _HomeLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 17),
        ),
        const SizedBox(width: 8),
        const Text(
          'Asian Mart',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _HomeActions extends StatelessWidget {
  const _HomeActions({
    required this.cartCount,
    required this.isAuthenticated,
    required this.userName,
    required this.onCartTap,
    required this.onOpenAuth,
    required this.onProfileTap,
    required this.onOpenLanguageSettings,
  });

  final int cartCount;
  final bool isAuthenticated;
  final String? userName;
  final VoidCallback onCartTap;
  final VoidCallback onOpenAuth;
  final VoidCallback onProfileTap;
  final VoidCallback onOpenLanguageSettings;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode.toUpperCase();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeaderIconBtn(icon: Icons.notifications_outlined, onTap: () {}),
        Stack(
          clipBehavior: Clip.none,
          children: [
            _HeaderIconBtn(icon: Icons.shopping_bag_outlined, onTap: onCartTap),
            if (cartCount > 0)
              Positioned(
                top: 6,
                right: 4,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 3.5),
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusSm)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    cartCount > 99 ? '99+' : '$cartCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (!isAuthenticated)
          TextButton(
            onPressed: onOpenAuth,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primary,
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(0, 40),
            ),
            child: const Text('로그인'),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top:4, right: 6),
            child: GestureDetector(
              onTap: onOpenLanguageSettings,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  languageCode,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HomeSearchBar extends StatefulWidget {
  const _HomeSearchBar({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  State<_HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<_HomeSearchBar> {
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
          style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(fontSize: 14, color: AppTheme.textTertiary),
            prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppTheme.textTertiary),
            suffixIcon: _hasText
                ? IconButton(
                    icon: const Icon(Icons.cancel_rounded, size: 18, color: AppTheme.textTertiary),
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

class _HeaderIconBtn extends StatelessWidget {
  const _HeaderIconBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 24, color: AppTheme.textSecondary),
      onPressed: onTap,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }
}

// ── Banner Carousel ───────────────────────────────────────────────────────────

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel();

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % _kBanners.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.only(top: 4, bottom: 14),
      child: Column(
        children: [
          SizedBox(
            height: 148,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _kBanners.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, index) =>
                  _BannerCard(data: _kBanners[index]),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_kBanners.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _currentPage ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color:
                      i == _currentPage ? AppTheme.primary : AppTheme.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.data});
  final _BannerData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: data.gradient.first.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -8,
            child: Icon(
              data.icon,
              size: 110,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 100, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    height: 1.4,
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

// ── Quick Categories ──────────────────────────────────────────────────────────

class _QuickCategories extends StatelessWidget {
  const _QuickCategories({
    required this.categories,
    required this.onSelect,
  });

  final List<ProductCategory> categories;
  final ValueChanged<ProductCategory> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: categories.map((cat) {
            return GestureDetector(
              onTap: () => onSelect(cat),
              child: Padding(
                padding: const EdgeInsets.only(right: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Center(
                        child: Text(
                          _categoryIcon(cat),
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat.name,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.trailing,
  });

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Recommend Section ─────────────────────────────────────────────────────────

class _RecommendSection extends StatelessWidget {
  const _RecommendSection({
    required this.products,
    required this.wishlistIds,
    required this.onProductTap,
    required this.onToggleWishlist,
    required this.onAddToCart,
  });

  final List<Product> products;
  final Set<int> wishlistIds;
  final ValueChanged<Product> onProductTap;
  final ValueChanged<int> onToggleWishlist;
  final ValueChanged<Product> onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: '추천 상품'),
        SizedBox(
          height: 228,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final product = products[index];
              return _HorizontalProductCard(
                product: product,
                isWishlisted: wishlistIds.contains(product.id),
                onTap: () => onProductTap(product),
                onWishlist: () => onToggleWishlist(product.id),
                onAddToCart: () => onAddToCart(product),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Horizontal Product Card ───────────────────────────────────────────────────

class _HorizontalProductCard extends StatelessWidget {
  const _HorizontalProductCard({
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
      child: Container(
        width: 148,
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
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: 148,
                  height: 148,
                  child: ProductImage(
                    imageUrl: product.thumbnailUrl,
                    label: product.name,
                    unavailable: unavailable,
                    borderRadius: 0,
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
                          topLeft: Radius.circular(AppTheme.radiusLg),
                          bottomRight: Radius.circular(AppTheme.radiusSm),
                        ),
                      ),
                      child: Text(
                        '${product.discountPercent}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (unavailable)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.35),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm),
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
                Positioned(
                  top: 6,
                  right: 6,
                  child: _HeartButton(
                    isWishlisted: isWishlisted,
                    onTap: onWishlist,
                  ),
                ),
              ],
            ),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            formatPrice(product.sellingPrice),
                            style: const TextStyle(
                              fontSize: 14,
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

// ── Sort Bar ──────────────────────────────────────────────────────────────────

class _SortBar extends StatelessWidget {
  const _SortBar({
    required this.productCount,
    required this.sortMode,
    required this.onSortTap,
    required this.l10n,
  });

  final int productCount;
  final SortMode sortMode;
  final VoidCallback onSortTap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSortTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        color: Colors.transparent,
        child: Row(
          children: [
            Text(
              '상품 $productCount개',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.sortModeLabel(sortMode),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ProductImage(
                    imageUrl: product.thumbnailUrl,
                    label: product.name,
                    unavailable: unavailable,
                    borderRadius: 0,
                  ),
                ),
                // Discount badge
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
                          topLeft: Radius.circular(AppTheme.radiusLg),
                          bottomRight: Radius.circular(AppTheme.radiusSm),
                        ),
                      ),
                      child: Text(
                        '${product.discountPercent}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                // Sold out overlay
                if (unavailable)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.35),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
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
                // Heart button
                Positioned(
                  top: 6,
                  right: 6,
                  child: _HeartButton(
                    isWishlisted: isWishlisted,
                    onTap: onWishlist,
                  ),
                ),
              ],
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
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
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.discountPercent > 0)
                                Text(
                                  '${product.discountPercent}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              Text(
                                formatPrice(product.sellingPrice),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
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

class _HeartButton extends StatelessWidget {
  const _HeartButton({required this.isWishlisted, required this.onTap});

  final bool isWishlisted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          isWishlisted
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          size: 17,
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
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
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
        childAspectRatio: 0.56,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
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
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.imagePlaceholder,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(width: double.infinity, height: 12, radius: 4),
                  const SizedBox(height: 5),
                  _SkeletonBox(width: 80, height: 12, radius: 4),
                  const Spacer(),
                  _SkeletonBox(width: 64, height: 18, radius: 4),
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
