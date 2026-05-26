import 'dart:convert';
import 'dart:io';

import 'package:asian_mart_app/core/config/api_config.dart';
import 'package:asian_mart_app/core/network/api_exception.dart';
import 'package:asian_mart_app/domain/entities/address.dart';
import 'package:asian_mart_app/domain/entities/app_user.dart';
import 'package:asian_mart_app/domain/entities/cart_entry.dart';
import 'package:asian_mart_app/domain/entities/cart_snapshot.dart';
import 'package:asian_mart_app/domain/entities/product.dart';
import 'package:asian_mart_app/domain/entities/wishlist_item.dart';

class ApiClient {
  ApiClient();

  final HttpClient _httpClient = HttpClient();

  Future<List<Product>> fetchProducts() async {
    final response = await _send('GET', '/api/products', query: {
      'page': '0',
      'size': '100',
    });
    final body = _asMap(response.data);
    final content = body['content'] as List<dynamic>? ?? const [];
    return content
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }

  Future<String> login({
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
    return body['accessToken'] as String? ?? '';
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

  Future<List<WishlistItem>> fetchWishlist(String accessToken) async {
    final response = await _send(
      'GET',
      '/api/wishlist',
      accessToken: accessToken,
    );
    final body = _asMap(response.data);
    final items = body['items'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(WishlistItem.fromJson)
        .toList();
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

  Future<void> placeOrder({
    required String accessToken,
    required int userId,
    required List<Map<String, int>> products,
    required int totalAmount,
    required String requestMessage,
  }) async {
    await _send(
      'POST',
      '/order/place',
      accessToken: accessToken,
      body: {
        'userId': userId,
        'totalAmount': totalAmount,
        'payAmount': totalAmount,
        'requestMessage': requestMessage,
        'orderStatus': 'PENDING',
        'paymentType': 'BANK_TRANSFER',
        'products': products
            .map((item) => {
                  'productId': item['productId'],
                  'productQuantity': item['productQuantity'],
                })
            .toList(),
      },
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
