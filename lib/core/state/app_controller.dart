import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:asian_mart_app/core/network/api_client.dart';
import 'package:asian_mart_app/core/network/api_exception.dart';
import 'package:asian_mart_app/domain/entities/address.dart';
import 'package:asian_mart_app/domain/entities/admin_order.dart';
import 'package:asian_mart_app/domain/entities/app_user.dart';
import 'package:asian_mart_app/domain/entities/cart_entry.dart';
import 'package:asian_mart_app/domain/entities/delivery.dart';
import 'package:asian_mart_app/domain/entities/order_detail.dart';
import 'package:asian_mart_app/domain/entities/order_history_item.dart';
import 'package:asian_mart_app/domain/entities/product.dart';
import 'package:asian_mart_app/domain/entities/wishlist_item.dart';

class AppController extends ChangeNotifier {
  AppController(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  static const _tokenKey = 'access_token';
  static const _rolesKey = 'user_roles';

  static const deliverRole = 'DELIEVER'; // 백엔드 Role enum 철자 그대로
  static const adminRole = 'ADMIN'; // 루트 관리자 (백엔드 Role enum)

  String? _accessToken;
  String? _guestToken;
  String? _fcmToken; // 현재 기기의 FCM 토큰 (main에서 주입)
  List<String> _userRoles = const [];

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
  List<Delivery> _deliveries = const [];
  bool _deliveriesLoading = false;
  String? _deliveriesError;
  List<AdminOrder> _adminOrders = const [];
  bool _adminOrdersLoading = false;
  String? _adminOrdersError;
  List<OrderHistoryItem> _orders = const [];
  bool _ordersLoading = false;
  String? _ordersError;
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

  List<String> get userRoles => _userRoles;
  bool get isDeliver => _userRoles.contains(deliverRole);
  bool get isAdmin => _userRoles.contains(adminRole);

  List<Delivery> get deliveries => _deliveries;
  bool get deliveriesLoading => _deliveriesLoading;
  String? get deliveriesError => _deliveriesError;

  List<AdminOrder> get adminOrders => _adminOrders;
  bool get adminOrdersLoading => _adminOrdersLoading;
  String? get adminOrdersError => _adminOrdersError;

  List<OrderHistoryItem> get orders => _orders;
  bool get ordersLoading => _ordersLoading;
  String? get ordersError => _ordersError;

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

    final savedToken = await _storage.read(key: _tokenKey);
    if (savedToken != null && savedToken.isNotEmpty) {
      _accessToken = savedToken;
    }
    final savedRoles = await _storage.read(key: _rolesKey);
    if (savedRoles != null && savedRoles.isNotEmpty) {
      _userRoles = savedRoles.split(',');
    }

    if (isAuthenticated) {
      unawaited(_registerFcmToken());
    }

    // 루트 관리자 계정은 스토어 데이터 대신 입금 확인 대기 목록만 로드한다.
    if (isAuthenticated && isAdmin) {
      await Future.wait([loadProfile(), loadAdminOrders()]);
      return;
    }

    // 배송 기사 계정은 스토어 데이터 대신 배송 목록만 로드한다.
    if (isAuthenticated && isDeliver) {
      await Future.wait([loadProfile(), loadDeliveries()]);
      return;
    }

    await Future.wait([
      loadProducts(),
      loadCart(),
    ]);

    if (isAuthenticated) {
      await Future.wait([loadWishlist(), loadProfile()]);
    }
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
      if (error is ApiException && error.statusCode == 401) {
        await _clearPersistedToken();
        return;
      }
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
      if (error is ApiException && error.statusCode == 401) {
        await _clearPersistedToken();
        return;
      }
      _profileError = _messageOf(error);
    } finally {
      _profileLoading = false;
      notifyListeners();
    }
  }

  Future<void> _clearPersistedToken() async {
    _accessToken = null;
    _userRoles = const [];
    _deliveries = const [];
    _adminOrders = const [];
    _orders = const [];
    _wishlistItems = const [];
    _addresses = const [];
    _currentUser = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _rolesKey);
    notifyListeners();
  }

  // ── 배송 (배송 기사) ──────────────────────────────────────────────────────
  Future<void> loadDeliveries() async {
    if (!isAuthenticated) {
      return;
    }
    _deliveriesLoading = true;
    _deliveriesError = null;
    notifyListeners();
    try {
      _deliveries = await _apiClient.fetchDeliveries(_accessToken!);
    } catch (error) {
      _deliveriesError = _messageOf(error);
    } finally {
      _deliveriesLoading = false;
      notifyListeners();
    }
  }

  /// 배송 접수: 확정 주문을 배송 접수해 배송(ACCEPTED)을 생성. 성공 시 목록 갱신.
  Future<String?> acceptDelivery({required int orderId}) async {
    if (!isAuthenticated) {
      return '로그인이 필요합니다.';
    }
    try {
      await _apiClient.registerDelivery(
        accessToken: _accessToken!,
        orderId: orderId,
      );
      await loadDeliveries();
      return null;
    } catch (error) {
      return _messageOf(error);
    }
  }

  /// 배송 상태 전이. [action]은 prepare | ship | complete. 성공 시 목록 갱신.
  Future<String?> advanceDelivery({
    required int deliveryId,
    required String action,
  }) async {
    if (!isAuthenticated) {
      return '로그인이 필요합니다.';
    }
    try {
      await _apiClient.advanceDelivery(
        accessToken: _accessToken!,
        deliveryId: deliveryId,
        action: action,
      );
      await loadDeliveries();
      return null;
    } catch (error) {
      return _messageOf(error);
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _authLoading = true;
    notifyListeners();
    try {
      final guestCartItems = _snapshotGuestCartItems();
      final result = await _apiClient.login(email: email, password: password);
      await _applyLoginResult(result);

      // 루트 관리자 계정: 스토어/장바구니 대신 입금 확인 대기 목록 로드.
      if (isAdmin) {
        await Future.wait([loadProfile(), loadAdminOrders()]);
        return null;
      }

      // 배송 기사 계정: 스토어/장바구니 대신 배송 목록 로드.
      if (isDeliver) {
        await Future.wait([loadProfile(), loadDeliveries()]);
        return null;
      }

      final mergeFailures = await _mergeGuestCartIntoMemberCart(guestCartItems);
      await Future.wait([
        loadCart(),
        loadWishlist(),
        loadProfile(),
      ]);
      if (mergeFailures.isNotEmpty) {
        _cartError = '일부 게스트 장바구니 상품을 회원 장바구니로 옮기지 못했습니다.';
      }
      return null;
    } catch (error) {
      return _messageOf(error);
    } finally {
      _authLoading = false;
      notifyListeners();
    }
  }

  Future<void> _applyLoginResult(
    ({String accessToken, List<String> roles}) result,
  ) async {
    _accessToken = result.accessToken;
    _userRoles = result.roles;
    await _storage.write(key: _tokenKey, value: _accessToken);
    await _storage.write(key: _rolesKey, value: _userRoles.join(','));
    unawaited(_registerFcmToken());
  }

  // ── FCM 기기 토큰 ─────────────────────────────────────────────────────────
  /// main에서 발급받은 FCM 토큰을 주입. 로그인 상태면 즉시 서버에 등록한다.
  void setFcmToken(String token) {
    if (token.isEmpty || _fcmToken == token) {
      return;
    }
    _fcmToken = token;
    unawaited(_registerFcmToken());
  }

  /// 현재 FCM 토큰을 로그인 사용자 기준으로 서버에 등록(베스트 에포트).
  Future<void> _registerFcmToken() async {
    final fcm = _fcmToken;
    if (fcm == null || fcm.isEmpty || !isAuthenticated) {
      return;
    }
    try {
      await _apiClient.registerDeviceToken(
        accessToken: _accessToken!,
        token: fcm,
      );
    } catch (_) {
      // 등록 실패는 무시(다음 로그인/토큰 갱신 때 재시도).
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
      final guestCartItems = _snapshotGuestCartItems();
      await _apiClient.signup(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      final result = await _apiClient.login(email: email, password: password);
      await _applyLoginResult(result);
      final mergeFailures = await _mergeGuestCartIntoMemberCart(guestCartItems);
      await Future.wait([
        loadCart(),
        loadWishlist(),
        loadProfile(),
      ]);
      if (mergeFailures.isNotEmpty) {
        _cartError = '일부 게스트 장바구니 상품을 회원 장바구니로 옮기지 못했습니다.';
      }
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
    final fcm = _fcmToken;
    // 이 기기로의 알림이 가지 않도록 토큰 제거(베스트 에포트).
    if (token != null && token.isNotEmpty && fcm != null && fcm.isNotEmpty) {
      try {
        await _apiClient.deleteDeviceToken(accessToken: token, token: fcm);
      } catch (_) {}
    }
    _accessToken = null;
    _guestToken = null;
    _userRoles = const [];
    _deliveries = const [];
    _adminOrders = const [];
    _orders = const [];
    _wishlistItems = const [];
    _addresses = const [];
    _currentUser = null;
    notifyListeners();
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _rolesKey);
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

  /// 주문 생성. 결제 페이지에서 "주문하기"를 눌렀을 때만 호출된다.
  ///
  /// - [products]: `[{productId, productQuantity}]` 형태. 장바구니 주문이면 선택 항목,
  ///   바로구매면 단일 상품.
  /// - 배송 정보(이름/연락처/주소)는 저장된 배송지 또는 사용자가 결제 페이지에서
  ///   직접 입력한 값을 그대로 전달받는다. (저장된 배송지가 없어도 주문 가능)
  /// - [clearSelectedCart]가 true이면(=장바구니 주문) 성공 후 선택 항목을 비운다.
  ///
  /// 성공 시 생성된 주문 id를 [orderId]로 돌려준다(무통장 입금 안내 → 결제 완료에 사용).
  Future<({int? orderId, String? error})> placeOrder({
    required String requestMessage,
    required String recipientName,
    required String recipientPhone,
    required String recipientAddress,
    required List<Map<String, int>> products,
    required double totalAmount,
    bool clearSelectedCart = false,
  }) async {
    if (!isAuthenticated || _currentUser == null) {
      return (orderId: null, error: '로그인이 필요합니다.');
    }
    if (products.isEmpty) {
      return (orderId: null, error: '주문할 상품이 없습니다.');
    }
    if (recipientName.trim().isEmpty ||
        recipientPhone.trim().isEmpty ||
        recipientAddress.trim().isEmpty) {
      return (orderId: null, error: '배송 정보를 모두 입력해 주세요.');
    }

    try {
      final orderId = await _apiClient.placeOrder(
        accessToken: _accessToken!,
        requestMessage: requestMessage.trim(),
        totalAmount: _normalizeCurrency(totalAmount),
        recipientName: recipientName.trim(),
        recipientPhone: recipientPhone.trim(),
        recipientAddress: recipientAddress.trim(),
        products: products,
      );
      if (clearSelectedCart) {
        final snapshot = await _apiClient.deleteSelectedCartItems(
          accessToken: _accessToken,
          guestToken: isAuthenticated ? null : _guestToken,
        );
        _cartItems = snapshot.items;
        notifyListeners();
      }
      return (orderId: orderId, error: null);
    } catch (error) {
      return (orderId: null, error: _messageOf(error));
    }
  }

  /// 고객 무통장 입금 통보: "입금 완료" → 입금 확인 대기(PAYMENT_PENDING).
  /// 실제 입금 확인/주문 확정은 루트 관리자가 처리한다.
  Future<String?> reportPayment(int orderId) async {
    if (!isAuthenticated) {
      return '로그인이 필요합니다.';
    }
    try {
      await _apiClient.reportPayment(
        accessToken: _accessToken!,
        orderId: orderId,
      );
      return null;
    } catch (error) {
      return _messageOf(error);
    }
  }

  // ── 내 주문 내역 ───────────────────────────────────────────────────────────
  /// 내 주문 내역 목록 로드.
  Future<void> loadOrders() async {
    if (!isAuthenticated) {
      _orders = const [];
      _ordersError = null;
      notifyListeners();
      return;
    }
    _ordersLoading = true;
    _ordersError = null;
    notifyListeners();
    try {
      _orders = await _apiClient.fetchOrders(_accessToken!);
    } catch (error) {
      if (error is ApiException && error.statusCode == 401) {
        await _clearPersistedToken();
        return;
      }
      _ordersError = _messageOf(error);
    } finally {
      _ordersLoading = false;
      notifyListeners();
    }
  }

  /// 주문 상세 단건 조회. 상세 페이지에서 직접 호출한다(상태는 페이지가 관리).
  Future<({OrderDetail? detail, String? error})> loadOrderDetail(
      int orderId) async {
    if (!isAuthenticated) {
      return (detail: null, error: '로그인이 필요합니다.');
    }
    try {
      final detail = await _apiClient.fetchOrderDetail(
        accessToken: _accessToken!,
        orderId: orderId,
      );
      return (detail: detail, error: null);
    } catch (error) {
      return (detail: null, error: _messageOf(error));
    }
  }

  // ── 루트 관리자 (입금 확인) ────────────────────────────────────────────────
  /// 관리자 주문 상세 로드 (배송지 + 상품 목록).
  Future<({OrderDetail? detail, String? error})> loadAdminOrderDetail(
      int orderId) async {
    if (!isAuthenticated) {
      return (detail: null, error: '로그인이 필요합니다.');
    }
    try {
      final detail = await _apiClient.fetchAdminOrderDetail(
        accessToken: _accessToken!,
        orderId: orderId,
      );
      return (detail: detail, error: null);
    } catch (error) {
      return (detail: null, error: _messageOf(error));
    }
  }

  /// 입금 확인 대기(PAYMENT_PENDING) 주문 목록 로드.
  Future<void> loadAdminOrders() async {
    if (!isAuthenticated) {
      return;
    }
    _adminOrdersLoading = true;
    _adminOrdersError = null;
    notifyListeners();
    try {
      _adminOrders = await _apiClient.fetchAdminOrderRequests(_accessToken!);
    } catch (error) {
      _adminOrdersError = _messageOf(error);
    } finally {
      _adminOrdersLoading = false;
      notifyListeners();
    }
  }

  /// 관리자 입금 확인: 주문(PAYMENT_PENDING) → 확정(CONFIRMED). 성공 시 목록 갱신.
  Future<String?> confirmDeposit(int orderId) async {
    if (!isAuthenticated) {
      return '로그인이 필요합니다.';
    }
    try {
      await _apiClient.confirmOrder(
        accessToken: _accessToken!,
        orderId: orderId,
      );
      await loadAdminOrders();
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

  List<CartEntry> _snapshotGuestCartItems() {
    if (_guestToken == null || _guestToken!.isEmpty || isAuthenticated) {
      return const [];
    }
    return List<CartEntry>.from(_cartItems);
  }

  Future<List<int>> _mergeGuestCartIntoMemberCart(List<CartEntry> guestCartItems) async {
    if (guestCartItems.isEmpty || !isAuthenticated) {
      _guestToken = null;
      return const [];
    }

    final failedProductIds = <int>[];
    for (final item in guestCartItems) {
      try {
        await _apiClient.addCartItem(
          productId: item.productId,
          quantity: item.quantity,
          accessToken: _accessToken,
        );
      } catch (_) {
        failedProductIds.add(item.productId);
      }
    }

    _guestToken = null;
    return failedProductIds;
  }

  double _normalizeCurrency(double value) {
    return double.parse(value.toStringAsFixed(2));
  }
}
