import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'category_service.dart';
import 'supplier_service.dart';

/// In-memory product/inventory store for the POS app.
///
/// Singleton `ChangeNotifier` so any screen (product list, dashboard
/// stats, future order screens) can listen for stock/catalog changes.
/// Swap the internal storage for a real database/API later without
/// changing the CRUD method signatures used by the UI.
class ProductService extends ChangeNotifier {
  ProductService._internal() {
    _seedData();
  }

  static final ProductService instance = ProductService._internal();

  final List<Product> _products = [];
  int _nextId = 1;

  List<Product> get products => List.unmodifiable(_products);

  void _seedData() {
    final categories = CategoryService.instance.getAll();
    final suppliers = SupplierService.instance.getAll();

    String? categoryIdAt(int index) =>
        categories.length > index ? categories[index].id : null;
    String? supplierIdAt(int index) =>
        suppliers.length > index ? suppliers[index].id : null;

    _products.addAll([
      Product(
        id: _generateId(),
        name: 'Coca Cola 500ml',
        sku: 'BEV-001',
        categoryId: categoryIdAt(0) ?? '',
        supplierId: supplierIdAt(0),
        price: 150.0,
        stockQty: 40,
        lowStockThreshold: 10,
      ),
      Product(
        id: _generateId(),
        name: 'Basmati Rice 5kg',
        sku: 'GRO-010',
        categoryId: categoryIdAt(1) ?? categoryIdAt(0) ?? '',
        supplierId: supplierIdAt(1),
        price: 1450.0,
        stockQty: 5,
        lowStockThreshold: 8, // intentionally low -> demonstrates the reminder
      ),
      Product(
        id: _generateId(),
        name: 'USB-C Charger 20W',
        sku: 'ELEC-005',
        categoryId: categoryIdAt(2) ?? categoryIdAt(0) ?? '',
        price: 2200.0,
        stockQty: 15,
        lowStockThreshold: 5,
      ),
    ]);
  }

  String _generateId() => 'P${(_nextId++).toString().padLeft(4, '0')}';

  // ---------- CREATE ----------
  Product addProduct({
    required String name,
    String sku = '',
    required String categoryId,
    String? supplierId,
    required double price,
    required int stockQty,
    int lowStockThreshold = 5,
    String description = '',
    String? imagePath,
  }) {
    final product = Product(
      id: _generateId(),
      name: name.trim(),
      sku: sku.trim(),
      categoryId: categoryId,
      supplierId: supplierId,
      price: price,
      stockQty: stockQty,
      lowStockThreshold: lowStockThreshold,
      description: description.trim(),
      imagePath: imagePath,
    );
    _products.insert(0, product);
    notifyListeners();
    return product;
  }

  // ---------- READ ----------
  List<Product> getAll() => List.unmodifiable(_products);

  Product? getById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Product> search(String query, {bool lowStockOnly = false}) {
    Iterable<Product> result = _products;

    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((p) =>
      p.name.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q));
    }

    if (lowStockOnly) {
      result = result.where((p) => p.isLowStock);
    }

    return result.toList();
  }

  /// Products at or below their reorder threshold — used for low-stock
  /// reminder banners/badges.
  List<Product> get lowStockProducts => _products.where((p) => p.isLowStock).toList();

  int get lowStockCount => lowStockProducts.length;

  String categoryNameFor(String categoryId) {
    return CategoryService.instance.getById(categoryId)?.name ?? 'Uncategorized';
  }

  String? supplierNameFor(String? supplierId) {
    if (supplierId == null) return null;
    return SupplierService.instance.getById(supplierId)?.name;
  }

  // ---------- UPDATE ----------
  bool updateProduct(
      String id, {
        required String name,
        required String sku,
        required String categoryId,
        String? supplierId,
        required double price,
        required int stockQty,
        required int lowStockThreshold,
        required String description,
        String? imagePath,
        bool clearImage = false,
      }) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index == -1) return false;
    _products[index] = _products[index].copyWith(
      name: name.trim(),
      sku: sku.trim(),
      categoryId: categoryId,
      supplierId: supplierId,
      clearSupplier: supplierId == null,
      price: price,
      stockQty: stockQty,
      lowStockThreshold: lowStockThreshold,
      description: description.trim(),
      imagePath: imagePath,
      clearImage: clearImage,
    );
    notifyListeners();
    return true;
  }

  /// Adjusts stock by [delta] (negative to deduct, e.g. on a sale/order;
  /// positive to restock). Clamps at zero so stock never goes negative.
  bool adjustStock(String id, int delta) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index == -1) return false;
    final current = _products[index];
    final newQty = (current.stockQty + delta).clamp(0, 1 << 31);
    _products[index] = current.copyWith(stockQty: newQty);
    notifyListeners();
    return true;
  }

  // ---------- DELETE ----------
  bool deleteProduct(String id) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index == -1) return false;
    _products.removeAt(index);
    notifyListeners();
    return true;
  }
}