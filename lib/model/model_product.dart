import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String id;
  String name;
  double price;
  String description;
  String imageUrl;
  String category;
  String subcategory;
  bool inStock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.subcategory,
    this.inStock = false,
  });

  // Create a Product from Firestore document data
  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      price: double.tryParse(map['price'].toString()) ?? 0.0,
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      inStock: map['inStock'] ?? false,
    );
  }

  // Convert Product object to Firestore-compatible Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,  // ✅ Ensure stored as double
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'subcategory': subcategory,
      'inStock': inStock,
    };
  }

  // Create Product object from Firestore DocumentSnapshot
  static Product fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return Product(
      id: snap.id,
      name: data['name'] ?? '',
      price: double.tryParse(snap['price'].toString()) ?? 0.0,
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      subcategory: data['subcategory'] ?? '',
      inStock: data['inStock'] ?? false,
    );
  }
}
