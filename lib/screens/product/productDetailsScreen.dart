import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myproject/helper/helper.dart';
import 'package:myproject/model/model_product.dart';
import 'package:myproject/screens/auth/signup.dart';

import '../../firebase_services/firestore_service.dart';
import '../home_screens/cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // FirebaseAuth? auth;
  FirebaseFireStoreService fireStoreService = FirebaseFireStoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: fireStoreService.fireStore.collection('products').doc(widget.productId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final productData = snapshot.data!.data()!;
            final product = Product.fromMap(widget.productId, productData);
            bool canBuy = product.inStock == true;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    product.imageUrl,
                    height: 300,
                    width: Get.width,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Price: \₹ ${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            product.inStock == true
                                ? Text(
                                    "InStock",
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500, color: Colors.greenAccent.shade700),
                                  )
                                : Text(
                                    "Out of Stock",
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500, color: Colors.redAccent.shade700),
                                  )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 50,
                      width: Get.width,
                      child: ElevatedButton(
                          onPressed: () {
                            if (!fireStoreService.userLoggedIn) {
                              Get.to(() => const SignUpScreen());
                              return;
                            }
                            if (canBuy == false) {
                              showToast("Product is out of stock");
                              return;
                            }
                            fireStoreService.addToCart(
                                productId: product.id.trim().toString(), productData: productData);
                          },
                          child: const Text("Add to cart")),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 50,
                      width: Get.width,
                      child: ElevatedButton(
                          onPressed: () {
                            if (!fireStoreService.userLoggedIn) {
                              Get.to(() => const SignUpScreen());
                              return;
                            }
                            if (canBuy == false) {
                              showToast("Product is out of stock");
                              return;
                            }
                            fireStoreService.addToCart(
                                productId: product.id.trim().toString(), productData: productData);
                            Get.to(() => const CartScreen());
                          },
                          child: const Text("Buy Now")),
                    ),
                  )

                ],
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),

    );
  }
}
