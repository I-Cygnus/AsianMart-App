class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.listPrice,
    required this.sellingPrice,
    required this.categoryId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.thumbnailUrl,
  });

  final int id;
  final String name;
  final String description;
  final double listPrice;
  final double sellingPrice;
  final int categoryId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? thumbnailUrl;

  bool get isOrderable => status == 'ON_SALE';

  String get statusLabel {
    switch (status) {
      case 'ON_SALE':
        return '판매중';
      case 'STOPPED':
        return '판매중지';
      case 'OUT_OF_STOCK':
        return '품절';
      default:
        return '일시품절';
    }
  }

  int get discountPercent {
    if (listPrice <= sellingPrice || listPrice == 0) {
      return 0;
    }
    return ((1 - sellingPrice / listPrice) * 100).round();
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      listPrice: (json['listPrice'] as num?)?.toDouble() ?? 0,
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? 0,
      categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'STOPPED',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }
}
