import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../theme/app_theme.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductService _service = ProductService.instance;
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  bool _lowStockOnly = false;

  @override
  void initState() {
    super.initState();
    _service.addListener(_refresh);
    _refresh();
  }

  @override
  void dispose() {
    _service.removeListener(_refresh);
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _products = _service.search(_searchController.text, lowStockOnly: _lowStockOnly);
    });
  }

  Future<void> _openForm({Product? product}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
    );
    _refresh();
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _service.deleteProduct(product.id);
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${product.name} deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lowStockCount = _service.lowStockCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _refresh(),
                decoration: InputDecoration(
                  hintText: 'Search by name or SKU',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _refresh();
                    },
                  ),
                ),
              ),
            ),
            if (lowStockCount > 0) _buildLowStockBanner(lowStockCount),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FilterChip(
                  label: const Text('Low stock only'),
                  selected: _lowStockOnly,
                  avatar: Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: _lowStockOnly ? Colors.white : AppColors.warning,
                  ),
                  selectedColor: AppColors.warning,
                  labelStyle: TextStyle(
                    color: _lowStockOnly ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (selected) {
                    setState(() => _lowStockOnly = selected);
                    _refresh();
                  },
                ),
              ),
            ),
            Expanded(
              child: _products.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                itemCount: _products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return _ProductTile(
                    product: product,
                    categoryName: _service.categoryNameFor(product.categoryId),
                    onTap: () => _openForm(product: product),
                    onDelete: () => _confirmDelete(product),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }

  Widget _buildLowStockBanner(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() => _lowStockOnly = true);
          _refresh();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  count == 1
                      ? '1 product is low on stock'
                      : '$count products are low on stock',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.warning, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasQuery = _searchController.text.trim().isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _lowStockOnly
                  ? Icons.check_circle_outline
                  : (hasQuery ? Icons.search_off : Icons.inventory_2_outlined),
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              _lowStockOnly
                  ? 'No low-stock products right now'
                  : (hasQuery ? 'No products match your search' : 'No products yet'),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            if (!hasQuery && !_lowStockOnly) ...[
              const SizedBox(height: 4),
              const Text(
                'Tap "Add Product" to create your first one',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  final String categoryName;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProductTile({
    required this.product,
    required this.categoryName,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final stockColor = product.isOutOfStock
        ? AppColors.error
        : (product.isLowStock ? AppColors.warning : AppColors.accent);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: product.isLowStock ? AppColors.warning.withValues(alpha: 0.5) : AppColors.border,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        onTap: onTap,
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Text(
            product.initial,
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  categoryName,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const Text('•', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(width: 6),
              Text(
                'Rs. ${product.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: stockColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                product.isOutOfStock ? 'Out of stock' : '${product.stockQty} in stock',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: stockColor),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}