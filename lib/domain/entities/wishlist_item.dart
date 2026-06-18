class WishlistItem {
  const WishlistItem({
    required this.wishlistItemId,
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.sellingPrice,
    required this.productStatus,
    required this.inventoryStatus,
    required this.thumbnailUrl,
    required this.createdAt,
  });

  final int wishlistItemId;
  final int productId;
  final String productName;
  final String productDescription;
  final double sellingPrice;
  final String productStatus;
  final String inventoryStatus;
  final String? thumbnailUrl;
  final DateTime createdAt;

  bool get isAvailable =>
      productStatus == 'ON_SALE' &&
      inventoryStatus != 'OUT_OF_STOCK' &&
      inventoryStatus != 'EXPIRED';

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      wishlistItemId: (json['wishlistItemId'] as num?)?.toInt() ?? 0,
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      productName: json['productName'] as String? ?? '',
      productDescription: json['productDescription'] as String? ?? '',
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? 0,
      productStatus: json['productStatus'] as String? ?? 'STOPPED',
      inventoryStatus: json['inventoryStatus'] as String? ?? 'OUT_OF_STOCK',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
