import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/state/app_controller.dart';
import 'package:asian_mart_app/core/state/app_scope.dart';
import 'package:asian_mart_app/domain/entities/product.dart';
import 'package:asian_mart_app/presentation/auth/auth_page.dart';
import 'package:asian_mart_app/presentation/cart/cart_tab.dart';
import 'package:asian_mart_app/presentation/checkout/checkout_page.dart';
import 'package:asian_mart_app/presentation/home/home_tab.dart';
import 'package:asian_mart_app/presentation/product_detail/product_detail_page.dart';
import 'package:asian_mart_app/presentation/product_list/product_list_page.dart';
import 'package:asian_mart_app/presentation/profile/address_manage_page.dart';
import 'package:asian_mart_app/presentation/profile/profile_tab.dart';
import 'package:asian_mart_app/presentation/settings/language_settings_page.dart';
import 'package:asian_mart_app/presentation/wishlist/wishlist_tab.dart';

class StorefrontShell extends StatefulWidget {
  const StorefrontShell({super.key, required this.controller});

  final AppController controller;

  @override
  State<StorefrontShell> createState() => _StorefrontShellState();
}

class _StorefrontShellState extends State<StorefrontShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.bootstrap();
  }

  Future<void> _openAuthPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AuthPage(controller: widget.controller),
      ),
    );
  }

  Future<void> _openCheckout() async {
    if (!widget.controller.isAuthenticated) {
      await _openAuthPage();
      return;
    }
    if (widget.controller.selectedCartItems.isEmpty) {
      _showSnack('주문할 상품을 먼저 선택해 주세요.');
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CheckoutPage(controller: widget.controller),
      ),
    );
  }

  Future<void> _handleWishlistToggle(int productId) async {
    if (!widget.controller.isAuthenticated) {
      await _openAuthPage();
      return;
    }
    final error = await widget.controller.toggleWishlist(productId);
    if (error != null && mounted) {
      _showSnack(error);
    }
  }

  Future<void> _handleAddToCart(Product product, {int quantity = 1}) async {
    final error = await widget.controller.addToCart(
      productId: product.id,
      quantity: quantity,
    );
    if (!mounted) {
      return;
    }
    if (error != null) {
      _showSnack(error);
      return;
    }
    final l10n = AppLocalizations.of(context);
    _showSnack(l10n.addedToCart(product.name, quantity));
  }

  void _showProduct(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailPage(
          initialProduct: product,
          onLoadDetail: () =>
              widget.controller.loadProductDetail(product.id),
          onAddToCart: (detailProduct, quantity) =>
              _handleAddToCart(detailProduct, quantity: quantity),
          onBuyNow: (detailProduct, quantity) async {
            await _handleAddToCart(detailProduct, quantity: quantity);
            if (!mounted) {
              return;
            }
            await _openCheckout();
          },
          onToggleWishlist: () => _handleWishlistToggle(product.id),
          isWishlisted:
              widget.controller.wishlistedProductIds.contains(product.id),
          onRequireLogin: _openAuthPage,
          isAuthenticated: widget.controller.isAuthenticated,
        ),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openAddressManage() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AnimatedBuilder(
          animation: widget.controller,
          builder: (context, __) => AddressManagePage(
            addresses: widget.controller.addresses,
            isLoading: widget.controller.profileLoading,
            errorMessage: widget.controller.profileError,
            onRefresh: widget.controller.loadProfile,
            onAddAddress: ({
              required addressName,
              required zipCode,
              required address1,
              required address2,
              required isDefault,
            }) {
              return widget.controller.addAddress(
                addressName: addressName,
                zipCode: zipCode,
                address1: address1,
                address2: address2,
                isDefault: isDefault,
              );
            },
            onSetDefault: (addressId) async {
              final error =
                  await widget.controller.setDefaultAddress(addressId);
              if (error != null && mounted) {
                _showSnack(error);
              }
            },
            onDeleteAddress: (addressId) async {
              final error = await widget.controller.deleteAddress(addressId);
              if (error != null && mounted) {
                _showSnack(error);
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openWishlist() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (routeContext) => AnimatedBuilder(
          animation: widget.controller,
          builder: (context, __) => WishlistTab(
            isAuthenticated: widget.controller.isAuthenticated,
            isLoading: widget.controller.wishlistLoading,
            isLoadingMore: widget.controller.wishlistLoadingMore,
            hasMore: widget.controller.wishlisthasMore,
            errorMessage: widget.controller.wishlistError,
            items: widget.controller.wishlistItems,
            totalCount: widget.controller.wishlistTotalCount,
            onRequireLogin: _openAuthPage,
            onRefresh: widget.controller.loadWishlist,
            onRemove: (productId) => _handleWishlistToggle(productId),
            onAddToCart: (productId) async {
              final product = widget.controller.findProduct(productId);
              if (product == null) {
                _showSnack('상품 정보를 찾을 수 없습니다.');
                return;
              }
              await _handleAddToCart(product);
            },
            onOpenProduct: (productId) async {
              final cached = widget.controller.findProduct(productId);
              if (cached != null) {
                _showProduct(cached);
                return;
              }
              try {
                final detail =
                    await widget.controller.loadProductDetail(productId);
                if (!mounted) return;
                _showProduct(detail);
              } catch (_) {
                _showSnack('상품 정보를 찾을 수 없습니다.');
              }
            },
            onLoadMore: widget.controller.loadMoreWishlists,
            onBack: () => Navigator.of(routeContext).pop(),
          ),
        ),
      ),
    );
  }

  void _openOrderInquiry() {
    final l10n = AppLocalizations.of(context);
    _showSnack(l10n.comingSoon);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScope(
      controller: widget.controller,
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final pages = <Widget>[
            HomeTab(
              recommendedProducts: widget.controller.recommendedProducts,
              popularProducts: widget.controller.popularProducts,
              isHomeSectionsLoading: widget.controller.homeSectionsLoading,
              homeSectionsError: widget.controller.homeSectionsError,
              currentUserName: widget.controller.currentUser?.name,
              isAuthenticated: widget.controller.isAuthenticated,
              wishlistIds: widget.controller.wishlistedProductIds,
              cartCount: widget.controller.cartItemCount,
              onSearch: (keyword) async {
                await widget.controller.applyProductFilters(
                  keyword: keyword,
                  sort: widget.controller.listSort,
                );
                if (mounted) {
                  setState(() => _currentIndex = 1);
                }
              },
              onRefresh: () async {
                await Future.wait([
                  widget.controller.loadProducts(),
                  widget.controller.loadHomeSections(),
                ]);
              },
              onOpenAuth: _openAuthPage,
              onProfileTap: () => setState(() => _currentIndex = 3),
              onCartTap: () => setState(() => _currentIndex = 2),
              onOpenLanguageSettings: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const LanguageSettingsPage(),
                  ),
                );
              },
              onProductTap: _showProduct,
              onToggleWishlist: _handleWishlistToggle,
              onAddToCart: _handleAddToCart,
              rootCategories: widget.controller.categoryLevels.isNotEmpty
                  ? widget.controller.categoryLevels.first
                  : const [],
              onCategoryTap: (category) async {
                await widget.controller.selectCategoryAtDepth(
                  depth: 0,
                  categoryId: category.id,
                );
                if (mounted) {
                  setState(() => _currentIndex = 1);
                }
              },
            ),
            ProductListPage(
              products: widget.controller.listProducts,
              isLoading: widget.controller.listLoading,
              isLoadingMore: widget.controller.listLoadingMore,
              hasMore: widget.controller.listHasMore,
              totalCount: widget.controller.listTotalCount,
              errorMessage: widget.controller.listError,
              categoryLevels: widget.controller.categoryLevels,
              categoryPath: widget.controller.categoryPath,
              loadingChildOf: widget.controller.loadingChildOf,
              searchQuery: widget.controller.listKeyword,
              sortMode: widget.controller.listSort,
              wishlistIds: widget.controller.wishlistedProductIds,
              onRefresh: widget.controller.refreshProductList,
              onSearch: (keyword) => widget.controller.applyProductFilters(
                keyword: keyword,
                sort: widget.controller.listSort,
              ),
              onSelectCategoryAtDepth: (depth, categoryId) =>
                  widget.controller.selectCategoryAtDepth(
                depth: depth,
                categoryId: categoryId,
              ),
              onSortChanged: (mode) => widget.controller.applyProductFilters(
                keyword: widget.controller.listKeyword,
                sort: mode,
              ),
              onLoadMore: widget.controller.loadMoreProducts,
              onProductTap: _showProduct,
              onToggleWishlist: _handleWishlistToggle,
              onAddToCart: _handleAddToCart,
            ),
            CartTab(
              isAuthenticated: widget.controller.isAuthenticated,
              items: widget.controller.cartItems,
              isLoading: widget.controller.cartLoading,
              errorMessage: widget.controller.cartError,
              total: widget.controller.selectedCartTotal,
              onRequireLogin: _openAuthPage,
              onRefresh: widget.controller.loadCart,
              onDelete: (cartItemId) async {
                final error = await widget.controller
                    .deleteCartItem(cartItemId: cartItemId);
                if (error != null && mounted) {
                  _showSnack(error);
                }
              },
              onQuantityChanged: (cartItemId, quantity) async {
                final error = await widget.controller.updateCartQuantity(
                  cartItemId: cartItemId,
                  quantity: quantity,
                );
                if (error != null && mounted) {
                  _showSnack(error);
                }
              },
              onSelectedChanged: (cartItemId, selected) async {
                final error = await widget.controller.updateCartSelected(
                  cartItemId: cartItemId,
                  selected: selected,
                );
                if (error != null && mounted) {
                  _showSnack(error);
                }
              },
              onGoShopping: () => setState(() => _currentIndex = 0),
              onCheckout: _openCheckout,
              onSelectAll: (selectAll) async {
                final targets = widget.controller.cartItems
                    .where((i) => i.selected != selectAll);
                await Future.wait(
                  targets.map(
                    (i) => widget.controller.updateCartSelected(
                      cartItemId: i.cartItemId,
                      selected: selectAll,
                    ),
                  ),
                );
              },
            ),
            ProfileTab(
              isAuthenticated: widget.controller.isAuthenticated,
              user: widget.controller.currentUser,
              onRequireLogin: _openAuthPage,
              onRefresh: widget.controller.loadProfile,
              onLogout: widget.controller.logout,
              onOpenAddressManage: _openAddressManage,
              onOpenWishlist: _openWishlist,
              onOpenCart: () => setState(() => _currentIndex = 2),
              onOpenOrderInquiry: _openOrderInquiry,
            ),
          ];

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            child: Scaffold(
              body: SafeArea(top: false, child: pages[_currentIndex]),
              bottomNavigationBar: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded),
                  label: l10n.navHome,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.storefront_outlined),
                  selectedIcon: const Icon(Icons.storefront_rounded),
                  label: l10n.navProducts,
                ),
                NavigationDestination(
                  icon: Badge.count(
                    count: widget.controller.cartItemCount,
                    isLabelVisible: widget.controller.cartItemCount > 0,
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                  selectedIcon: Badge.count(
                    count: widget.controller.cartItemCount,
                    isLabelVisible: widget.controller.cartItemCount > 0,
                    child: const Icon(Icons.shopping_bag_rounded),
                  ),
                  label: l10n.navCart,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline_rounded),
                  selectedIcon: const Icon(Icons.person_rounded),
                  label: l10n.navProfile,
                ),
              ],
            ),
            ),
          );
        },
      ),
    );
  }
}
