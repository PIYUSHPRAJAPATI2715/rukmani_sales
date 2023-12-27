import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myproject/helper/new_helper.dart';

class Product {
  String id; // Document ID from Firestore
  String name;
  double price;
  String description;
  String imageUrl;
  String category;
  bool? inStock;

  Product({
    required this.id,
    required this.name,
    this.inStock,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
  });

  // Factory method to create a Product object from a map and document ID
  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      inStock: map['inStock'] ?? false,
      price: map['price'].toString().toNum.toDouble(),
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
    );
  }
  static Product fromSnapshot(DocumentSnapshot snap) {
    Product product = Product(
      name: snap['name'],
      price: snap['price'],
      inStock: snap['inStock'],
      imageUrl: snap['imageUrl'],
      description: snap['description'],
      id: snap['id'],
      category: snap['category'],
    );
    return product;
  }
}
