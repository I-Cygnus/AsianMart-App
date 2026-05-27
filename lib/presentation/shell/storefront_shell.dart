import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/state/app_controller.dart';
import 'package:asian_mart_app/core/state/app_scope.dart';
import 'package:asian_mart_app/domain/entities/product.dart';
import 'package:asian_mart_app/domain/enums/sort_mode.dart';
import 'package:asian_mart_app/presentation/auth/auth_page.dart';
import 'package:asian_mart_app/presentation/cart/cart_tab.dart';
import 'package:asian_mart_app/presentation/checkout/checkout_page.dart';
import 'package:asian_mart_app/presentation/home/home_tab.dart';
import 'package:asian_mart_app/presentation/product_detail/product_detail_page.dart';
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
  String _searchQuery = '';
  SortMode _sortMode = SortMode.latest;

  List<Product> get _filteredProducts {
    final query = _searchQuery.trim().toLowerCase();
    final items = widget.controller.products.where((product) {
      if (query.isEmpty) {
        return true;
      }
      return product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);
    }).toList();

    switch (_sortMode) {
      case SortMode.recommended:
        items.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
      case SortMode.latest:
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SortMode.lowPrice:
        items.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
      case SortMode.highPrice:
        items.sort((a, b) => b.sellingPrice.compareTo(a.sellingPrice));
    }
    return items;
  }

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
          product: product,
          onAddToCart: (quantity) =>
              _handleAddToCart(product, quantity: quantity),
          onBuyNow: (quantity) async {
            await _handleAddToCart(product, quantity: quantity);
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
              products: _filteredProducts,
              isLoading: widget.controller.productsLoading,
              errorMessage: widget.controller.productsError,
              searchQuery: _searchQuery,
              sortMode: _sortMode,
              currentUserName: widget.controller.currentUser?.name,
              isAuthenticated: widget.controller.isAuthenticated,
              wishlistIds: widget.controller.wishlistedProductIds,
              cartCount: widget.controller.cartItemCount,
              onSearchChanged: (value) => setState(() => _searchQuery = value),
              onSortChanged: (mode) => setState(() => _sortMode = mode),
              onRefresh: widget.controller.loadProducts,
              onOpenAuth: _openAuthPage,
              onProfileTap: () => setState(() => _currentIndex = 3),
              onCartTap: () => setState(() => _currentIndex = 1),
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
            WishlistTab(
              isAuthenticated: widget.controller.isAuthenticated,
              isLoading: widget.controller.wishlistLoading,
              errorMessage: widget.controller.wishlistError,
              items: widget.controller.wishlistItems,
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
              onOpenProduct: (productId) {
                final product = widget.controller.findProduct(productId);
                if (product == null) {
                  _showSnack('상품 정보를 찾을 수 없습니다.');
                  return;
                }
                _showProduct(product);
              },
            ),
            ProfileTab(
              isAuthenticated: widget.controller.isAuthenticated,
              user: widget.controller.currentUser,
              addresses: widget.controller.addresses,
              isLoading: widget.controller.profileLoading,
              errorMessage: widget.controller.profileError,
              onRequireLogin: _openAuthPage,
              onRefresh: widget.controller.loadProfile,
              onLogout: widget.controller.logout,
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
              onOpenLanguageSettings: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const LanguageSettingsPage(),
                  ),
                );
              },
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
                  icon: const Icon(Icons.storefront_outlined),
                  selectedIcon: const Icon(Icons.storefront_rounded),
                  label: l10n.navHome,
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
                  icon: const Icon(Icons.favorite_border_rounded),
                  selectedIcon: const Icon(Icons.favorite_rounded),
                  label: l10n.navWishlist,
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
