import 'package:flutter/material.dart';
import '../../models/supplier.dart';
import '../../services/supplier_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_drawer.dart';
import 'supplier_form_screen.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  final SupplierService _service = SupplierService.instance;
  final TextEditingController _searchController = TextEditingController();
  List<Supplier> _suppliers = [];

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
      _suppliers = _service.search(_searchController.text);
    });
  }

  Future<void> _openForm({Supplier? supplier}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SupplierFormScreen(supplier: supplier)),
    );
    _refresh();
  }

  void _confirmDelete(Supplier supplier) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: Text('Are you sure you want to delete "${supplier.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _service.deleteSupplier(supplier.id);
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${supplier.name} deleted')),
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
    return Scaffold(
      drawer: const AppDrawer(currentRoute: AppDrawer.suppliers),
      appBar: AppBar(
        title: const Text('Suppliers'),
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
                  hintText: 'Search by name, contact, phone, or email',
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
            Expanded(
              child: _suppliers.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                itemCount: _suppliers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final supplier = _suppliers[index];
                  return _SupplierTile(
                    supplier: supplier,
                    onTap: () => _openForm(supplier: supplier),
                    onDelete: () => _confirmDelete(supplier),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_business_outlined),
        label: const Text('Add Supplier'),
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
              hasQuery ? Icons.search_off : Icons.local_shipping_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              hasQuery ? 'No suppliers match your search' : 'No suppliers yet',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            if (!hasQuery) ...[
              const SizedBox(height: 4),
              const Text(
                'Tap "Add Supplier" to create your first one',
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

class _SupplierTile extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SupplierTile({
    required this.supplier,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleParts = [
      if (supplier.contactPerson.isNotEmpty) supplier.contactPerson,
      if (supplier.phone.isNotEmpty) supplier.phone,
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        onTap: onTap,
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.accent.withValues(alpha: 0.14),
          child: Text(
            supplier.initial,
            style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          supplier.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: subtitleParts.isEmpty
            ? null
            : Text(
          subtitleParts.join(' • '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          onPressed: onDelete,
        ),
      ),
    );
  }
}