import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:myproject/screens/widgets/common_app_bar.dart';

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

  RxString categoryId = "".obs;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      categoryId.value = widget.keyId.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: "Categories",
      ),
      body: Column(
        children: [
          SizedBox(
            height: 100,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: firestore.collection('categories').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error fetching products'),
                  );
                }

                List<Category> category = snapshot.data!.docs.map((doc) {
                  return Category.fromMap(doc.id, doc.data());
                }).toList();
                return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    // padEnds: false,
                    itemCount: category.length,
                    itemBuilder: (context, index) {
                      return Obx(() {
                        bool selected = categoryId.value == category[index].name;
                        return GestureDetector(
                          onTap: () {
                            categoryId.value = category[index].name;
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: selected ? Colors.blue : Colors.transparent, width: 2)),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 30, // Image radius
                                  backgroundImage: NetworkImage(category[index].imageUrl),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                Center(
                                  child: Text(
                                    category[index].name.capitalize!,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    });
              },
            ),
          ),
          Expanded(
            child: Obx(() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: firestore.collection('products').where("category", isEqualTo: categoryId.value).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error fetching products'),
                      );
                    }
                    List<Product> products = snapshot.data!.docs.map((doc) {
                      return Product.fromMap(doc.id, doc.data());
                    }).toList();

                    return GridView.builder(
                      itemCount: products.length,
                      scrollDirection: Axis.vertical,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Get.to(() => ProductDetailsScreen(productId: products[index].id));
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
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(0),
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Image.network(
                                              products[index].imageUrl,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            products[index].name,
                                            style: const TextStyle(fontSize: 10, color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8, right: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            '\$${products[index].price.toStringAsFixed(2)}',
                                          ),
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
                )),
          ),
        ],
      ),
    );
  }
}
