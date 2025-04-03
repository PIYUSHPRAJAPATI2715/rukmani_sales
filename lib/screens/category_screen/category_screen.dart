import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import '../../firebase_services/firestore_service.dart';
import '../../model/Category.dart';
import '../../model/model_product.dart';
import '../product/productDetailsScreen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, required this.keyId});
  final String keyId;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxString selectedCategoryId = "".obs;
  RxString selectedSubcategoryId = "".obs;
  RxBool showSubcategories = false.obs;
  final FirebaseFireStoreService fireStoreService = FirebaseFireStoreService();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      selectedCategoryId.value = widget.keyId;
      fetchSubcategories(widget.keyId);
    });
  }

  Future<void> fetchSubcategories(String categoryId) async {
    QuerySnapshot subcategorySnapshot = await fireStoreService.fireStore
        .collection("categories")
        .doc(categoryId)
        .collection("subcategories")
        .get();

    showSubcategories.value = subcategorySnapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Categories")),
      body: Column(
        children: [
          // Categories List (Horizontal Scroll)
          SizedBox(
            height: 100,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: firestore.collection('categories').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching categories'));
                }

                List<Category> categories = snapshot.data!.docs.map((doc) {
                  return Category.fromMap(doc.id, doc.data());
                }).toList();

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return Obx(() {
                      bool selected = selectedCategoryId.value == categories[index].id;
                      return InkWell(
                        onTap: () {
                          selectedCategoryId.value = categories[index].id;
                          selectedSubcategoryId.value = "";
                          fetchSubcategories(categories[index].id);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: selected ? Colors.blue : Colors.transparent, width: 2),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(categories[index].imageUrl),
                              ),
                              const SizedBox(height: 7),
                              Text(categories[index].name.capitalize ?? ""),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                );
              },
            ),
          ),

          // Subcategories List (If Available)
          SizedBox(height: 20,),
          Obx(() {
            if (!showSubcategories.value) return const SizedBox();
            return SizedBox(
              height: 100,
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: firestore
                    .collection("categories")
                    .doc(selectedCategoryId.value)
                    .collection("subcategories")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    showSubcategories.value = false; // Hide subcategories if none exist
                    return const SizedBox();
                  }

                  List<Category> subcategories = snapshot.data!.docs.map((doc) {
                    return Category.fromMap(doc.id, doc.data());
                  }).toList();

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: subcategories.length,
                    itemBuilder: (context, index) {
                      return Obx(() {
                        bool selected = selectedSubcategoryId.value == subcategories[index].id;
                        return InkWell(
                          onTap: () {
                            selectedSubcategoryId.value = subcategories[index].id;
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: selected ? Colors.green : Colors.transparent, width: 2),
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(subcategories[index].imageUrl),
                                ),
                                const SizedBox(height: 5),
                                Text(subcategories[index].name.capitalize ?? ""),
                              ],
                            ),
                          ),
                        );
                      });
                    },
                  );
                },
              ),
            );
          }),

          // Products Grid
          Expanded(
            child: Obx(() {
              String filterField = selectedSubcategoryId.value.isNotEmpty ? "subcategory" : "category";
              String filterValue = selectedSubcategoryId.value.isNotEmpty ? selectedSubcategoryId.value : selectedCategoryId.value;
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: firestore.collection('products').where(filterField, isEqualTo: filterValue).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No products available'));
                  }

                  List<Product> products = snapshot.data!.docs.map((doc) => Product.fromMap(doc.id, doc.data())).toList();

                  return GridView.builder(
                    itemCount: products.length,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];

                      return GestureDetector(
                        onTap: () => Get.to(() => ProductDetailsScreen(productId: product.id)),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                    width: double.infinity,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                child: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  '₹${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
