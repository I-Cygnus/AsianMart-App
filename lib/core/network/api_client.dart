import 'dart:convert';
import 'dart:io';

import 'package:asian_mart_app/core/config/api_config.dart';
import 'package:asian_mart_app/core/network/api_exception.dart';
import 'package:asian_mart_app/domain/entities/address.dart';
import 'package:asian_mart_app/domain/entities/admin_order.dart';
import 'package:asian_mart_app/domain/entities/app_user.dart';
import 'package:asian_mart_app/domain/entities/cart_entry.dart';
import 'package:asian_mart_app/domain/entities/cart_snapshot.dart';
import 'package:asian_mart_app/domain/entities/delivery.dart';
import 'package:asian_mart_app/domain/entities/order_detail.dart';
import 'package:asian_mart_app/domain/entities/order_history_item.dart';
import 'package:asian_mart_app/domain/entities/product.dart';
import 'package:asian_mart_app/domain/entities/product_category.dart';
import 'package:asian_mart_app/domain/entities/wishlist_item.dart';

class ApiClient {
  ApiClient();

  final HttpClient _httpClient = HttpClient();

  Future<List<ProductCategory>> fetchRootCateogires() async {
    final response = await _send('GET', '/api/categories/root');

    if (response.data is List) {
      return (response.data as List)
          .whereType<Map<String, dynamic>>()
          .map(ProductCategory.fromJson)
          .toList();
    }
    return [];
  }

  Future<List<ProductCategory>> fetchChildCategories(int parentId) async {
    final response = await _send('GET', '/api/categories/child/$parentId');

    if (response.data is List) {
      return (response.data as List)
          .whereType<Map<String, dynamic>>()
          .map(ProductCategory.fromJson)
          .toList();
    }
    return [];
  }

  Future<Product> fetchProduct({
    required int productId,
    String? languageCode
  }) async {
    final Map<String, String> query = {};
    if (languageCode != null) {
      query['languageCode'] = languageCode;
    }
    final response = await _send(
      'GET',
      '/api/products/$productId',
      query: query
    );
    return Product.fromJson(_asMap(response.data));
  }

  Future<PagedProducts> fetchProducts({
    num? categoryId,
    String? keyword,
    String? searchField,
    num? page,
    num? size,
    String? sort,
    String? languageCode
  }) async {
    final Map<String, String> query = {};
    if (categoryId != null) {
      query['categoryId'] = '$categoryId';
    }
    if (keyword != null && keyword.isNotEmpty) {
      query['keyword'] = keyword;
    }
    if (searchField != null && searchField.isNotEmpty) {
      query['searchField'] = searchField;
    }

    query['page'] = page != null ? '$page' : '0';
    query['size'] = size != null ? '$size' : '4';

    if (sort != null && sort.isNotEmpty) {
      query['sort'] = sort;
    }

    if (languageCode != null) {
      query['languageCode'] = languageCode;
    }

    final response = await _send('GET', '/api/products', query: query);
    final body = _asMap(response.data);
    final content = body['content'] as List<dynamic>? ?? const [];
    final items = content
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();

    return PagedProducts(
      items: items,
      page: (body['number'] as num?)?.toInt() ?? (page?.toInt() ?? 0),
      isLast: body['last'] as bool? ?? true,
      totalElements: (body['totalElements'] as num?)?.toInt() ?? items.length,
      totalPages: (body['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  Future<List<Product>> fetchRecommendedProducts({String? languageCode}) async {
    final Map<String, String> query = {};

    if (languageCode != null) {
      query['languageCode'] = languageCode;
    }
    final response = await _send('GET', '/api/products/recommend', query: query);
    final body = _asMap(response.data);
    final content = body['products'] as List<dynamic>? ?? const [];
    final products = content
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
      
    return products;
  }

  Future<List<Product>> fetchPopularProducts({String? languageCode}) async {
    final Map<String, String> query = {};

    if (languageCode != null) {
      query['languageCode'] = languageCode;
    }
    final response = await _send('GET', '/api/products/popular', query: query);
    final body = _asMap(response.data);
    final content = body['products'] as List<dynamic>? ?? const [];
    final products = content
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
      
    return products;
  }

  Future<({String accessToken, List<String> roles})> login({
    required String email,
    required String password,
  }) async {
    final response = await _send(
      'POST',
      '/api/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );
    final body = _asMap(response.data);
    final roles = (body['userRoles'] as List<dynamic>?)
            ?.whereType<String>()
            .toList() ??
        const <String>[];
    return (
      accessToken: body['accessToken'] as String? ?? '',
      roles: roles,
    );
  }

  Future<void> signup({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    await _send(
      'POST',
      '/api/users/signup',
      body: {
        'email': email,
        'password': password,
        'name': name,
        'phone': phone.trim().isEmpty ? null : phone.trim(),
        'address': null,
      },
    );
  }

  Future<void> logout(String accessToken) async {
    await _send(
      'POST',
      '/api/auth/logout',
      accessToken: accessToken,
    );
  }

  /// FCM 기기 토큰 등록(로그인 사용자 기준 업서트).
  Future<void> registerDeviceToken({
    required String accessToken,
    required String token,
    String? platform,
  }) async {
    await _send(
      'POST',
      '/api/users/device-token',
      accessToken: accessToken,
      body: {'token': token, 'platform': platform},
    );
  }

  /// FCM 기기 토큰 삭제(로그아웃 시).
  Future<void> deleteDeviceToken({
    required String accessToken,
    required String token,
  }) async {
    await _send(
      'DELETE',
      '/api/users/device-token',
      accessToken: accessToken,
      body: {'token': token},
    );
  }

  Future<AppUser> fetchMe(String accessToken) async {
    final response = await _send(
      'GET',
      '/api/users/me',
      accessToken: accessToken,
    );
    return AppUser.fromJson(_asMap(response.data));
  }

  Future<List<Address>> fetchAddresses(String accessToken) async {
    final response = await _send(
      'GET',
      '/api/users/addresses',
      accessToken: accessToken,
    );
    return _asList(response.data)
        .whereType<Map<String, dynamic>>()
        .map(Address.fromJson)
        .toList();
  }

  Future<void> addAddress({
    required String accessToken,
    required String addressName,
    required String zipCode,
    required String address1,
    required String address2,
    required bool isDefault,
  }) async {
    await _send(
      'POST',
      '/api/users/addresses',
      accessToken: accessToken,
      body: {
        'addressName': addressName,
        'isDefault': isDefault,
        'addressInfo': {
          'zipCode': zipCode,
          'address1': address1,
          'address2': address2.trim().isEmpty ? null : address2.trim(),
        },
      },
    );
  }

  Future<void> deleteAddress({
    required String accessToken,
    required int addressId,
  }) async {
    await _send(
      'DELETE',
      '/api/users/addresses/$addressId',
      accessToken: accessToken,
    );
  }

  Future<void> setDefaultAddress({
    required String accessToken,
    required int addressId,
  }) async {
    await _send(
      'PATCH',
      '/api/users/addresses/$addressId/default',
      accessToken: accessToken,
    );
  }

  Future<CartSnapshot> fetchCart({
    String? accessToken,
    String? guestToken,
  }) async {
    final response = await _send(
      'GET',
      '/api/cart',
      accessToken: accessToken,
      guestToken: guestToken,
    );
    return _cartSnapshotFromResponse(response.data);
  }

  Future<CartSnapshot> addCartItem({
    required int productId,
    required int quantity,
    String? accessToken,
    String? guestToken,
  }) async {
    final response = await _send(
      'POST',
      '/api/cart/items',
      accessToken: accessToken,
      guestToken: guestToken,
      body: {
        'productId': productId,
        'quantity': quantity,
      },
    );
    return _cartSnapshotFromResponse(response.data);
  }

  Future<CartSnapshot> updateCartQuantity({
    required int cartItemId,
    required int quantity,
    String? accessToken,
    String? guestToken,
  }) async {
    final response = await _send(
      'PATCH',
      '/api/cart/items/$cartItemId/quantity',
      accessToken: accessToken,
      guestToken: guestToken,
      body: {
        'quantity': quantity,
      },
    );
    return _cartSnapshotFromResponse(response.data);
  }

  Future<CartSnapshot> updateCartSelected({
    required int cartItemId,
    required bool selected,
    String? accessToken,
    String? guestToken,
  }) async {
    final response = await _send(
      'PATCH',
      '/api/cart/items/$cartItemId/selected',
      accessToken: accessToken,
      guestToken: guestToken,
      body: {
        'selected': selected,
      },
    );
    return _cartSnapshotFromResponse(response.data);
  }

  Future<CartSnapshot> deleteCartItem({
    required int cartItemId,
    String? accessToken,
    String? guestToken,
  }) async {
    final response = await _send(
      'DELETE',
      '/api/cart/items/$cartItemId',
      accessToken: accessToken,
      guestToken: guestToken,
    );
    return _cartSnapshotFromResponse(response.data);
  }

  Future<CartSnapshot> deleteSelectedCartItems({
    String? accessToken,
    String? guestToken,
  }) async {
    final response = await _send(
      'DELETE',
      '/api/cart/items/selected',
      accessToken: accessToken,
      guestToken: guestToken,
    );
    return _cartSnapshotFromResponse(response.data);
  }

  Future<PagedWishlistItems> fetchWishlists({
    String? accessToken,
    num? page,
    num? size,
    String? sort,
    String? languageCode
  }) async {
    final Map<String, String> query = {};

    query['page'] = page != null ? '$page' : '0';
    query['size'] = size != null ? '$size' : '4';

    if (sort != null && sort.isNotEmpty) {
      query['sort'] = sort;
    }

    if (languageCode != null) {
      query['languageCode'] = languageCode;
    }

    final response = await _send('GET', '/api/wishlist/page', query: query, accessToken: accessToken);
    final body = _asMap(response.data);
    final content = body['content'] as List<dynamic>? ?? const [];
    final items = content
        .whereType<Map<String, dynamic>>()
        .map(WishlistItem.fromJson)
        .toList();

    return PagedWishlistItems(
      items: items,
      page: (body['number'] as num?)?.toInt() ?? (page?.toInt() ?? 0),
      isLast: body['last'] as bool? ?? true,
      totalElements: (body['totalElements'] as num?)?.toInt() ?? items.length,
      totalPages: (body['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  Future<void> toggleWishlist({
    required String accessToken,
    required int productId,
  }) async {
    await _send(
      'POST',
      '/api/wishlist/items/$productId/toggle',
      accessToken: accessToken,
    );
  }

  /// 주문 생성. 생성된 주문의 id를 반환한다(무통장 입금 확정에 사용).
  Future<int> placeOrder({
    required String accessToken,
    required List<Map<String, int>> products,
    required num totalAmount,
    required String requestMessage,
    required String recipientName,
    required String recipientPhone,
    required String recipientAddress,
  }) async {
    final response = await _send(
      'POST',
      '/api/order/place',
      accessToken: accessToken,
      body: {
        'totalAmount': totalAmount,
        'payAmount': totalAmount,
        'requestMessage': requestMessage,
        'paymentType': 'BANK_TRANSFER',
        'recipientName': recipientName,
        'recipientPhone': recipientPhone,
        'recipientAddress': recipientAddress,
        'products': products
            .map((item) => {
                  'productId': item['productId'],
                  'productQuantity': item['productQuantity'],
                })
            .toList(),
      },
    );
    final body = _asMap(response.data);
    return (body['orderId'] as num?)?.toInt() ?? 0;
  }

  /// 장바구니 체크아웃: 선택된 회원 장바구니 상품으로 주문을 생성한다.
  /// 서버가 금액을 계산하고 주문된 상품을 장바구니에서 비운다. 생성된 주문 id를 반환.
  Future<int> checkoutCart({
    required String accessToken,
    required String recipientName,
    required String recipientPhone,
    required String recipientAddress,
    required String requestMessage,
  }) async {
    final response = await _send(
      'POST',
      '/api/cart/checkout',
      accessToken: accessToken,
      body: {
        'recipientName': recipientName,
        'recipientPhone': recipientPhone,
        'recipientAddress': recipientAddress,
        'paymentType': 'BANK_TRANSFER',
        'requestMessage': requestMessage,
      },
    );
    final body = _asMap(response.data);
    return (body['orderId'] as num?)?.toInt() ?? 0;
  }

  /// 고객 무통장 입금 통보: 주문(PLACED) → 입금 확인 대기(PAYMENT_PENDING).
  Future<void> reportPayment({
    required String accessToken,
    required int orderId,
  }) async {
    await _send(
      'POST',
      '/api/order/$orderId/payment',
      accessToken: accessToken,
    );
  }

  /// 내 주문 내역 목록 (최신순).
  Future<List<OrderHistoryItem>> fetchOrders(String accessToken) async {
    final response = await _send(
      'GET',
      '/api/order',
      accessToken: accessToken,
    );
    return _asList(response.data)
        .whereType<Map<String, dynamic>>()
        .map(OrderHistoryItem.fromJson)
        .toList();
  }

  /// 주문 상세 (상품 목록 + 배송 정보).
  Future<OrderDetail> fetchOrderDetail({
    required String accessToken,
    required int orderId,
  }) async {
    final response = await _send(
      'GET',
      '/api/order/$orderId',
      accessToken: accessToken,
    );
    return OrderDetail.fromJson(_asMap(response.data));
  }

  // ── 루트 관리자 (주문 요청) ────────────────────────────────────────────────
  /// 관리자 주문 상세: 배송지 + 상품 목록(이미지 포함).
  Future<OrderDetail> fetchAdminOrderDetail({
    required String accessToken,
    required int orderId,
  }) async {
    final response = await _send(
      'GET',
      '/api/admin/order/$orderId',
      accessToken: accessToken,
    );
    return OrderDetail.fromJson(_asMap(response.data));
  }

  /// 주문 요청 목록: 입금 대기(PLACED) + 입금 확인 대기(PAYMENT_PENDING).
  Future<List<AdminOrder>> fetchAdminOrderRequests(String accessToken) async {
    final response = await _send(
      'GET',
      '/api/admin/order/requests',
      accessToken: accessToken,
    );
    return _asList(response.data)
        .whereType<Map<String, dynamic>>()
        .map(AdminOrder.fromJson)
        .toList();
  }

  /// 관리자 입금 확인: 주문(PAYMENT_PENDING) → 확정(CONFIRMED).
  Future<void> confirmOrder({
    required String accessToken,
    required int orderId,
  }) async {
    await _send(
      'POST',
      '/api/admin/order/$orderId/confirm',
      accessToken: accessToken,
    );
  }

  // ── 배송 (배송 기사 앱) ────────────────────────────────────────────────────
  /// 배송 리스트 = 결제 완료(CONFIRMED) 주문 + 각 주문의 배송 상태.
  Future<List<Delivery>> fetchDeliveries(String accessToken) async {
    final response = await _send(
      'GET',
      '/api/delivery/orders',
      accessToken: accessToken,
    );
    return _asList(response.data)
        .whereType<Map<String, dynamic>>()
        .map(Delivery.fromJson)
        .toList();
  }

  /// 배송 접수: 확정 주문([orderId])에 대해 배송(ACCEPTED)을 생성한다.
  Future<void> registerDelivery({
    required String accessToken,
    required int orderId,
  }) async {
    await _send(
      'POST',
      '/api/delivery/register',
      accessToken: accessToken,
      body: {'orderId': orderId},
    );
  }

  /// 배송 상태를 다음 단계로 전이. [action]은 prepare | ship | complete.
  Future<void> advanceDelivery({
    required String accessToken,
    required int deliveryId,
    required String action,
  }) async {
    await _send(
      'POST',
      '/api/delivery/$deliveryId/$action',
      accessToken: accessToken,
    );
  }

  CartSnapshot _cartSnapshotFromResponse(Object? data) {
    final body = _asMap(data);
    final items = body['items'] as List<dynamic>? ?? const [];
    return CartSnapshot(
      items: items
          .whereType<Map<String, dynamic>>()
          .map(CartEntry.fromJson)
          .toList(),
      guestToken: body['guestToken'] as String?,
    );
  }

  Future<_ApiResponse> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    String? accessToken,
    String? guestToken,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters: query,
    );

    final request = await _httpClient.openUrl(method, uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (accessToken != null && accessToken.isNotEmpty) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    }
    if (guestToken != null && guestToken.isNotEmpty) {
      request.headers.set('X-Guest-Token', guestToken);
    }
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
    }

    final response = await request.close();
    final rawBody = await _readBody(response);
    final data = rawBody.isEmpty ? null : jsonDecode(rawBody);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = data is Map<String, dynamic>
          ? data['message'] as String? ?? '요청 처리에 실패했습니다.'
          : '요청 처리에 실패했습니다.';
      throw ApiException(message, response.statusCode);
    }

    return _ApiResponse(response.statusCode, data);
  }

  Future<String> _readBody(HttpClientResponse response) async {
    final bytes = await response.fold<List<int>>(
      <int>[],
      (buffer, data) {
        buffer.addAll(data);
        return buffer;
      },
    );
    return utf8.decode(bytes);
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    return const {};
  }

  List<dynamic> _asList(Object? data) {
    if (data is List<dynamic>) {
      return data;
    }
    return const [];
  }
}

class _ApiResponse {
  const _ApiResponse(this.statusCode, this.data);

  final int statusCode;
  final Object? data;
}

/// 상품 목록 조회 결과. 페이지네이션 메타데이터를 함께 담는다.
class PagedProducts {
  const PagedProducts({
    required this.items,
    required this.page,
    required this.isLast,
    required this.totalElements,
    required this.totalPages,
  });

  final List<Product> items;
  final int page;
  final bool isLast;
  final int totalElements;
  final int totalPages;
}

class PagedWishlistItems {
  const PagedWishlistItems({
    required this.items,
    required this.page,
    required this.isLast,
    required this.totalElements,
    required this.totalPages,
  });

  final List<WishlistItem> items;
  final int page;
  final bool isLast;
  final int totalElements;
  final int totalPages;
}
