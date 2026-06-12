class ProductCategory {
    const ProductCategory({
        required this.id,
        required this.name,
        this.parentId,
    });

    final int? id;
    final String name;
    final int? parentId;

    factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
            id: (json['id'] as num?)?.toInt() ?? 0,
            name: json['name'] as String,
            parentId: (json['parentId'] as num?)?.toInt()
        );
    }
}

