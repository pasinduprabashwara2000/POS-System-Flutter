import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../services/category_service.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';
import '../../theme/app_theme.dart';
import '../product/product_list_screen.dart';

enum _ReportPeriod { today, week, month, all }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  _ReportPeriod _period = _ReportPeriod.week;

  List<Order> _filteredOrders() {
    final all = OrderService.instance.getAll();
    final now = DateTime.now();

    switch (_period) {
      case _ReportPeriod.today:
        return all.where((o) => o.isToday).toList();
      case _ReportPeriod.week:
        final cutoff = now.subtract(const Duration(days: 7));
        return all.where((o) => o.createdAt.isAfter(cutoff)).toList();
      case _ReportPeriod.month:
        return all
            .where((o) => o.createdAt.year == now.year && o.createdAt.month == now.month)
            .toList();
      case _ReportPeriod.all:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filteredOrders();

    final totalSales = orders.fold(0.0, (sum, o) => sum + o.totalAmount);
    final totalOrders = orders.length;
    final itemsSold = orders.fold(0, (sum, o) => sum + o.itemCount);
    final avgOrderValue = totalOrders > 0 ? totalSales / totalOrders : 0.0;

    final topProducts = _topProducts(orders);
    final categorySales = _salesByCategory(orders);
    final lowStock = ProductService.instance.lowStockProducts;

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 20),
            _buildSummaryGrid(totalSales, totalOrders, avgOrderValue, itemsSold),
            const SizedBox(height: 28),
            _sectionHeader('Top Selling Products'),
            const SizedBox(height: 10),
            topProducts.isEmpty
                ? _emptyHint('No sales in this period yet')
                : _buildBarList(
              entries: topProducts
                  .map((p) => _BarEntry(label: p.name, value: p.qty.toDouble(), sublabel: 'Rs. ${p.revenue.toStringAsFixed(2)}'))
                  .toList(),
              color: AppColors.primary,
              valueSuffix: ' sold',
            ),
            const SizedBox(height: 28),
            _sectionHeader('Sales by Category'),
            const SizedBox(height: 10),
            categorySales.isEmpty
                ? _emptyHint('No sales in this period yet')
                : _buildBarList(
              entries: categorySales
                  .map((c) => _BarEntry(label: c.name, value: c.revenue))
                  .toList(),
              color: AppColors.accent,
              valuePrefix: 'Rs. ',
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionHeader('Low Stock Alerts'),
                if (lowStock.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProductListScreen()),
                      );
                    },
                    child: const Text('View all'),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            lowStock.isEmpty
                ? _emptyHint('Everything is well stocked 🎉')
                : Column(
              children: lowStock.take(5).map((p) => _buildLowStockTile(p)).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ---------- data aggregation ----------

  List<_ProductAggregate> _topProducts(List<Order> orders) {
    final Map<String, _ProductAggregate> map = {};
    for (final order in orders) {
      for (final item in order.items) {
        final existing = map[item.productId];
        if (existing == null) {
          map[item.productId] = _ProductAggregate(
            name: item.productName,
            qty: item.quantity,
            revenue: item.subtotal,
          );
        } else {
          existing.qty += item.quantity;
          existing.revenue += item.subtotal;
        }
      }
    }
    final list = map.values.toList()..sort((a, b) => b.qty.compareTo(a.qty));
    return list.take(5).toList();
  }

  List<_CategoryAggregate> _salesByCategory(List<Order> orders) {
    final Map<String, _CategoryAggregate> map = {};
    for (final order in orders) {
      for (final item in order.items) {
        final product = ProductService.instance.getById(item.productId);
        final categoryName = product != null
            ? CategoryService.instance.getById(product.categoryId)?.name ?? 'Uncategorized'
            : 'Uncategorized';
        final existing = map[categoryName];
        if (existing == null) {
          map[categoryName] = _CategoryAggregate(name: categoryName, revenue: item.subtotal);
        } else {
          existing.revenue += item.subtotal;
        }
      }
    }
    final list = map.values.toList()..sort((a, b) => b.revenue.compareTo(a.revenue));
    return list;
  }

  // ---------- UI pieces ----------

  Widget _buildPeriodSelector() {
    final options = {
      _ReportPeriod.today: 'Today',
      _ReportPeriod.week: '7 Days',
      _ReportPeriod.month: 'This Month',
      _ReportPeriod.all: 'All Time',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.entries.map((entry) {
          final selected = _period == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: selected,
              onSelected: (_) => setState(() => _period = entry.key),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryGrid(
      double totalSales,
      int totalOrders,
      double avgOrderValue,
      int itemsSold,
      ) {
    final items = [
      _SummaryItem('Total Sales', 'Rs. ${totalSales.toStringAsFixed(2)}', Icons.trending_up, AppColors.accent),
      _SummaryItem('Orders', '$totalOrders', Icons.receipt_long, AppColors.primary),
      _SummaryItem('Avg. Order Value', 'Rs. ${avgOrderValue.toStringAsFixed(2)}', Icons.bar_chart_rounded, Colors.indigo),
      _SummaryItem('Items Sold', '$itemsSold', Icons.shopping_bag_outlined, Colors.orange),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 100,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(item.icon, color: item.color, size: 20),
              Text(
                item.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary));
  }

  Widget _emptyHint(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
    );
  }

  Widget _buildBarList({
    required List<_BarEntry> entries,
    required Color color,
    String valuePrefix = '',
    String valueSuffix = '',
  }) {
    final maxValue = entries.map((e) => e.value).fold(0.0, (a, b) => a > b ? a : b);

    return Column(
      children: entries.map((entry) {
        final fraction = maxValue > 0 ? (entry.value / maxValue).clamp(0.0, 1.0) : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.sublabel ?? '$valuePrefix${entry.value.toStringAsFixed(entry.value % 1 == 0 ? 0 : 2)}$valueSuffix',
                    style: TextStyle(fontSize: 12.5, color: color, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(height: 8, width: constraints.maxWidth, color: AppColors.border),
                        Container(height: 8, width: constraints.maxWidth * fraction, color: color),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLowStockTile(Product product) {
    final isOut = product.stockQty <= 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            isOut ? Icons.remove_shopping_cart_outlined : Icons.warning_amber_rounded,
            color: isOut ? AppColors.error : AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (isOut ? AppColors.error : AppColors.warning).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isOut ? 'Out of stock' : '${product.stockQty} left',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isOut ? AppColors.error : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  _SummaryItem(this.label, this.value, this.icon, this.color);
}

class _ProductAggregate {
  final String name;
  int qty;
  double revenue;

  _ProductAggregate({required this.name, required this.qty, required this.revenue});
}

class _CategoryAggregate {
  final String name;
  double revenue;

  _CategoryAggregate({required this.name, required this.revenue});
}

class _BarEntry {
  final String label;
  final double value;
  final String? sublabel;

  _BarEntry({required this.label, required this.value, this.sublabel});
}