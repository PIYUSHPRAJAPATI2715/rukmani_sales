import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myproject/firebase_services/firestore_service.dart';
import 'package:myproject/screens/widgets/loading_animation.dart';

import '../../model/model_product.dart';
import '../product/productDetailsScreen.dart';

class SearchProducts extends StatefulWidget {
  const SearchProducts({super.key});

  @override
  State<SearchProducts> createState() => _SearchProductsState();
}

class _SearchProductsState extends State<SearchProducts> {
  final FirebaseFireStoreService fireStoreService = FirebaseFireStoreService();
  List<Product>? products;
  final TextEditingController searchController = TextEditingController();
  RxInt refreshInt = 0.obs;

  String get searchText => searchController.text.trim().toLowerCase();

  getAllProducts() {
    fireStoreService.getAllProducts().then((value) {
      products = value.docs.map((e) => Product.fromMap(e.id, e.data())).toList();
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      getAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: products != null
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 8),
                    child: TextFormField(
                      cursorColor: Colors.orange,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: searchController,
                      onChanged: (ads) {
                        refreshInt.value = DateTime.now().millisecondsSinceEpoch;
                      },
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        border:
                            OutlineInputBorder(borderRadius: BorderRadius.circular(1000), borderSide: BorderSide.none),
                        enabledBorder:
                            OutlineInputBorder(borderRadius: BorderRadius.circular(1000), borderSide: BorderSide.none),
                        counterText: "",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        enabled: true,
                        filled: true,
                        suffixIcon: const Icon(Icons.search),
                        fillColor: Colors.grey.shade100,
                        hintText: "Search Product",
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      List<Product> tempList = [];
                      if (refreshInt.value > 0) {}
                      if (searchText.isNotEmpty) {
                        tempList = products!
                            .where((element) =>
                                element.name.toLowerCase().contains(searchText) ||
                                element.description.toLowerCase().contains(searchText) ||
                                element.price.toString().toLowerCase().contains(searchText))
                            .toList();
                      } else {
                        tempList = products!;
                      }
                      return ListView.builder(
                          itemCount: tempList.length,
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(16).copyWith(top: 0),
                          itemBuilder: (context, index) {
                            final productInfo = tempList[index];
                            return Card(
                              elevation: 1,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  Get.to(() => ProductDetailsScreen(productId: productInfo.id));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 80,
                                          width: 80,
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(21), color: Colors.white),
                                          child: Image.network(
                                            productInfo.imageUrl,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                productInfo.name.toString(),
                                                style: const TextStyle(
                                                    fontSize: 15, color: Colors.teal, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(
                                                height: 2,
                                              ),
                                              Text(
                                                "₹${productInfo.price}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.arrow_forward_ios_rounded),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          });
                    }),
                  ),
                ],
              )
            : const LoadingAnimation());
  }
}
