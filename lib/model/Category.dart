import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String id;
  String name;
  String imageUrl;
  List<String> subcategories;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.subcategories,
  });

  // Convert Firestore document to Category object
  factory Category.fromMap(String id, Map<String, dynamic> map) {
    print("Raw Firestore Data: $map"); // Debugging print
    return Category(
      id: id,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      subcategories: (map.containsKey('subcategories') && map['subcategories'] is List)
          ? List<String>.from(map['subcategories'])
          : [],
    );
  }

}
