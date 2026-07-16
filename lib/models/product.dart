/// Represents a product/inventory item in the POS system.
class Product {
  final String id;
  String name;
  String sku;
  String categoryId;
  String? supplierId;
  double price;
  int stockQty;
  int lowStockThreshold;
  String description;
  DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    this.sku = '',
    required this.categoryId,
    this.supplierId,
    required this.price,
    required this.stockQty,
    this.lowStockThreshold = 5,
    this.description = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// True when stock has dropped to, or below, the reorder threshold.
  bool get isLowStock => stockQty <= lowStockThreshold;

  bool get isOutOfStock => stockQty <= 0;

  String get initial => name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

  Product copyWith({
    String? name,
    String? sku,
    String? categoryId,
    String? supplierId,
    bool clearSupplier = false,
    double? price,
    int? stockQty,
    int? lowStockThreshold,
    String? description,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      categoryId: categoryId ?? this.categoryId,
      supplierId: clearSupplier ? null : (supplierId ?? this.supplierId),
      price: price ?? this.price,
      stockQty: stockQty ?? this.stockQty,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      description: description ?? this.description,
      createdAt: createdAt,
    );
  }
}