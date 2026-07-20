import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';
import '../../services/supplier_service.dart';
import '../../theme/app_theme.dart';

/// Single form used for both creating a new product and editing an
/// existing one. Pass [product] to edit; leave it null to create.
class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  bool get isEditing => product != null;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _thresholdController;
  late final TextEditingController _descriptionController;

  String? _categoryId;
  String? _supplierId;
  String? _imagePath; // local file path of the picked/existing product photo
  bool _isSaving = false;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _skuController = TextEditingController(text: p?.sku ?? '');
    _priceController = TextEditingController(text: p != null ? p.price.toString() : '');
    _stockController = TextEditingController(text: p != null ? p.stockQty.toString() : '');
    _thresholdController =
        TextEditingController(text: p != null ? p.lowStockThreshold.toString() : '5');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _categoryId = p?.categoryId;
    _supplierId = p?.supplierId;
    _imagePath = p?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _thresholdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isPickingImage = true);
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() => _imagePath = picked.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not access image source: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined, color: AppColors.primary),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_imagePath != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  title: const Text('Remove Photo', style: TextStyle(color: AppColors.error)),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    setState(() => _imagePath = null);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _save() {
    final formValid = _formKey.currentState!.validate();
    if (!formValid || _categoryId == null) {
      if (_categoryId == null) {
        setState(() {}); // trigger dropdown validator display
      }
      return;
    }

    setState(() => _isSaving = true);

    final service = ProductService.instance;
    final price = double.parse(_priceController.text.trim());
    final stockQty = int.parse(_stockController.text.trim());
    final threshold = int.parse(_thresholdController.text.trim());

    if (widget.isEditing) {
      service.updateProduct(
        widget.product!.id,
        name: _nameController.text,
        sku: _skuController.text,
        categoryId: _categoryId!,
        supplierId: _supplierId,
        price: price,
        stockQty: stockQty,
        lowStockThreshold: threshold,
        description: _descriptionController.text,
        imagePath: _imagePath,
        clearImage: _imagePath == null,
      );
    } else {
      service.addProduct(
        name: _nameController.text,
        sku: _skuController.text,
        categoryId: _categoryId!,
        supplierId: _supplierId,
        price: price,
        stockQty: stockQty,
        lowStockThreshold: threshold,
        description: _descriptionController.text,
        imagePath: _imagePath,
      );
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final categories = CategoryService.instance.getAll();
    final suppliers = SupplierService.instance.getAll();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Product' : 'Add Product'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImagePicker(),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Product Name *',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _skuController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'SKU / Code',
                    prefixIcon: Icon(Icons.qr_code_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                if (categories.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'No categories yet. Add a category first so this product can be assigned to one.',
                            style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: _categoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category *',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: categories
                        .map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name)))
                        .toList(),
                    onChanged: (value) => setState(() => _categoryId = value),
                    validator: (value) => value == null ? 'Please select a category' : null,
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  initialValue: _supplierId,
                  decoration: const InputDecoration(
                    labelText: 'Supplier (optional)',
                    prefixIcon: Icon(Icons.local_shipping_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('None')),
                    ...suppliers.map(
                          (sup) => DropdownMenuItem<String?>(value: sup.id, child: Text(sup.name)),
                    ),
                  ],
                  onChanged: (value) => setState(() => _supplierId = value),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Price (Rs.) *',
                          prefixIcon: Icon(Icons.payments_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Required';
                          final parsed = double.tryParse(value.trim());
                          if (parsed == null || parsed < 0) return 'Invalid price';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Stock Qty *',
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Required';
                          final parsed = int.tryParse(value.trim());
                          if (parsed == null || parsed < 0) return 'Invalid qty';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _thresholdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Low Stock Threshold *',
                    prefixIcon: Icon(Icons.warning_amber_outlined),
                    helperText: 'You\'ll get a low-stock reminder at or below this quantity',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Required';
                    final parsed = int.tryParse(value.trim());
                    if (parsed == null || parsed < 0) return 'Invalid threshold';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                      : Text(widget.isEditing ? 'Update Product' : 'Save Product'),
                ),
                if (widget.isEditing) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    label: const Text(
                      'Delete Product',
                      style: TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _isPickingImage ? null : _showImageSourceSheet,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border, width: 1.4),
              ),
              clipBehavior: Clip.antiAlias,
              child: _isPickingImage
                  ? const Center(
                child: CircularProgressIndicator(strokeWidth: 2.4),
              )
                  : (_imagePath != null
                  ? Image.file(
                File(_imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 36,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
                  : const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 30,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Add Photo',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )),
            ),
            if (_imagePath != null)
              Positioned(
                right: -8,
                top: -8,
                child: GestureDetector(
                  onTap: () => setState(() => _imagePath = null),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${widget.product!.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ProductService.instance.deleteProduct(widget.product!.id);
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop(true);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}