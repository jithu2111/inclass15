import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  // Fields
  final String? id;
  final String name;
  final int quantity;
  final double price;
  final String category;
  final DateTime createdAt;

  // Constructor with named parameters
  Item({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.category,
    required this.createdAt,
  });

  // Convert Item object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt), // Convert DateTime to Timestamp
    };
  }

  // Create Item object from Firestore document
  factory Item.fromMap(String id, Map<String, dynamic> map) {
    return Item(
      id: id,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      price: (map['price'] as num).toDouble(), // Handle both int and double
      category: map['category'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(), // Convert Timestamp to DateTime
    );
  }

  // Optional: Create a copyWith method for easy updates
  Item copyWith({
    String? id,
    String? name,
    int? quantity,
    double? price,
    String? category,
    DateTime? createdAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}