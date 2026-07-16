import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../services/customer_service.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';
import '../../theme/app_theme.dart';
import '../customer/customer_form_screen.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final TextEditingController _searchController = TextEditingController();

  String? _customerId;
  // productId -> quantity currently in the cart
  final Map<String, int> _cart = {};
  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _availableStock(Product product) {
    final inCart = _cart[product.id] ?? 0;
    return product.stockQty - inCart;
  }

  void _incrementItem(Product product) {
    if (_availableStock(product) <= 0) return;
    setState(() {
      _cart[product.id] = (_cart[product.id] ?? 0) + 1;
    });
  }

  void _decrementItem(String productId) {
    setState(() {
      final current = _cart[productId] ?? 0;
      if (current <= 1) {
        _cart.remove(productId);
      } else {
        _cart[productId] = current - 1;
      }
    });
  }

  double get _cartTotal {
    double total = 0;
    final products = ProductService.instance.products;
    for (final entry in _cart.entries) {
      final product = products.firstWhere((p) => p.id == entry.key);
      total += product.price * entry.value;
    }
    return total;
  }

  int get _cartItemCount => _cart.values.fold(0, (sum, qty) => sum + qty);

  Future<void> _placeOrder() async {
    if (_customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer')),
      );
      return;
    }
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one product to the cart')),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    final customer = CustomerService.instance.getById(_customerId!);
    if (customer == null) {
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected customer no longer exists')),
      );
      return;
    }

    final products = ProductService.instance.products;
    final items = _cart.entries.map((entry) {
      final product = products.firstWhere((p) => p.id == entry.key);
      return OrderItem(
        productId: product.id,
        productName: product.name,
        unitPrice: product.price,
        quantity: entry.value,
      );
    }).toList();

    final order = OrderService.instance.placeOrder(
      customerId: customer.id,
      customerName: customer.name,
      items: items,
    );

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.accent),
            SizedBox(width: 10),
            Text('Order Placed'),
          ],
        ),
        content: Text(
          'Order ${order.id} for ${order.customerName}\nTotal: Rs. ${order.totalAmount.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = ProductService.instance.products;
    final query = _searchController.text.trim().toLowerCase();
    final products = query.isEmpty
        ? allProducts
        : allProducts
        .where((p) =>
    p.name.toLowerCase().contains(query) || p.sku.toLowerCase().contains(query))
        .toList();
    final customers = CustomerService.instance.customers;

    return Scaffold(
      appBar: AppBar(title: const Text('New Sale')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _buildCustomerSelector(customers),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search products by name or SKU',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: products.isEmpty
                  ? const Center(
                child: Text(
                  'No products found',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _ProductPickerTile(
                    product: product,
                    quantityInCart: _cart[product.id] ?? 0,
                    availableStock: _availableStock(product),
                    onAdd: () => _incrementItem(product),
                    onRemove: () => _decrementItem(product.id),
                  );
                },
              ),
            ),
            if (_cart.isNotEmpty) _buildCartBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSelector(List customers) {
    if (customers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'No customers yet. Add one to start a sale.',
                style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),
            ),
            TextButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CustomerFormScreen()),
                );
                setState(() {});
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: _customerId,
      decoration: const InputDecoration(
        labelText: 'Customer *',
        prefixIcon: Icon(Icons.person_outline),
      ),
      items: customers
          .map<DropdownMenuItem<String>>(
            (customer) => DropdownMenuItem(value: customer.id, child: Text(customer.name)),
      )
          .toList(),
      onChanged: (value) => setState(() => _customerId = value),
    );
  }

  Widget _buildCartBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_cartItemCount item${_cartItemCount == 1 ? '' : 's'} in cart',
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                  Text(
                    'Rs. ${_cartTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: _isPlacingOrder ? null : _placeOrder,
                child: _isPlacingOrder
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                )
                    : const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductPickerTile extends StatelessWidget {
  final Product product;
  final int quantityInCart;
  final int availableStock;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _ProductPickerTile({
    required this.product,
    required this.quantityInCart,
    required this.availableStock,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final outOfStock = product.stockQty <= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              product.initial,
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Rs. ${product.price.toStringAsFixed(2)} • ${outOfStock ? 'Out of stock' : '$availableStock available'}',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: outOfStock ? AppColors.error : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (quantityInCart == 0)
            IconButton.filledTonal(
              onPressed: outOfStock ? null : onAdd,
              icon: const Icon(Icons.add),
            )
          else
            Row(
              children: [
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppColors.error,
                ),
                Text(
                  '$quantityInCart',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                IconButton(
                  onPressed: availableStock > 0 ? onAdd : null,
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.primary,
                ),
              ],
            ),
        ],
      ),
    );
  }
}