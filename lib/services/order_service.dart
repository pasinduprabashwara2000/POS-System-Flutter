import 'package:flutter/foundation.dart';
import '../models/order.dart';
import 'product_service.dart';

/// In-memory order store for the POS app.
///
/// Placing an order deducts stock via [ProductService.adjustStock];
/// deleting an order restores it. Singleton `ChangeNotifier` so the
/// dashboard and order screens can react to new sales / stock changes.
class OrderService extends ChangeNotifier {
  OrderService._internal();

  static final OrderService instance = OrderService._internal();

  final List<Order> _orders = [];
  int _nextId = 1;

  List<Order> get orders => List.unmodifiable(_orders);

  String _generateId() => 'ORD${(_nextId++).toString().padLeft(5, '0')}';

  // ---------- CREATE ----------
  /// Creates an order and deducts stock for each line item. Callers
  /// should validate stock availability before calling this (e.g. in the
  /// New Sale screen) since this method assumes the cart is already
  /// valid and does not roll back partial stock deductions on failure.
  Order placeOrder({
    required String customerId,
    required String customerName,
    required List<OrderItem> items,
  }) {
    final order = Order(
      id: _generateId(),
      customerId: customerId,
      customerName: customerName,
      items: items,
    );

    for (final item in items) {
      ProductService.instance.adjustStock(item.productId, -item.quantity);
    }

    _orders.insert(0, order);
    notifyListeners();
    return order;
  }

  // ---------- READ ----------
  List<Order> getAll() => List.unmodifiable(_orders);

  Order? getById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Order> search(String query) {
    if (query.trim().isEmpty) return getAll();
    final q = query.trim().toLowerCase();
    return _orders.where((o) {
      return o.customerName.toLowerCase().contains(q) || o.id.toLowerCase().contains(q);
    }).toList();
  }

  List<Order> get todaysOrders => _orders.where((o) => o.isToday).toList();

  int get todaysOrderCount => todaysOrders.length;

  double get todaysSalesTotal =>
      todaysOrders.fold(0.0, (sum, order) => sum + order.totalAmount);

  int get totalOrderCount => _orders.length;

  // ---------- DELETE ----------
  /// Deletes an order and restocks every item it contained.
  bool deleteOrder(String id) {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index == -1) return false;

    final order = _orders[index];
    for (final item in order.items) {
      ProductService.instance.adjustStock(item.productId, item.quantity);
    }

    _orders.removeAt(index);
    notifyListeners();
    return true;
  }
}