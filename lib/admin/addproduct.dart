import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myproject/helper/helper.dart';
import 'package:myproject/screens/widgets/common_app_bar.dart';
import 'package:myproject/screens/widgets/loading_animation.dart';

import '../firebase_services/firestore_service.dart';
import '../helper/new_helper.dart';
import '../model/Category.dart';
import '../model/model_product.dart';
import '../screens/orders/address_screen.dart';

class AddProductAdmin extends StatefulWidget {
  const AddProductAdmin({super.key, this.product});
  final Product? product;

  @override
  State<AddProductAdmin> createState() => _AddProductAdminState();
}

class _AddProductAdminState extends State<AddProductAdmin> {
  final FirebaseFireStoreService fireStoreService = FirebaseFireStoreService();
  File image = File("");
  bool inStock = false;
  bool updating = false;

  updateProfile() {
    if (!formKey.currentState!.validate()) return;
    if (category.value.isEmpty) {
      showToast("Please select category");
      return;
    }
    if (updating == true) {
      return;
    }
    updating = true;
    try {
      fireStoreService
          .updateProduct(
              category: category.value,
              deletePrevious:
                  widget.product != null ? widget.product!.imageUrl : "",
              description: description.text.trim(),
              price: price.text.trim(),
              allowChange: imagePicked,
              context: context,
              inStock: inStock,
              name: nameController.text.trim(),
              profileImage: image,
              productId: widget.product != null
                  ? widget.product!.id
                  : DateTime.now().millisecondsSinceEpoch.toString(),
              updated: (bool value) {
                Get.back();
                updating = false;
                // if(value == false)return;
                // if (widget.fromLogin == false) {
                //   Get.back();
                // } else {
                //   Get.offAll(const BottomNavigationScreen());
                // }
              })
          .then((value) {})
          .catchError((e) {
        updating = false;
      });
    } catch (e) {
      updating = false;
    } finally {
      updating = false;
    }
  }

  bool imagePicked = false;

  bool dataLoaded = true;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController description = TextEditingController();
  RxString category = "".obs;
  bool assigneInitial = false;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      nameController.text = widget.product!.name.toString();
      price.text = widget.product!.price.toString();
      description.text = widget.product!.description.toString();
      category.value = widget.product!.category.toString();
      image = File(widget.product!.imageUrl.toString());
      inStock = widget.product!.inStock!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: "Product Details",
      ),
      body: dataLoaded
          ? Container(
              padding: const EdgeInsets.only(left: 16, top: 20, right: 16),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Form(
                  key: formKey,
                  child: ListView(
                    children: [
                      Center(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            NewHelper.showImagePickerSheet(
                                gotImage: (File gg) {
                                  image = gg;
                                  imagePicked = true;
                                  setState(() {});
                                },
                                context: context);
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 4, color: Colors.white),
                                  boxShadow: [
                                    BoxShadow(
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.1),
                                    )
                                  ],
                                  shape: BoxShape.circle,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10000),
                                  child: Image.file(image,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          Image.network(
                                            image.path,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              CupertinoIcons.person_alt_circle,
                                              size: 45,
                                              color: Colors.grey.shade700,
                                            ),
                                          )),
                                ),
                              ),
                              Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          width: 4,
                                          color: Colors.white,
                                        ),
                                        color: Colors.blue),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      buildTextField(
                          hintetxt: 'Enter Product Name',
                          icon: const Icon(
                            Icons.abc,
                            color: Colors.blue,
                          ),
                          controller: nameController,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return "Please enter product name";
                            }
                            return null;
                          }),
                      const SizedBox(
                        height: 18,
                      ),
                      buildTextField(
                          hintetxt: 'Enter Product Price',
                          icon: const Padding(
                            padding: EdgeInsets.only(left: 20, top: 5),
                            child: Text(
                              '₹',
                              style: TextStyle(fontSize: 25),
                            ),
                          ),
                          controller: price,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return "Please enter product price";
                            }
                            if (value.trim().convertToNum == null) {
                              return "Please enter valid price";
                            }
                            return null;
                          }),
                      const SizedBox(
                        height: 18,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Categories",
                              style: GoogleFonts.urbanist(
                                  fontWeight: FontWeight.w600, fontSize: 13.2),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            StreamBuilder(
                              stream: fireStoreService.getCategories(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<
                                          QuerySnapshot<Map<String, dynamic>>>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data == null)
                                    return const LoadingAnimation();
                                  // log(snapshot.data!.docs.map((e) => jsonEncode(e.data())).toList().toString());
                                  List<Category> catoriesList = snapshot
                                      .data!.docs
                                      .map((e) =>
                                          Category.fromMap(e.id, e.data()))
                                      .toList();

                                  if (assigneInitial == false) {
                                    assigneInitial = true;
                                    if (!catoriesList
                                        .map((e) => e.name.toLowerCase())
                                        .toList()
                                        .contains(category.value)) {
                                      if (catoriesList.isNotEmpty) {
                                        category.value = catoriesList.first.name
                                            .toLowerCase();
                                      }
                                    }
                                  }

                                  return Wrap(
                                    spacing: 12,
                                    children: catoriesList
                                        .map((e) => Obx(() => FilterChip(
                                            selected: category.value ==
                                                e.name.toString().toLowerCase(),
                                            label: Text(e.name.capitalize!),
                                            onSelected: (gg) {
                                              category.value = e.name
                                                  .toString()
                                                  .toLowerCase();
                                            })))
                                        .toList(),
                                  );
                                }
                                return const LoadingAnimation();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      buildTextField(
                          hintetxt: 'Enter Product Description',
                          allowMultiLine: true,
                          controller: description,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return "Please enter product description";
                            }
                            return null;
                          }),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Expanded(child: Text("Product In Stock")),
                          CupertinoSwitch(
                              value: inStock,
                              onChanged: (value) {
                                inStock = value;
                                setState(() {});
                              }),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          updateProfile();
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20))),
                        child: const Text(
                          'Update',
                          style: TextStyle(
                              fontSize: 15,
                              letterSpacing: 2,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
