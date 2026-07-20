import 'package:flutter/material.dart';
import 'package:ma2/screens/supplier/supplier_list_screen.dart';
import '../services/customer_service.dart';
import '../services/order_service.dart';
import '../services/product_service.dart';
import '../theme/app_theme.dart';
import 'category/category_list_screen.dart';
import 'customer/customer_list_screen.dart';
import 'login_screen.dart';
import 'order/new_order_screen.dart';
import 'order/order_list_screen.dart';
import 'product/product_list_screen.dart';
import 'reports/reports_screen.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  Future<void> _openCustomers() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CustomerListScreen()),
    );
    // Refresh stats (e.g. customer count) after returning.
    if (mounted) setState(() {});
  }

  Future<void> _openCategories() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CategoryListScreen()),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openSuppliers() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SupplierListScreen()),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openProducts() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProductListScreen()),
    );
    // Refresh stats (product count, low-stock count) after returning.
    if (mounted) setState(() {});
  }

  Future<void> _openNewSale() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewOrderScreen()),
    );
    // Refresh stats (today's sales/orders, stock levels) after returning.
    if (mounted) setState(() {});
  }

  Future<void> _openOrders() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OrderListScreen()),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openReports() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ReportsScreen()),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: AppDrawer.dashboard),
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(context),
              const SizedBox(height: 24),
              _buildStatsGrid(context),
              const SizedBox(height: 28),
              Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Here\'s what\'s happening in your store today',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final productService = ProductService.instance;
    final orderService = OrderService.instance;
    final lowStockCount = productService.lowStockCount;

    final stats = [
      _StatItem(
        'Today\'s Sales',
        'Rs. ${orderService.todaysSalesTotal.toStringAsFixed(2)}',
        Icons.trending_up,
        AppColors.accent,
      ),
      _StatItem(
        'Orders',
        '${orderService.todaysOrderCount}',
        Icons.receipt_long,
        AppColors.primary,
      ),
      _StatItem(
        'Products',
        '${productService.products.length}',
        Icons.inventory_2_outlined,
        Colors.orange,
      ),
      _StatItem(
        'Customers',
        '${CustomerService.instance.customers.length}',
        Icons.people_outline,
        Colors.purple,
      ),
      _StatItem(
        'Low Stock',
        '$lowStockCount',
        Icons.warning_amber_rounded,
        lowStockCount > 0 ? AppColors.warning : AppColors.textSecondary,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      // Fixed pixel height per row instead of childAspectRatio.
      // childAspectRatio derives height from the available width, so on
      // narrower screens or with larger system font scale the fixed-size
      // content (icon + value + label) no longer fits -> bottom overflow.
      // mainAxisExtent gives a deterministic height that always fits.
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 120,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        final isLowStockCard = stat.label == 'Low Stock' && lowStockCount > 0;
        VoidCallback? onTap;
        switch (stat.label) {
          case 'Products':
            onTap = _openProducts;
            break;
          case 'Low Stock':
            if (isLowStockCard) onTap = _openProducts;
            break;
          case 'Today\'s Sales':
          case 'Orders':
            onTap = _openOrders;
            break;
        }
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLowStockCard ? AppColors.warning.withValues(alpha: 0.06) : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isLowStockCard ? AppColors.warning.withValues(alpha: 0.4) : AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: stat.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(stat.icon, color: stat.color, size: 20),
                ),
                Text(
                  stat.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  stat.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _ActionItem('New Sale', Icons.point_of_sale_rounded, AppColors.primary, _openNewSale),
      _ActionItem('Products', Icons.inventory_2_outlined, Colors.orange, _openProducts),
      _ActionItem('Customers', Icons.people_outline, Colors.purple, _openCustomers),
      _ActionItem('Categories', Icons.category_outlined, Colors.teal, _openCategories),
      _ActionItem('Suppliers', Icons.local_shipping_outlined, AppColors.accent, _openSuppliers),
      _ActionItem('Reports', Icons.bar_chart_rounded, Colors.indigo, _openReports),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      // Same fix: fixed row height instead of an aspect ratio.
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 68,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: action.onTap ??
                  () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${action.label} coming soon')),
                );
              },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(action.icon, color: action.color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    action.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  _StatItem(this.label, this.value, this.icon, this.color);
}

class _ActionItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  _ActionItem(this.label, this.icon, this.color, this.onTap);
}