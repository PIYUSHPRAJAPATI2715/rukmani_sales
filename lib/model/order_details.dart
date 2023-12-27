import 'model_address.dart';

class ModelOrderDetails {
  String orderId = "";
  dynamic orderTimeInMilliSec;
  dynamic shipping;
  ModelAddress? address;
  dynamic totalAmount;
  dynamic userId;
  UserDetails? userDetails;
  dynamic subTotal;
  List<ProductsList>? productsList;
  dynamic phoneNumber;
  dynamic transactionId;
  dynamic paymentMethod;
  bool? dispatch = false;
  bool? delivered = false;
  bool? isCancelled = false;

  ModelOrderDetails(
      {this.orderTimeInMilliSec,
      this.shipping,
      required this.orderId,
      this.dispatch,
      this.delivered,
      this.isCancelled,
      this.totalAmount,
      this.paymentMethod,
      this.userId,
      this.userDetails,
      this.address,
      this.subTotal,
      this.productsList,
      this.phoneNumber,
      this.transactionId});

  ModelOrderDetails.fromJson(Map<String, dynamic> json, givenOrderId) {
    orderId = givenOrderId;
    orderTimeInMilliSec = json['orderTimeInMilliSec'];
    shipping = json['shipping'];
    dispatch = json['dispatch'] ?? false;
    delivered = json['delivered'] ?? false;
    isCancelled = json['isCancelled'] ?? false;
    paymentMethod = json['payment_method'];
    totalAmount = json['total_amount'];
    userId = json['user_id'];
    userDetails = json['user_details'] != null ? UserDetails.fromJson(json['user_details']) : null;
    address = json['address'] != null ? ModelAddress.fromJson(json['address']) : null;
    subTotal = json['sub_total'];
    if (json['products_list'] != null) {
      productsList = <ProductsList>[];
      json['products_list'].forEach((v) {
        productsList!.add(ProductsList.fromJson(v));
      });
    }
    phoneNumber = json['phone_number'];
    transactionId = json['transactionId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderTimeInMilliSec'] = orderTimeInMilliSec;
    data['shipping'] = shipping;
    data['payment_method'] = paymentMethod;
    data['total_amount'] = totalAmount;
    data['user_id'] = userId;
    if (userDetails != null) {
      data['user_details'] = userDetails!.toJson();
    }
    if (address != null) {
      data['user_details'] = address!.toJson();
    }
    data['sub_total'] = subTotal;
    if (productsList != null) {
      data['products_list'] = productsList!.map((v) => v.toJson()).toList();
    }
    data['phone_number'] = phoneNumber;
    data['transactionId'] = transactionId;
    return data;
  }
}

class UserDetails {
  dynamic address;
  dynamic profile;
  dynamic name;
  dynamic email;

  UserDetails({this.address, this.profile, this.name, this.email});

  UserDetails.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    profile = json['profile'];
    name = json['name'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['profile'] = profile;
    data['name'] = name;
    data['email'] = email;
    return data;
  }
}

class ProductsList {
  dynamic productId;
  ProductDetails? productDetails;
  dynamic productQuantity;

  ProductsList({this.productId, this.productDetails, this.productQuantity});

  ProductsList.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    productDetails = json['product_details'] != null ? ProductDetails.fromJson(json['product_details']) : null;
    productQuantity = json['product_quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    if (productDetails != null) {
      data['product_details'] = productDetails!.toJson();
    }
    data['product_quantity'] = productQuantity;
    return data;
  }
}

class ProductDetails {
  dynamic price;
  dynamic imageUrl;
  dynamic name;
  dynamic description;
  dynamic category;

  ProductDetails({this.price, this.imageUrl, this.name, this.description, this.category});

  ProductDetails.fromJson(Map<String, dynamic> json) {
    price = json['price'];
    imageUrl = json['imageUrl'];
    name = json['name'];
    description = json['description'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['price'] = price;
    data['imageUrl'] = imageUrl;
    data['name'] = name;
    data['description'] = description;
    data['category'] = category;
    return data;
  }
}
