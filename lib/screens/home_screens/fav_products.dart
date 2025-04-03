import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myproject/model/model_product.dart';
import 'package:myproject/screens/product/productDetailsScreen.dart';

import '../../helper/helper.dart';

class FavoritesScreen extends StatelessWidget {
  final FavoritesService favoritesService = FavoritesService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favourites"),
        backgroundColor: Colors.amber,
      ),
      body: StreamBuilder<List<Product>>(
        stream: favoritesService.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No favorite products yet."));
          }

          List<Product> favorites = snapshot.data!;

          return GridView.builder(
            itemCount: favorites.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: .7,
            ),
            itemBuilder: (context, index) {
              Product product = favorites[index];

              return GestureDetector(
                onTap: () {
                  Get.to(() => ProductDetailsScreen(productId: product.id));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 4,
                          color: Color(0x3600000F),
                          offset: Offset(0, 2),
                        )
                      ],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Image.network(
                                    product.imageUrl,
                                    fit: BoxFit.fill,
                                    width: Get.width,
                                  ),
                                ),
                              ),
                              // ❤️ Favorite Remove Button
                              Positioned(
                                top: 10,
                                right: 10,
                                child: IconButton(
                                  icon: const Icon(Icons.favorite, color: Colors.red),
                                  onPressed: () async {
                                    await favoritesService.toggleFavorite(product);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(fontSize: 17, color: Colors.black),
                              ),
                              Text(
                                '\₹${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 20, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
class FavoritesService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> toggleFavorite(Product product) async {
    final favRef = firestore.collection('users').doc(userId).collection('favorites').doc(product.id);

    final docSnapshot = await favRef.get();
    if (docSnapshot.exists) {
      await favRef.delete();
      showToast("Product removed from wishlist");
      // ✅ Remove from favorites
    } else {
      await favRef.set(product.toMap());
     // ✅ Add to favorites
    }
  }

  Stream<List<Product>> getFavorites() {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Product.fromMap(doc.id, doc.data())).toList());
  }
}
