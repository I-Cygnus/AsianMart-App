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
import 'package:asian_mart_app/domain/entities/product_category.dart';
import 'package:asian_mart_app/domain/entities/wishlist_item.dart';
import 'package:asian_mart_app/domain/enums/sort_mode.dart';

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

  String _languageCode = 'KO';
  String get languageCode => _languageCode;

  static const int _listPageSize = 20;
  static const int _wishlistPageSize = 10;

  bool _bootstrapped = false;
  bool _productsLoading = false;
  bool _cartLoading = false;
  bool _authLoading = false;

  bool _profileLoading = false;

  String? _productsError;
  String? _homeSectionsError;
  String? _cartError;
  String? _profileError;

  List<Product> _products = const [];
  List<Product> _recommendedProducts = const [];
  List<Product> _popularProducts = const [];
  bool _homeSectionsLoading = false;
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

  // ── '상품' 탭(서버 주도 검색/필터/정렬/페이지네이션) 상태 ──────────────────
  List<ProductCategory> _categories = const [];
  List<int> _categoryPath = const [];
  List<List<ProductCategory>> _categoryLevels = const [];
  final Map<int, List<ProductCategory>> _childCategoryCache = {};
  int? _loadingChildOf;
  List<Product> _listProducts = const [];
  bool _listLoading = false;
  bool _listLoadingMore = false;
  String? _listError;
  int _listPage = 0;
  bool _listHasMore = true;
  int _listTotalCount = 0;
  int? _listCategoryId;
  String _listKeyword = '';
  SortMode _listSort = SortMode.latest;

  bool _wishlistLoading = false;
  bool _wishlistLoadingMore = false;
  String? _wishlistError;
  int _wishlistPage = 0;
  bool _wishlistHasMore = true;
  int _wishlistTotalCount = 0;

  bool get bootstrapped => _bootstrapped;
  bool get productsLoading => _productsLoading;
  bool get cartLoading => _cartLoading;
  bool get authLoading => _authLoading;
  bool get profileLoading => _profileLoading;

  String? get productsError => _productsError;
  String? get homeSectionsError => _homeSectionsError;
  bool get homeSectionsLoading => _homeSectionsLoading;
  List<Product> get recommendedProducts => _recommendedProducts;
  List<Product> get popularProducts => _popularProducts;
  String? get cartError => _cartError;
  String? get profileError => _profileError;

  List<Product> get products => _products;
  List<ProductCategory> get categories => _categories;
  List<int> get categoryPath => _categoryPath;
  List<List<ProductCategory>> get categoryLevels => _categoryLevels;
  int? get loadingChildOf => _loadingChildOf;
  List<Product> get listProducts => _listProducts;
  bool get listLoading => _listLoading;
  bool get listLoadingMore => _listLoadingMore;
  String? get listError => _listError;
  bool get listHasMore => _listHasMore;
  int get listTotalCount => _listTotalCount;
  int? get listCategoryId => _listCategoryId;
  String get listKeyword => _listKeyword;
  SortMode get listSort => _listSort;
  List<CartEntry> get cartItems => _cartItems;
  List<WishlistItem> get wishlistItems => _wishlistItems;
  bool get wishlistLoading => _wishlistLoading;
  bool get wishlistLoadingMore => _wishlistLoadingMore;
  bool get wishlisthasMore => _wishlistHasMore;
  int get wishlistTotalCount => _wishlistTotalCount;
  String? get wishlistError => _wishlistError;
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
    for (final product in [
      ..._products,
      ..._recommendedProducts,
      ..._popularProducts,
      ..._listProducts,
    ]) {
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
      loadHomeSections(),
      loadCategories(),
      refreshProductList(),
      loadCart(),
    ]);

    if (isAuthenticated) {
      await Future.wait([loadWishlist(), loadProfile()]);
    }
  }

  Future<void> setLanguageCode(String code) async {
    if (_languageCode == code) return;
    _languageCode = code;
    await Future.wait([
      loadProducts(),
      loadHomeSections(),
      refreshProductList(),
      loadWishlist()
    ]);
  }

  Future<void> loadHomeSections() async {
    _homeSectionsLoading = true;
    _homeSectionsError = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _apiClient.fetchRecommendedProducts(languageCode: languageCode),
        _apiClient.fetchPopularProducts(languageCode: languageCode),
      ]);
      _recommendedProducts = results[0];
      _popularProducts = results[1];
    } catch (error) {
      _homeSectionsError = _messageOf(error);
    } finally {
      _homeSectionsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts() async {
    _productsLoading = true;
    _productsError = null;
    notifyListeners();
    try {
      final result = await _apiClient.fetchProducts(languageCode: languageCode);
      _products = result.items;
    } catch (error) {
      _productsError = _messageOf(error);
    } finally {
      _productsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _apiClient.fetchRootCateogires();
      _rebuildRootLevel();
      notifyListeners();
    } catch (_) {
      // 카테고리 로드 실패는 치명적이지 않으므로 조용히 무시한다.
    }
  }

  List<ProductCategory> _rootLevelCategories() {
    return [
      const ProductCategory(id: null, name: '전체'),
      ..._categories,
    ];
  }

  void _rebuildRootLevel() {
    _categoryLevels = [_rootLevelCategories()];
  }

  Future<List<ProductCategory>> _loadChildren(int parentId) async {
    final cached = _childCategoryCache[parentId];
    if (cached != null) {
      return cached;
    }
    final children = await _apiClient.fetchChildCategories(parentId);
    _childCategoryCache[parentId] = children;
    return children;
  }

  Future<void> _appendChildLevel(int parentId) async {
    if (_childCategoryCache.containsKey(parentId)) {
      final cached = _childCategoryCache[parentId]!;
      if (_categoryPath.isNotEmpty &&
          _categoryPath.last == parentId &&
          cached.isNotEmpty) {
        _categoryLevels = [..._categoryLevels, cached];
        notifyListeners();
      }
      return;
    }

    _loadingChildOf = parentId;
    notifyListeners();

    try {
      final children = await _loadChildren(parentId);
      if (_categoryPath.isEmpty || _categoryPath.last != parentId) {
        return;
      }
      if (children.isNotEmpty) {
        _categoryLevels = [..._categoryLevels, children];
      }
    } catch (_) {
      // 하위 카테고리 로드 실패는 치명적이지 않으므로 조용히 무시한다.
    } finally {
      if (_loadingChildOf == parentId) {
        _loadingChildOf = null;
      }
      notifyListeners();
    }
  }

  /// depth 행에서 카테고리를 선택한다. 하위가 있으면 다음 행을 지연 로드한다.
  Future<void> selectCategoryAtDepth({
    required int depth,
    int? categoryId,
  }) async {
    if (depth == 0 && categoryId == null) {
      _categoryPath = [];
      _listCategoryId = null;
      _categoryLevels = _categoryLevels.isNotEmpty
          ? [_categoryLevels.first]
          : [_rootLevelCategories()];
      _loadingChildOf = null;
      notifyListeners();
      await _fetchProductListPage(reset: true);
      return;
    }

    if (categoryId == null) {
      return;
    }

    _categoryPath = [..._categoryPath.take(depth), categoryId];
    _listCategoryId = categoryId;
    _categoryLevels = _categoryLevels.take(depth + 1).toList();
    notifyListeners();

    await Future.wait([
      _fetchProductListPage(reset: true),
      _appendChildLevel(categoryId),
    ]);
  }

  /// 검색어/정렬을 적용해 '상품' 탭 목록을 첫 페이지부터 다시 불러온다.
  Future<void> applyProductFilters({
    String? keyword,
    SortMode? sort,
  }) async {
    if (keyword != null) {
      _listKeyword = keyword;
    }
    if (sort != null) {
      _listSort = sort;
    }
    await _fetchProductListPage(reset: true);
  }

  /// 현재 필터를 유지한 채 목록을 새로고침한다.
  Future<void> refreshProductList() => _fetchProductListPage(reset: true);

  /// 무한 스크롤: 다음 페이지를 불러와 기존 목록에 이어 붙인다.
  Future<void> loadMoreProducts() async {
    if (_listLoading || _listLoadingMore || !_listHasMore) {
      return;
    }
    await _fetchProductListPage(reset: false);
  }

  Future<void> _fetchProductListPage({required bool reset}) async {
    if (reset) {
      _listLoading = true;
      _listError = null;
      _listPage = 0;
      _listHasMore = true;
    } else {
      _listLoadingMore = true;
    }
    notifyListeners();

    final keyword = _listKeyword.trim();
    try {
      final result = await _apiClient.fetchProducts(
        categoryId: _listCategoryId,
        keyword: keyword.isEmpty ? null : keyword,
        page: _listPage,
        size: _listPageSize,
        sort: _listSort.apiSort,
        languageCode: _languageCode
      );
      _listProducts =
          reset ? result.items : [..._listProducts, ...result.items];
      if (reset) {
        _listTotalCount = result.totalElements;
      }
      _listHasMore = !result.isLast;
      if (_listHasMore) {
        _listPage += 1;
      }
    } catch (error) {
      _listError = _messageOf(error);
      if (reset) {
        _listProducts = const [];
        _listTotalCount = 0;
      }
    } finally {
      _listLoading = false;
      _listLoadingMore = false;
      notifyListeners();
    }
  }

  Future<Product> loadProductDetail(int productId) async {
    try {
      return await _apiClient.fetchProduct(
          productId: productId,
          languageCode: languageCode);
    } catch (error) {
      throw ApiException(_messageOf(error));
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

  Future<void> _fetchWishlistPage({required bool reset}) async {
    if (reset) {
      _wishlistLoading = true;
      _wishlistError = null;
      _wishlistPage = 0;
      _wishlistHasMore = true;
    } else {
      _wishlistLoadingMore = true;
    }
    notifyListeners();

    try {
      final result = await _apiClient.fetchWishlists(
        accessToken: _accessToken,
        page: _wishlistPage,
        size: _wishlistPageSize,
        sort: _listSort.apiSort,
        languageCode: languageCode
      );
      _wishlistItems =
          reset ? result.items : [..._wishlistItems, ...result.items];
      if (reset) {
        _wishlistTotalCount = result.totalElements;
      }
      _wishlistHasMore = !result.isLast;
      if (_wishlistHasMore) {
        _wishlistPage += 1;
      }
    } catch (error) {
      if (error is ApiException && error.statusCode == 401) {
        await _clearPersistedToken();
        return;
      }
      _wishlistError = _messageOf(error);
      if (reset) {
        _wishlistItems = const [];
        _wishlistTotalCount = 0;
      }
    } finally {
      _wishlistLoading = false;
      _wishlistLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadWishlist() async {
    if (!isAuthenticated) {
      _wishlistItems = const [];
      _wishlistError = null;
      _wishlistPage = 0;
      _wishlistHasMore = true;
      _wishlistTotalCount = 0;
      notifyListeners();
      return;
    }

    await _fetchWishlistPage(reset: true);
  }

  Future<void> loadMoreWishlists() async {
    if (_wishlistLoading || _wishlistLoadingMore || !_wishlistHasMore) {
      return;
    }
    await _fetchWishlistPage(reset: false);
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
    _wishlistTotalCount = 0;
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
    _wishlistTotalCount = 0;
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

  /// 바로구매 주문 생성. 상품 상세의 "바로구매"에서 단일 상품을 주문할 때 호출된다.
  /// (장바구니 주문은 [checkoutCart]를 사용한다.)
  ///
  /// - [products]: `[{productId, productQuantity}]` 형태의 단일 상품.
  /// - 배송 정보(이름/연락처/주소)는 저장된 배송지 또는 사용자가 결제 페이지에서
  ///   직접 입력한 값을 그대로 전달받는다. (저장된 배송지가 없어도 주문 가능)
  ///
  /// 성공 시 생성된 주문 id를 [orderId]로 돌려준다(무통장 입금 안내 → 결제 완료에 사용).
  Future<({int? orderId, String? error})> placeOrder({
    required String requestMessage,
    required String recipientName,
    required String recipientPhone,
    required String recipientAddress,
    required List<Map<String, int>> products,
    required double totalAmount,
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
      return (orderId: orderId, error: null);
    } catch (error) {
      return (orderId: null, error: _messageOf(error));
    }
  }

  /// 장바구니 주문: 선택된 회원 장바구니 상품으로 주문을 생성한다(서버 원자 처리).
  ///
  /// 서버가 가격을 다시 계산하고, 주문 성공 시 주문된 상품을 장바구니에서 비운다.
  /// 성공 후 장바구니를 새로고침해 상태를 동기화한다.
  Future<({int? orderId, String? error})> checkoutCart({
    required String requestMessage,
    required String recipientName,
    required String recipientPhone,
    required String recipientAddress,
  }) async {
    if (!isAuthenticated || _currentUser == null) {
      return (orderId: null, error: '로그인이 필요합니다.');
    }
    if (selectedCartItems.isEmpty) {
      return (orderId: null, error: '주문할 상품을 먼저 선택해 주세요.');
    }
    if (recipientName.trim().isEmpty ||
        recipientPhone.trim().isEmpty ||
        recipientAddress.trim().isEmpty) {
      return (orderId: null, error: '배송 정보를 모두 입력해 주세요.');
    }

    try {
      final orderId = await _apiClient.checkoutCart(
        accessToken: _accessToken!,
        requestMessage: requestMessage.trim(),
        recipientName: recipientName.trim(),
        recipientPhone: recipientPhone.trim(),
        recipientAddress: recipientAddress.trim(),
      );
      await loadCart();
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
