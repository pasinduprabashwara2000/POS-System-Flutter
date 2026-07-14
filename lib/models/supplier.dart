/// Represents a supplier/vendor record in the POS system.
class Supplier {
  final String id;
  String name;
  String contactPerson;
  String phone;
  String email;
  String address;
  DateTime createdAt;

  Supplier({
    required this.id,
    required this.name,
    this.contactPerson = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Supplier copyWith({
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
  }) {
    return Supplier(
      id: id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      createdAt: createdAt,
    );
  }

  String get initial => name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
}