/// Represents a product category in the POS system.
class Category {
  final String id;
  String name;
  String description;
  DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.description = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Category copyWith({
    String? name,
    String? description,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
    );
  }

  String get initial => name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
}