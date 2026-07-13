import 'package:flutter/foundation.dart';
import '../models/customer.dart';

/// In-memory customer store for the POS app.
///
/// This is a singleton `ChangeNotifier` so any screen can listen for
/// changes. Swap the internal storage for a real database/API later
/// without changing the CRUD method signatures used by the UI.
class CustomerService extends ChangeNotifier {
  CustomerService._internal() {
    _seedData();
  }

  static final CustomerService instance = CustomerService._internal();

  final List<Customer> _customers = [];
  int _nextId = 1;

  List<Customer> get customers => List.unmodifiable(_customers);

  void _seedData() {
    _customers.addAll([
      Customer(
        id: _generateId(),
        name: 'Nimal Perera',
        phone: '0771234567',
        email: 'nimal@example.com',
        address: 'Negombo, Sri Lanka',
      ),
      Customer(
        id: _generateId(),
        name: 'Kamala Silva',
        phone: '0719876543',
        email: 'kamala@example.com',
        address: 'Wadduwa, Sri Lanka',
      ),
    ]);
  }

  String _generateId() => 'C${(_nextId++).toString().padLeft(4, '0')}';

  // ---------- CREATE ----------
  Customer addCustomer({
    required String name,
    String phone = '',
    String email = '',
    String address = '',
  }) {
    final customer = Customer(
      id: _generateId(),
      name: name.trim(),
      phone: phone.trim(),
      email: email.trim(),
      address: address.trim(),
    );
    _customers.insert(0, customer);
    notifyListeners();
    return customer;
  }

  // ---------- READ ----------
  List<Customer> getAll() => List.unmodifiable(_customers);

  Customer? getById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Customer> search(String query) {
    if (query.trim().isEmpty) return getAll();
    final q = query.trim().toLowerCase();
    return _customers.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q);
    }).toList();
  }

  // ---------- UPDATE ----------
  bool updateCustomer(
      String id, {
        required String name,
        required String phone,
        required String email,
        required String address,
      }) {
    final index = _customers.indexWhere((c) => c.id == id);
    if (index == -1) return false;
    _customers[index] = _customers[index].copyWith(
      name: name.trim(),
      phone: phone.trim(),
      email: email.trim(),
      address: address.trim(),
    );
    notifyListeners();
    return true;
  }

  // ---------- DELETE ----------
  bool deleteCustomer(String id) {
    final index = _customers.indexWhere((c) => c.id == id);
    if (index == -1) return false;
    _customers.removeAt(index);
    notifyListeners();
    return true;
  }
}