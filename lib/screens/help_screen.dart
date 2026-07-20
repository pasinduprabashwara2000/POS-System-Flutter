import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const List<_HelpTopic> _topics = [
    _HelpTopic(
      icon: Icons.point_of_sale_rounded,
      title: 'Making a Sale',
      steps: [
        'From the Dashboard, tap "New Sale".',
        'Select a customer from the dropdown (a customer is required for every sale).',
        'Search for products and tap the + button to add them to the cart.',
        'Adjust quantities with the +/- controls; you can\'t add more than what\'s in stock.',
        'Tap "Place Order" to complete the sale — stock is deducted automatically.',
      ],
    ),
    _HelpTopic(
      icon: Icons.inventory_2_outlined,
      title: 'Managing Products',
      steps: [
        'From the Dashboard, tap "Products".',
        'Tap "Add Product" to create a new one, or tap an existing product to edit it.',
        'Tap the photo circle at the top of the form to add a product photo from your camera or gallery.',
        'Set a "Low Stock Threshold" — you\'ll get a reminder once stock drops to or below it.',
        'Use the "Low stock only" filter chip to quickly see what needs reordering.',
      ],
    ),
    _HelpTopic(
      icon: Icons.warning_amber_rounded,
      title: 'Low Stock Reminders',
      steps: [
        'Products at or below their threshold are marked with an orange badge in the product list.',
        'A banner appears at the top of the Products screen summarising how many items are low.',
        'The Dashboard also shows a live "Low Stock" count — tap it to jump straight to the filtered list.',
      ],
    ),
    _HelpTopic(
      icon: Icons.people_outline,
      title: 'Customers, Categories & Suppliers',
      steps: [
        'Each of these has its own screen, reachable from the Dashboard or the menu.',
        'Use the search bar at the top of each list to quickly find an entry.',
        'Tap any entry to edit it, or use the delete option inside the edit screen to remove it.',
        'Every product must belong to a category; assigning a supplier is optional.',
      ],
    ),
    _HelpTopic(
      icon: Icons.receipt_long_outlined,
      title: 'Orders',
      steps: [
        'The Orders screen lists every completed sale, most recent first.',
        'Tap an order to see its full item list and total.',
        'Deleting an order automatically restocks every item it contained.',
      ],
    ),
    _HelpTopic(
      icon: Icons.bar_chart_rounded,
      title: 'Reports',
      steps: [
        'Choose a period at the top — Today, 7 Days, This Month, or All Time.',
        'The summary cards show total sales, order count, average order value, and items sold.',
        'Below that, see your top-selling products and a sales breakdown by category.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tap any topic below to see step-by-step guidance.',
                      style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ..._topics.map((topic) => _HelpTopicTile(topic: topic)),
            const SizedBox(height: 8),
            Container(
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
                  const Row(
                    children: [
                      Icon(Icons.support_agent, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Still need help?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This is a student prototype built for Advanced Mobile Development Assignment 02.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpTopic {
  final IconData icon;
  final String title;
  final List<String> steps;

  const _HelpTopic({required this.icon, required this.title, required this.steps});
}

class _HelpTopicTile extends StatelessWidget {
  final _HelpTopic topic;

  const _HelpTopicTile({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(topic.icon, color: AppColors.primary, size: 20),
          title: Text(topic.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...topic.steps.asMap().entries.map(
                  (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}