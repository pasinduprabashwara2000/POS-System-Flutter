import 'package:flutter/foundation.dart' hide Category;
import '../models/category.dart';

/// In-memory category store for the POS app.
///
/// Singleton `ChangeNotifier` so any screen can listen for changes.
/// Swap the internal storage for a real database/API later without
/// changing the CRUD method signatures used by the UI.
class CategoryService extends ChangeNotifier {
  CategoryService._internal() {
    _seedData();
  }

  static final CategoryService instance = CategoryService._internal();

  final List<Category> _categories = [];
  int _nextId = 1;

  List<Category> get categories => List.unmodifiable(_categories);

  void _seedData() {
    _categories.addAll([
      Category(id: _generateId(), name: 'Beverages', description: 'Soft drinks, juices, water'),
      Category(id: _generateId(), name: 'Groceries', description: 'Everyday grocery items'),
      Category(id: _generateId(), name: 'Electronics', description: 'Gadgets and accessories'),
    ]);
  }

  String _generateId() => 'CAT${(_nextId++).toString().padLeft(4, '0')}';

  // ---------- CREATE ----------
  Category addCategory({required String name, String description = ''}) {
    final category = Category(
      id: _generateId(),
      name: name.trim(),
      description: description.trim(),
    );
    _categories.insert(0, category);
    notifyListeners();
    return category;
  }

  // ---------- READ ----------
  List<Category> getAll() => List.unmodifiable(_categories);

  Category? getById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Category> search(String query) {
    if (query.trim().isEmpty) return getAll();
    final q = query.trim().toLowerCase();
    return _categories.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q);
    }).toList();
  }

  // ---------- UPDATE ----------
  bool updateCategory(String id, {required String name, required String description}) {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) return false;
    _categories[index] = _categories[index].copyWith(
      name: name.trim(),
      description: description.trim(),
    );
    notifyListeners();
    return true;
  }

  // ---------- DELETE ----------
  bool deleteCategory(String id) {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) return false;
    _categories.removeAt(index);
    notifyListeners();
    return true;
  }
}