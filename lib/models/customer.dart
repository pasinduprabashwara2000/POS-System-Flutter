/// Represents a customer record in the POS system.
class Customer {
  final String id;
  String name;
  String phone;
  String email;
  String address;
  DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.address = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Customer copyWith({
    String? name,
    String? phone,
    String? email,
    String? address,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      createdAt: createdAt,
    );
  }

  /// First letter used for the avatar circle in list views.
  String get initial => name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
}