import 'package:flutter/foundation.dart';
import '../models/supplier.dart';

/// In-memory supplier store for the POS app.
///
/// Singleton `ChangeNotifier` so any screen can listen for changes.
/// Swap the internal storage for a real database/API later without
/// changing the CRUD method signatures used by the UI.
class SupplierService extends ChangeNotifier {
  SupplierService._internal() {
    _seedData();
  }

  static final SupplierService instance = SupplierService._internal();

  final List<Supplier> _suppliers = [];
  int _nextId = 1;

  List<Supplier> get suppliers => List.unmodifiable(_suppliers);

  void _seedData() {
    _suppliers.addAll([
      Supplier(
        id: _generateId(),
        name: 'Lanka Distributors Pvt Ltd',
        contactPerson: 'Ruwan Fernando',
        phone: '0112345678',
        email: 'ruwan@lankadist.lk',
        address: 'Colombo, Sri Lanka',
      ),
      Supplier(
        id: _generateId(),
        name: 'Wadduwa Wholesale Traders',
        contactPerson: 'Sanduni Jayasuriya',
        phone: '0342233445',
        email: 'sanduni@wwtraders.lk',
        address: 'Wadduwa, Sri Lanka',
      ),
    ]);
  }

  String _generateId() => 'SUP${(_nextId++).toString().padLeft(4, '0')}';

  // ---------- CREATE ----------
  Supplier addSupplier({
    required String name,
    String contactPerson = '',
    String phone = '',
    String email = '',
    String address = '',
  }) {
    final supplier = Supplier(
      id: _generateId(),
      name: name.trim(),
      contactPerson: contactPerson.trim(),
      phone: phone.trim(),
      email: email.trim(),
      address: address.trim(),
    );
    _suppliers.insert(0, supplier);
    notifyListeners();
    return supplier;
  }

  // ---------- READ ----------
  List<Supplier> getAll() => List.unmodifiable(_suppliers);

  Supplier? getById(String id) {
    try {
      return _suppliers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Supplier> search(String query) {
    if (query.trim().isEmpty) return getAll();
    final q = query.trim().toLowerCase();
    return _suppliers.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.contactPerson.toLowerCase().contains(q) ||
          s.phone.toLowerCase().contains(q) ||
          s.email.toLowerCase().contains(q);
    }).toList();
  }

  // ---------- UPDATE ----------
  bool updateSupplier(
      String id, {
        required String name,
        required String contactPerson,
        required String phone,
        required String email,
        required String address,
      }) {
    final index = _suppliers.indexWhere((s) => s.id == id);
    if (index == -1) return false;
    _suppliers[index] = _suppliers[index].copyWith(
      name: name.trim(),
      contactPerson: contactPerson.trim(),
      phone: phone.trim(),
      email: email.trim(),
      address: address.trim(),
    );
    notifyListeners();
    return true;
  }

  // ---------- DELETE ----------
  bool deleteSupplier(String id) {
    final index = _suppliers.indexWhere((s) => s.id == id);
    if (index == -1) return false;
    _suppliers.removeAt(index);
    notifyListeners();
    return true;
  }
}