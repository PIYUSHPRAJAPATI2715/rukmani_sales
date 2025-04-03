import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myproject/model/model_product.dart';
import 'package:myproject/screens/auth/signup.dart';
import '../../firebase_services/firestore_service.dart';
import '../../helper/helper.dart';
import '../home_screens/cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  FirebaseFireStoreService fireStoreService = FirebaseFireStoreService();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  bool isFavorite = false; // 🔥 Track favorite state

  @override
  void initState() {
    super.initState();
    if (userId != null) {
      _checkIfFavorite();
    }
  }

  Future<void> _checkIfFavorite() async {
    if (userId == null) return; // 🔥 Prevents errors for guest users

    DocumentSnapshot favDoc = await firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(widget.productId)
        .get();

    setState(() {
      isFavorite = favDoc.exists;
    });
  }

  Future<void> _toggleFavorite(Product product) async {
    if (userId == null) {
      Get.to(() => const SignUpScreen());
      return;
    }

    final favRef = firestore.collection('users').doc(userId).collection('favorites').doc(product.id);

    if (isFavorite) {
      await favRef.delete();
      showToast("Product removed from wishlist");
    } else {
      await favRef.set(product.toMap());
      showToast("Product added to wishlist");
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
        backgroundColor: Colors.amber,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: fireStoreService.fireStore.collection('products').doc(widget.productId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final productData = snapshot.data!.data()!;
          final product = Product.fromMap(widget.productId, productData);
          bool canBuy = product.inStock == true;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.network(
                      product.imageUrl,
                      height: 300,
                      width: Get.width,
                      fit: BoxFit.contain,
                    ),

                    // ❤️ Heart icon (Only for logged-in users)
                    if (userId != null)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => _toggleFavorite(product),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                            size: 28,
                          ),
                        ),
                      )
                  ],
                ),

                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                            "In Stock",
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

                // 🛒 Add to Cart Button
                _buildActionButton(
                  text: "Add to Cart",
                  onPressed: () {
                    if (!fireStoreService.userLoggedIn) {
                      Get.to(() => const SignUpScreen());
                      return;
                    }
                    if (!canBuy) {
                      showToast("Product is out of stock");
                      return;
                    }
                    fireStoreService.addToCart(productId: product.id, productData: productData);
                  },
                ),

                // 🛍️ Buy Now Button
                _buildActionButton(
                  text: "Buy Now",
                  onPressed: () {
                    if (!fireStoreService.userLoggedIn) {
                      Get.to(() => const SignUpScreen());
                      return;
                    }
                    if (!canBuy) {
                      showToast("Product is out of stock");
                      return;
                    }
                    fireStoreService.addToCart(productId: product.id, productData: productData);
                    Get.to(() => const CartScreen());
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🔥 Custom button widget for reusability
  Widget _buildActionButton({required String text, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 50,
        width: Get.width,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.black, Colors.amber],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
