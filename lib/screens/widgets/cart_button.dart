import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import 'package:myproject/helper/new_helper.dart';
import '../../firebase_services/firestore_service.dart';
import '../../model/model_cart_list.dart';
import '../home_screens/cart_screen.dart';

class CartButton extends StatefulWidget {
  const CartButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<CartButton> createState() => _CartButtonState();
}

class _CartButtonState extends State<CartButton> {
  FirebaseFireStoreService fireStoreService = FirebaseFireStoreService();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: fireStoreService.auth.currentUser != null
          ? StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: fireStoreService.getCartList(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<ModelCartList> cartList = [];
                  if (snapshot.data == null) return const SizedBox();
                  // log(snapshot.data!.docs.map((e) => jsonEncode(e.data())).toList().toString());
                  cartList = snapshot.data!.docs.map((e) => ModelCartList.fromJson(e.data())).toList();
                  int totalAmount = cartList.map((e) => e.productQuantity!.toString().toNum).toList().sum.toInt();

                  return Badge(
                    offset: const Offset(-5, 4),
                    label: Text(totalAmount.toString()),
                    child: IconButton(onPressed: widget.onPressed, icon: const Icon(Icons.card_travel)),
                  );
                }
                return Badge(
                  child: IconButton(
                      onPressed: () {
                        Get.to(() => const CartScreen());
                      },
                      icon: const Icon(Icons.card_travel)),
                );
              })
          : const SizedBox.shrink(),
    );
  }
}
