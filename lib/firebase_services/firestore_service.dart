import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:myproject/helper/helper.dart';
import 'package:myproject/model/model_product.dart';

import '../helper/new_helper.dart';
import '../model/model_address.dart';
import '../model/model_admin_details.dart';
import '../model/model_cart_list.dart';
import '../model/model_shipping_details.dart';
import '../model/profile_model.dart';
import '../bottom_navigation_bar_screen.dart';

enum UpdateType { set, update }

class FirebaseFireStoreService {
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  static String cartCollection = "cart";
  static String orderCollection = "orders";
  static String productsCollection = "products";
  static String profileCollection = "profile_collection";
  static String addressCollection = "address_collection";
  // static String shippingCollection = "shipping_collection";
  final FirebaseAuth auth = FirebaseAuth.instance;
  final storageRef = FirebaseStorage.instance.ref();

  String get userId => auth.currentUser!.uid;
  bool get userLoggedIn => auth.currentUser != null;
  String get phoneNumber => auth.currentUser!.phoneNumber!;

  addToCart({
    required String productId,
    required Map<String, dynamic> productData,
  }) async {
    try {
      final response =
          await fireStore.collection(cartCollection).doc(userId).collection(productsCollection).doc(productId).get();
      if (response.exists) {
        showToast("Product Already Exists In Cart");
        return;
      }
      response.reference.set({
        "product_id": productId,
        "product_details": productData,
        "product_quantity": 1,
      }).then((value) {
        showToast("Product Added to cart");
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future updatePriceQuantity({
    required String productId,
    required int productQuantity,
  }) async {
    try {
      final response =
          await fireStore.collection(cartCollection).doc(userId).collection(productsCollection).doc(productId).get();
      if (response.exists) {
        await response.reference.update({"product_quantity": productQuantity}).then((value) {
          showToast("Product quantity Updated");
        });
      } else {
        showToast("Product do not exist");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future removeProduct({
    required String productId,
  }) async {
    try {
      final response =
          await fireStore.collection(cartCollection).doc(userId).collection(productsCollection).doc(productId).get();
      if (response.exists) {
        await response.reference.delete().then((value) {
          showToast("Product Removed");
        });
      } else {
        showToast("Product do not exist");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCartList() {
    return fireStore.collection(cartCollection).doc(userId).collection(productsCollection).snapshots();
  }

  Future<bool> checkUserProfile() async {
    final response = await fireStore.collection(profileCollection).doc(userId).get();
    if (response.exists) {
      return true;
    }
    return false;
  }

  Future<ModelProfileData?> getProfileDetails() async {
    final response = await fireStore.collection(profileCollection).doc(userId).get();
    if (response.exists) {
      log("Api Repsponse.....    ${jsonEncode(response.data())}");
      if (response.data() == null) return null;
      return ModelProfileData.fromJson(response.data()!);
    }
    return null;
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String address,
    required File profileImage,
    required bool allowChange,
    required BuildContext context,
    required Function(bool gg) updated,
  }) async {
    String profileUrl = profileImage.path;
    OverlayEntry loader = NewHelper.overlayLoader(context);
    try {
      if (allowChange) {
        Overlay.of(context).insert(loader);
        final userProfileImageRef = storageRef.child("user_images/$userId");
        UploadTask task6 = userProfileImageRef.putFile(profileImage);
        profileUrl = await (await task6).ref.getDownloadURL();
      }
      await fireStore.collection(profileCollection).doc(userId).set({
        "email": email,
        "name": name,
        "address": address,
        "profile": profileUrl,
      }).then((value) {
        showToast("Profile updated");
        updated(true);
        NewHelper.hideLoader(loader);
        return true;
      });
      NewHelper.hideLoader(loader);
      return false;
    } catch (e) {
      NewHelper.hideLoader(loader);
      throw Exception(e);
    } finally {
      NewHelper.hideLoader(loader);
    }
  }

  Future<bool> updateProduct({
    required String productId,
    required String name,
    required String description,
    required String price,
    required String category,
    required String deletePrevious,
    required File profileImage,
    required bool allowChange,
    required bool inStock,
    required BuildContext context,
    required Function(bool gg) updated,
  }) async {
    String profileUrl = profileImage.path;
    OverlayEntry loader = NewHelper.overlayLoader(context);
    try {
      if (allowChange) {
        Overlay.of(context).insert(loader);
        if (deletePrevious.isNotEmpty) {
          try {
            await FirebaseStorage.instance.refFromURL(deletePrevious).delete();
          } catch (e) {}
        }
        final userProfileImageRef = storageRef.child("product_image/${name}_${DateTime.now().millisecondsSinceEpoch}");
        UploadTask task6 = userProfileImageRef.putFile(profileImage);
        profileUrl = await (await task6).ref.getDownloadURL();
      }
      // name
      // price
      // imageUrl
      // description
      // category

      await fireStore.collection("products").doc(productId).set({
        "name": name,
        "price": price,
        "category": category,
        "inStock": inStock,
        "description": description,
        "imageUrl": profileUrl,
      }).then((value) {
        showToast("Product updated");
        updated(true);
        NewHelper.hideLoader(loader);
        return true;
      });
      NewHelper.hideLoader(loader);
      return false;
    } catch (e) {
      NewHelper.hideLoader(loader);
      throw Exception(e);
    } finally {
      NewHelper.hideLoader(loader);
    }
  }

  Future<ModelAddress?> getAddress() async {
    final response = await fireStore.collection(addressCollection).doc(userId).get();
    if (response.exists) {
      if (response.data() == null) return null;
      return ModelAddress.fromJson(response.data()!);
    }
    return null;
  }

  Future updateAddress({
    required String title,
    required String phone,
    required String city,
    required String address,
    required String landmark,
  }) async {
    try {
      await fireStore.collection(addressCollection).doc(userId).set({
        "title": title,
        "phone": phone,
        "city": city,
        "address": address,
        "landmark": landmark,
      }).then((value) {
        showToast("Address Updated");
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future updateOrdersDetails({
    required bool dispatch,
    required bool delivered,
    required String orderID,
    required Function(bool gg) updated,
  }) async {
    try {
      await fireStore.collection("orders").doc(orderID).update({
        "dispatch": dispatch,
        "delivered": delivered,
      }).then((value) {
        showToast("Order Updated");
        updated(true);
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<ModelShippingAddress?> getShippingDetails() async {
    try {
      final response = await fireStore.collection("shipping_collection").get();
      // print("Got Model Shipping address....     ${response.exists}");
      // print("Got Model Shipping address....     ${response.data()!}");
      // if (response.exists == false) return null;
      // if (response.data() == null) return null;
      if(response.docs.isEmpty)return null;
      final gg = ModelShippingAddress.fromJson(response.docs.first.data());
      return gg;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<ModelCityList?> getCityList() async {
    try {
      final response = await fireStore.collection("admin_details").doc("address_city").get();
      if (response.exists == false) return null;
      if (response.data() == null) return null;
      if (kDebugMode) {
        print(jsonEncode(response.data()));
      }
      return ModelCityList.fromJson(response.data()!);
      // return gg;
    } catch (e) {
      throw Exception(e);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getOrdersList() {
    return fireStore
        .collection(orderCollection)
        .where("user_id", isEqualTo: userId)
        .orderBy("orderTimeInMilliSec", descending: true)
        .limit(100)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAdminOrdersList({int? limit}) {
    return fireStore.collection(orderCollection).orderBy("orderTimeInMilliSec", descending: true).snapshots();
  }

  checkOutTransaction({
    required String shipping,
    required String total,
    required String transactionId,
    required String paymentMethod,
    required BuildContext context,
    required Map<String, dynamic> address,
  }) async {
    OverlayEntry loader = NewHelper.overlayLoader(context);
    Overlay.of(context).insert(loader);
    try {
      final cartListCollection = await fireStore.collection(cartCollection).doc(userId).collection("products").get();

      List<ModelCartList> cartList = cartListCollection.docs.map((e) => ModelCartList.fromJson(e.data())).toList();

      if (cartList.isEmpty) {
        showToast("Cart is empty");
        return;
      }

      final userInfo = await getProfileDetails();

      if (userInfo == null) {
        showToast("Invalid User");
        return;
      }

      await fireStore.collection(orderCollection).doc(DateTime.now().millisecondsSinceEpoch.toString()).set({
        "products_list": cartListCollection.docs.map((e) => e.data()).toList(),
        "total_amount": total,
        "sub_total": cartList.getTotalAmount,
        "shipping": shipping,
        "payment_method": paymentMethod,
        "address": address,
        "orderTimeInMilliSec": DateTime.now().millisecondsSinceEpoch,
        "transactionId": transactionId,
        "user_id": userId,
        "isCancelled": false,
        "delivered" : false,
        "dispatch" : false,
        "phone_number": phoneNumber,
        "user_details": userInfo.toJson(),
      }).then((value) async {
        await fireStore.collection(cartCollection).doc(userId).collection("products").get().then((value) async {
          for (var element in value.docs) {
            element.reference.delete();
          }
        });
        Get.offAll(() => const BottomNavigationScreen());
        showToast("Order Placed");
      });
    } catch (e) {
      NewHelper.hideLoader(loader);
      throw Exception(e);
    } finally {
      NewHelper.hideLoader(loader);
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllProducts() async {
    return await fireStore.collection("products").get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllProductsList() {
    return fireStore.collection("products").snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCategories() {
    return fireStore.collection("categories").snapshots();
  }

  Future<bool> checkAdminAccount() async {
    final response = await fireStore.collection("admin_details").doc("admin_info").get();
    if (response.exists) {
      if (response.data() == null) return false;
      log(jsonEncode(response.data()));
      if(auth.currentUser == null)return false;
      // log(auth.currentUser!.phoneNumber!.toString().simpleString);
      ModelAdminDetails modelAdminDetails = ModelAdminDetails.fromJson(response.data()!);
      if (modelAdminDetails.number!.contains(auth.currentUser!.phoneNumber.toString().simpleString)) {

        FirebaseMessaging.instance.getToken().then((token) {
          FirebaseFirestore.instance.collection('fcmtoken').doc("admin_token").set(
              {
                'fcmtoken' : token
              });
          print("FCM Token: $token");
        });
        auth.currentUser!.updateDisplayName("Admin");
        return true;
      } else {
        auth.currentUser!.updateDisplayName("User");
        return false;
      }
    } else {
      return false;
    }
  }

  Future<Product?> getProductDetails({
    required String productId,
  }) async {
    final response = await fireStore.collection("products").doc(productId).get();
    if (response.exists == false || response.data() == null) {
      return null;
    }
    return Product.fromMap(response.id, response.data()!);
  }
}

extension TrimString on String {
  String get simpleString {
    return replaceAll("+91", "");
  }
}
