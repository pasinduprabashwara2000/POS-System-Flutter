import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 84,
                      width: 84,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 42),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'POS System',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Version $_appVersion',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _sectionCard(
                title: 'About this App',
                icon: Icons.info_outline,
                child: const Text(
                  'POS System is a lightweight point-of-sale application built for small retail '
                      'businesses. It helps store staff manage products, categories, suppliers, and '
                      'customers, process sales, and keep an eye on stock levels — all from a single '
                      'mobile app.',
                  style: TextStyle(fontSize: 13.5, color: AppColors.textPrimary, height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Key Features',
                icon: Icons.star_outline,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _FeatureLine(icon: Icons.point_of_sale_rounded, text: 'Quick point-of-sale checkout with live cart'),
                    _FeatureLine(icon: Icons.inventory_2_outlined, text: 'Product catalogue with stock tracking'),
                    _FeatureLine(icon: Icons.warning_amber_rounded, text: 'Automatic low-stock reminders'),
                    _FeatureLine(icon: Icons.people_outline, text: 'Customer, category, and supplier management'),
                    _FeatureLine(icon: Icons.bar_chart_rounded, text: 'Sales reports and top-product insights'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Developed By',
                icon: Icons.person_outline,
                child: const Text(
                  'Developed as part of the Advanced Mobile Development module, BSc (Hons) in '
                      'Computing.',
                  style: TextStyle(fontSize: 13.5, color: AppColors.textPrimary, height: 1.5),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  '© 2026 POS System. All rights reserved.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _FeatureLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}