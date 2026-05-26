class CartEntry {
  const CartEntry({
    required this.cartItemId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.selected,
    required this.sellingPrice,
    required this.itemTotalPrice,
    required this.productStatus,
    required this.inventoryStatus,
    required this.imageUrl,
  });

  final int cartItemId;
  final int productId;
  final String productName;
  final int quantity;
  final bool selected;
  final double sellingPrice;
  final double itemTotalPrice;
  final String productStatus;
  final String inventoryStatus;
  final String? imageUrl;

  bool get isAvailable =>
      productStatus == 'ON_SALE' &&
      inventoryStatus != 'OUT_OF_STOCK' &&
      inventoryStatus != 'EXPIRED';

  String get inventoryStatusLabel {
    switch (inventoryStatus) {
      case 'NORMAL':
      case 'IN_STOCK':
        return '';
      case 'LOW_STOCK':
        return '재고 부족';
      case 'OUT_OF_STOCK':
        return '품절';
      case 'EXPIRED':
        return '판매 종료';
      default:
        return '';
    }
  }

  factory CartEntry.fromJson(Map<String, dynamic> json) {
    return CartEntry(
      cartItemId: (json['cartItemId'] as num?)?.toInt() ?? 0,
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      productName: json['productName'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      selected: json['selected'] as bool? ?? false,
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? 0,
      itemTotalPrice: (json['itemTotalPrice'] as num?)?.toDouble() ?? 0,
      productStatus: json['productStatus'] as String? ?? 'STOPPED',
      inventoryStatus: json['inventoryStatus'] as String? ?? 'OUT_OF_STOCK',
      imageUrl: json['mainImageUrl'] as String?,
    );
  }
}
