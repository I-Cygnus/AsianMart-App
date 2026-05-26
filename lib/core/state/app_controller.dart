import 'package:flutter/foundation.dart';
import 'package:asian_mart_app/core/network/api_client.dart';
import 'package:asian_mart_app/core/network/api_exception.dart';
import 'package:asian_mart_app/domain/entities/address.dart';
import 'package:asian_mart_app/domain/entities/app_user.dart';
import 'package:asian_mart_app/domain/entities/cart_entry.dart';
import 'package:asian_mart_app/domain/entities/product.dart';
import 'package:asian_mart_app/domain/entities/wishlist_item.dart';

class AppController extends ChangeNotifier {
  AppController(this._apiClient);

  final ApiClient _apiClient;

  String? _accessToken;
  String? _guestToken;

  bool _bootstrapped = false;
  bool _productsLoading = false;
  bool _cartLoading = false;
  bool _authLoading = false;
  bool _wishlistLoading = false;
  bool _profileLoading = false;

  String? _productsError;
  String? _cartError;
  String? _wishlistError;
  String? _profileError;

  List<Product> _products = const [];
  List<CartEntry> _cartItems = const [];
  List<WishlistItem> _wishlistItems = const [];
  List<Address> _addresses = const [];
  AppUser? _currentUser;

  bool get bootstrapped => _bootstrapped;
  bool get productsLoading => _productsLoading;
  bool get cartLoading => _cartLoading;
  bool get authLoading => _authLoading;
  bool get wishlistLoading => _wishlistLoading;
  bool get profileLoading => _profileLoading;

  String? get productsError => _productsError;
  String? get cartError => _cartError;
  String? get wishlistError => _wishlistError;
  String? get profileError => _profileError;

  List<Product> get products => _products;
  List<CartEntry> get cartItems => _cartItems;
  List<WishlistItem> get wishlistItems => _wishlistItems;
  List<Address> get addresses => _addresses;
  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  Set<int> get wishlistedProductIds =>
      _wishlistItems.map((item) => item.productId).toSet();

  List<CartEntry> get selectedCartItems =>
      _cartItems.where((item) => item.selected).toList();

  int get cartItemCount =>
      _cartItems.fold(0, (total, item) => total + item.quantity);

  double get selectedCartTotal => selectedCartItems.fold(
        0,
        (total, item) => total + item.itemTotalPrice,
      );

  Address? get defaultAddress {
    for (final address in _addresses) {
      if (address.isDefault) {
        return address;
      }
    }
    return _addresses.isEmpty ? null : _addresses.first;
  }

  Product? findProduct(int productId) {
    for (final product in _products) {
      if (product.id == productId) {
        return product;
      }
    }
    return null;
  }

  Future<void> bootstrap() async {
    if (_bootstrapped) {
      return;
    }
    _bootstrapped = true;
    await Future.wait([
      loadProducts(),
      loadCart(),
    ]);
  }

  Future<void> loadProducts() async {
    _productsLoading = true;
    _productsError = null;
    notifyListeners();
    try {
      _products = await _apiClient.fetchProducts();
    } catch (error) {
      _productsError = _messageOf(error);
    } finally {
      _productsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCart() async {
    _cartLoading = true;
    _cartError = null;
    notifyListeners();
    try {
      final snapshot = await _apiClient.fetchCart(
        accessToken: _accessToken,
        guestToken: isAuthenticated ? null : _guestToken,
      );
      _cartItems = snapshot.items;
      if (!isAuthenticated && snapshot.guestToken != null) {
        _guestToken = snapshot.guestToken;
      }
    } catch (error) {
      _cartError = _messageOf(error);
    } finally {
      _cartLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWishlist() async {
    if (!isAuthenticated) {
      _wishlistItems = const [];
      _wishlistError = null;
      notifyListeners();
      return;
    }

    _wishlistLoading = true;
    _wishlistError = null;
    notifyListeners();
    try {
      _wishlistItems = await _apiClient.fetchWishlist(_accessToken!);
    } catch (error) {
      _wishlistError = _messageOf(error);
    } finally {
      _wishlistLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProfile() async {
    if (!isAuthenticated) {
      _currentUser = null;
      _addresses = const [];
      _profileError = null;
      notifyListeners();
      return;
    }

    _profileLoading = true;
    _profileError = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _apiClient.fetchMe(_accessToken!),
        _apiClient.fetchAddresses(_accessToken!),
      ]);
      _currentUser = results[0] as AppUser;
      _addresses = results[1] as List<Address>;
    } catch (error) {
      _profileError = _messageOf(error);
    } finally {
      _profileLoading = false;
      notifyListeners();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _authLoading = true;
    notifyListeners();
    try {
      _accessToken = await _apiClient.login(email: email, password: password);
      await Future.wait([
        loadCart(),
        loadWishlist(),
        loadProfile(),
      ]);
      return null;
    } catch (error) {
      return _messageOf(error);
    } finally {
      _authLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signup({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    _authLoading = true;
    notifyListeners();
    try {
      await _apiClient.signup(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      _accessToken = await _apiClient.login(email: email, password: password);
      await Future.wait([
        loadCart(),
        loadWishlist(),
        loadProfile(),
      ]);
      return null;
    } catch (error) {
      return _messageOf(error);
    } finally {
      _authLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final token = _accessToken;
    _accessToken = null;
    _wishlistItems = const [];
    _addresses = const [];
    _currentUser = null;
    notifyListeners();
    if (token != null && token.isNotEmpty) {
      try {
        await _apiClient.logout(token);
      } catch (_) {}
    }
    await loadCart();
  }

  Future<String?> addToCart({
    required int productId,
    int quantity = 1,
  }) async {
    try {
      final snapshot = await _apiClient.addCartItem(
        productId: productId,
        quantity: quantity,
        accessToken: _accessToken,
        guestToken: isAuthenticated ? null : _guestToken,
      );
      _cartItems = snapshot.items;
      if (!isAuthenticated && snapshot.guestToken != null) {
        _guestToken = snapshot.guestToken;
      }
      notifyListeners();
      return null;
    } catch (error) {
      return _messageOf(error);
    }
  }

  Future<String?> updateCartQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      if (quantity < 1) {
        return deleteCartItem(cartItemId: cartItemId);
      }
      final snapshot = await _apiClient.updateCartQuantity(
        cartItemId: cartItemId,
        quantity: quantity,
        accessToken: _accessToken,
        guestToken: isAuthenticated ? null : _guestToken,
      );
      _cartItems = snapshot.items;
      notifyListeners();
      return null;
    } catch (error) {
      return _messageOf(error);
    }
  }

  Future<String?> updateCartSelected({
    required int cartItemId,
    required bool selected,
  }) async {
    try {
      final snapshot = await _apiClient.updateCartSelected(
        cartItemId: cartItemId,
        selected: selected,
        accessToken: _accessToken,
        guestToken: isAuthenticated ? null : _guestToken,
      );
      _cartItems = snapshot.items;
      notifyListeners();
      return null;
    } catch (error) {
      return _messageOf(error);
    }
  }

  Future<String?> deleteCartItem({
    required int cartItemId,
  }) async {
    try {
      final snapshot = await _apiClient.deleteCartItem(
        cartItemId: cartItemId,
        accessToken: _accessToken,
        guestToken: isAuthenticated ? null : _guestToken,
      );
      _cartItems = snapshot.items;
      notifyListeners();
      return null;
    } catch (error) {
      return _messageOf(error);
    }
  }

  Future<String?> toggleWishlist(int productId) async {
    if (!isAuthenticated) {
      return '로그인이 필요합니다.';
    }
    try {
      await _apiClient.toggleWishlist(
        accessToken: _accessToken!,
        productId: productId,
      );
      await loadWishlist();
      return null;
    } catch (error) {
      return _messageOf(error);
    }
  }

  Future<String?> addAddress({
    required String addressName,
    required String zipCode,
    required String address1,
    required String address2,
    required bool isDefault,
  }) async {
    if (!isAuthenticated) {
      return '로그인이 필요합니다.';
    }
    try {
      await _apiClient.addAddress(
        accessToken: _accessToken!,
        addressName: addressName,
        zipCode: zipCode,
        address1: address1,
        address2: address2,
        isDefault: isDefault,
      );
      await loadProfile();
      return null;
    } catch (error) {
      return _messageOf(error);
    }
  }

  Future<String?> deleteAddress(int addressId) async {
    if (!isAuthenticated) {
      return '로그인이 필요합니다.';
    }
    try {
      await _apiClient.deleteAddress(
        accessToken: _accessToken!,
        addressId: addressId,
      );
      await loadProfile();
      return null;
    } catch (error) {
      return _messageOf(error);
    }
  }

  Future<String?> setDefaultAddress(int addressId) async {
    if (!isAuthenticated) {
      return '로그인이 필요합니다.';
    }
    try {
      await _apiClient.setDefaultAddress(
        accessToken: _accessToken!,
        addressId: addressId,
      );
      await loadProfile();
      return null;
    } catch (error) {
      return _messageOf(error);
    }
  }

  Future<String?> placeOrder({required String requestMessage}) async {
    if (!isAuthenticated || _currentUser == null) {
      return '로그인이 필요합니다.';
    }
    if (selectedCartItems.isEmpty) {
      return '선택된 상품이 없습니다.';
    }
    if (defaultAddress == null) {
      return '기본 배송지를 먼저 등록해 주세요.';
    }

    final totalAmount = selectedCartTotal.round();

    try {
      await _apiClient.placeOrder(
        accessToken: _accessToken!,
        userId: _currentUser!.id,
        requestMessage: requestMessage.trim(),
        totalAmount: totalAmount,
        products: selectedCartItems
            .map((item) => {
                  'productId': item.productId,
                  'productQuantity': item.quantity,
                })
            .toList(),
      );
      final snapshot = await _apiClient.deleteSelectedCartItems(
        accessToken: _accessToken,
        guestToken: isAuthenticated ? null : _guestToken,
      );
      _cartItems = snapshot.items;
      notifyListeners();
      return null;
    } catch (error) {
      return _messageOf(error);
    }
  }

  String _messageOf(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return '요청 처리 중 문제가 발생했습니다.';
  }
}
