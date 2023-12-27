// To parse this JSON data, do
//
//     final modelCartList = modelCartListFromJson(jsonString);
import 'package:collection/collection.dart';
import 'dart:convert';

import 'package:myproject/helper/new_helper.dart';

extension GetTotal on List<ModelCartList> {
  num get getTotalAmount {
    return map((e) => e.productQuantity.toString().toNum * e.productDetails!.price.toString().toNum).toList().sum;
  }
}

class ModelCartList {
  final dynamic productId;
  final ProductDetails? productDetails;
  final dynamic productQuantity;
  bool? inStock;

  ModelCartList({
    this.productId,
    this.productDetails,
    this.inStock,
    this.productQuantity,
  });

  factory ModelCartList.fromRawJson(String str) => ModelCartList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ModelCartList.fromJson(Map<String, dynamic> json) => ModelCartList(
        productId: json["product_id"],
        productDetails: json["product_details"] == null ? null : ProductDetails.fromJson(json["product_details"]),
        productQuantity: json["product_quantity"],
      );

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "product_details": productDetails?.toJson(),
        "product_quantity": productQuantity,
      };
}

class ProductDetails {
  final dynamic price;
  final dynamic imageUrl;
  final dynamic name;
  final dynamic description;

  ProductDetails({
    this.price,
    this.imageUrl,
    this.name,
    this.description,
  });

  factory ProductDetails.fromRawJson(String str) => ProductDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductDetails.fromJson(Map<String, dynamic> json) => ProductDetails(
        price: json["price"],
        imageUrl: json["imageUrl"],
        name: json["name"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "price": price,
        "imageUrl": imageUrl,
        "name": name,
        "description": description,
      };
}
