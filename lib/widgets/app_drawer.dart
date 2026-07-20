import 'package:flutter/material.dart';
import '../screens/about_screen.dart';
import '../screens/category/category_list_screen.dart';
import '../screens/customer/customer_list_screen.dart';
import '../screens/help_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/order/new_order_screen.dart';
import '../screens/order/order_list_screen.dart';
import '../screens/product/product_list_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/supplier/supplier_list_screen.dart';
import '../theme/app_theme.dart';

/// Global navigation menu shared across every main screen in the app.
///
/// Pass [currentRoute] so the drawer can highlight where the user
/// currently is (see [_DrawerRoute]). Any screen that includes this
/// drawer gets a hamburger icon in its AppBar automatically — that's
/// standard Scaffold behaviour once `drawer:` is set.
class AppDrawer extends StatelessWidget {
  final _DrawerRoute currentRoute;

  const AppDrawer({super.key, this.currentRoute = _DrawerRoute.none});

  static const dashboard = _DrawerRoute.dashboard;
  static const newSale = _DrawerRoute.newSale;
  static const products = _DrawerRoute.products;
  static const customers = _DrawerRoute.customers;
  static const categories = _DrawerRoute.categories;
  static const suppliers = _DrawerRoute.suppliers;
  static const orders = _DrawerRoute.orders;
  static const reports = _DrawerRoute.reports;
  static const about = _DrawerRoute.about;
  static const help = _DrawerRoute.help;

  void _navigate(BuildContext context, Widget screen, {bool replace = false}) {
    Navigator.of(context).pop(); // close the drawer first
    if (replace) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => screen));
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    }
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _item(context, Icons.dashboard_outlined, 'Dashboard', _DrawerRoute.dashboard,
                          () => _navigate(context, const HomeScreen(), replace: true)),
                  _item(context, Icons.point_of_sale_rounded, 'New Sale', _DrawerRoute.newSale,
                          () => _navigate(context, const NewOrderScreen())),
                  const Divider(height: 20),
                  _item(context, Icons.inventory_2_outlined, 'Products', _DrawerRoute.products,
                          () => _navigate(context, const ProductListScreen())),
                  _item(context, Icons.people_outline, 'Customers', _DrawerRoute.customers,
                          () => _navigate(context, const CustomerListScreen())),
                  _item(context, Icons.category_outlined, 'Categories', _DrawerRoute.categories,
                          () => _navigate(context, const CategoryListScreen())),
                  _item(context, Icons.local_shipping_outlined, 'Suppliers', _DrawerRoute.suppliers,
                          () => _navigate(context, const SupplierListScreen())),
                  _item(context, Icons.receipt_long_outlined, 'Orders', _DrawerRoute.orders,
                          () => _navigate(context, const OrderListScreen())),
                  _item(context, Icons.bar_chart_rounded, 'Reports', _DrawerRoute.reports,
                          () => _navigate(context, const ReportsScreen())),
                  const Divider(height: 20),
                  _item(context, Icons.info_outline, 'About', _DrawerRoute.about,
                          () => _navigate(context, const AboutScreen())),
                  _item(context, Icons.help_outline, 'Help', _DrawerRoute.help,
                          () => _navigate(context, const HelpScreen())),
                ],
              ),
            ),
            const Divider(height: 1),
            _item(context, Icons.logout, 'Logout', _DrawerRoute.none, () => _logout(context),
                iconColor: AppColors.error, textColor: AppColors.error),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POS System',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  'Store Management',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(
      BuildContext context,
      IconData icon,
      String label,
      _DrawerRoute route,
      VoidCallback onTap, {
        Color? iconColor,
        Color? textColor,
      }) {
    final isActive = route != _DrawerRoute.none && route == currentRoute;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Icon(icon, size: 20, color: isActive ? AppColors.primary : (iconColor ?? AppColors.textSecondary)),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.primary : (textColor ?? AppColors.textPrimary),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

enum _DrawerRoute {
  none,
  dashboard,
  newSale,
  products,
  customers,
  categories,
  suppliers,
  orders,
  reports,
  about,
  help,
}