/// A single line item within an order.
///
/// Product name and unit price are snapshotted at the time of sale so
/// that historical orders stay accurate even if the product is later
/// renamed, repriced, or deleted from the catalog.
class OrderItem {
  final String productId;
  final String productName;
  final double unitPrice;
  int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  double get subtotal => unitPrice * quantity;
}

/// Represents a completed sale/order in the POS system.
class Order {
  final String id;
  final String customerId;
  final String customerName; // snapshot, same reasoning as OrderItem
  final List<OrderItem> items;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.items,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.subtotal);

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }
}