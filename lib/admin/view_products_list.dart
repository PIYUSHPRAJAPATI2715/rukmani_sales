import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myproject/firebase_services/firestore_service.dart';
import '../model/model_product.dart';
import '../screens/widgets/common_app_bar.dart';
import '../screens/widgets/loading_animation.dart';
import 'addproduct.dart';

class ViewProductsLList extends StatefulWidget {
  const ViewProductsLList({super.key});

  @override
  State<ViewProductsLList> createState() => _ViewProductsLListState();
}

class _ViewProductsLListState extends State<ViewProductsLList> {
  final FirebaseFireStoreService fireStoreService = FirebaseFireStoreService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: "Products List",
        actions: [
          IconButton(
              onPressed: () {
                Get.to(() => const AddProductAdmin());
              },
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: Colors.teal,
                size: 30,
              )),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: StreamBuilder(
        stream: fireStoreService.getAllProductsList(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == null) return const SizedBox();
            // log(snapshot.data!.docs.map((e) => jsonEncode(e.data())).toList().toString());
            List<Product> products = snapshot.data!.docs.map((e) => Product.fromMap(e.id, e.data())).toList();
            return ListView.builder(
                itemCount: products.length,
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final productInfo = products[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: InkWell(
                      onTap: () {
                        Get.to(() => AddProductAdmin(
                              product: productInfo,
                            ));
                        // Get.to(()=> OrderDetails(modelOrderDetails: order,),
                        //     transition: Transition.rightToLeft);
                      },
                      borderRadius: BorderRadius.circular(10),
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
                                decoration: BoxDecoration(boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 4,
                                    color: Color(0x3600000F),
                                    offset: Offset(0, 2),
                                  )
                                ], borderRadius: BorderRadius.circular(21), color: Colors.white),
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
                                      productInfo.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      productInfo.category.toString(),
                                      style: GoogleFonts.urbanist(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            productInfo.price.toString(),
                                            style: GoogleFonts.urbanist(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                        productInfo.inStock == true
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
          }
          return const LoadingAnimation();
        },
      ),
    );
  }
}
