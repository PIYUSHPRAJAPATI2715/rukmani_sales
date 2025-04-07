import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../firebase_services/firestore_service.dart';
import '../helper/helper.dart';
import '../helper/new_helper.dart';
import '../model/Category.dart';
import '../model/model_product.dart';
import '../screens/widgets/common_app_bar.dart';
import '../screens/widgets/loading_animation.dart';

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
  bool imagePicked = false;
  bool dataLoaded = true;
  void updateProfile() {
    if (!formKey.currentState!.validate()) return;
    if (category.value.isEmpty) {
      Get.snackbar("Error", "Please select a category");
      return;
    }
    // if (image.path.isEmpty) {
    //   Get.snackbar("Error", "Please select a product image");
    //   return;
    // }

    if (updating) return;
    updating = true;

    fireStoreService.updateProduct(
      subcategory: subcategory.value,
      productType: productType.value,
      category: category.value,
      description: description.text.trim(),
      price: price.text.trim(),
      allowChange: imagePicked,
      inStock: inStock,
      context: context,
      name: nameController.text.trim(),
      profileImage: image,
      deletePrevious: widget.product?.imageUrl ?? "",
      productId: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      updated: (bool success) {
        updating = false;
        if (success) {
          Get.back();
        }
      },
    );
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController description = TextEditingController();
  RxString category = "".obs;
  RxString subcategory = "".obs;
  List<String> subcategoriesList = [];
  bool assigneInitial = false;
  final formKey = GlobalKey<FormState>();
  Future<List<String>> fetchSubcategories(String categoryId) async {
    print("Fetching subcategories for category: $categoryId");

    QuerySnapshot subcategorySnapshot = await fireStoreService.fireStore
        .collection("categories") // Go to the categories collection
        .doc(categoryId) // Select the specific category document
        .collection("subcategories") // Get its subcategories subcollection
        .get();

    List<String> subcategories = subcategorySnapshot.docs
        .map((doc) => doc["name"] as String)
        .toList();

    print("Fetched subcategories: $subcategories");
    return subcategories;
  }

  RxString productType = "".obs;
  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      nameController.text = widget.product!.name.toString();
      price.text = widget.product!.price.toString();
      description.text = widget.product!.description.toString();
      category.value = widget.product!.category.toString();
      subcategory.value = widget.product!.subcategory;
      productType.value = widget.product!.type;
      image = File(widget.product!.imageUrl.toString());
      inStock = widget.product!.inStock!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Add Product"),
      body: dataLoaded
          ? Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: () {
                  NewHelper.showImagePickerSheet(
                      gotImage: (File img) {
                        image = img;
                        imagePicked = true;
                        setState(() {});
                      },
                      context: context);
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                  image.path.isNotEmpty ? FileImage(image) : null,
                  child: image.path.isEmpty
                      ? const Icon(Icons.add_a_photo, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) => value!.isEmpty
                    ? "Please enter product name"
                    : null,
              ),
              TextFormField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Product Price'),
                validator: (value) => value!.isEmpty
                    ? "Please enter product price"
                    : null,
              ),
              TextFormField(
                controller: description,
                decoration:
                const InputDecoration(labelText: 'Product Description'),
                validator: (value) => value!.isEmpty
                    ? "Please enter product description"
                    : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: productType.value.isEmpty ? null : productType.value,
                decoration: const InputDecoration(labelText: 'Product Type'),
                items: ['men', 'women']
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                onChanged: (value) {
                  productType.value = value!;
                },
                validator: (value) =>
                value == null || value.isEmpty ? 'Please select a product type' : null,
              ),

              const SizedBox(height: 20),

              StreamBuilder(
                stream: fireStoreService.getCategories(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const LoadingAnimation();
                  }

                  // ✅ Debugging: Print Firestore Data
                  snapshot.data!.docs.forEach((doc) {
                    print("Firestore Data: ${doc.data()}");
                  });

                  List<Category> categories = snapshot.data!.docs
                      .map((e) => Category.fromMap(e.id, e.data() as Map<String, dynamic>))
                      .toList();

                  return DropdownButtonFormField(
                    value: category.value.isEmpty ? null : category.value,
                    items: categories
                        .map((cat) => DropdownMenuItem(
                      value: cat.name,
                      child: Text(cat.name.capitalize!),
                    ))
                        .toList(),
                    onChanged: (value) async {
                      category.value = value as String;

                      // ✅ Find the selected category
                      Category selectedCategory = categories.firstWhere((cat) => cat.name == category.value);

                      // ✅ Fetch subcategories dynamically
                      subcategoriesList = await fetchSubcategories(selectedCategory.id);

                      print("Selected Category: ${selectedCategory.name}");
                      print("Subcategories List: $subcategoriesList"); // ✅ Debugging

                      // subcategory.value = ""; // Reset subcategory selection
                      setState(() {}); // ✅ Ensure UI updates
                    },

                    decoration: const InputDecoration(labelText: 'Category'),
                  );
                },
              ),


              if (subcategoriesList.isNotEmpty) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField(
                  value:
                  subcategory.value.isEmpty ? null : subcategory.value,
                  items: subcategoriesList
                      .map((subcat) => DropdownMenuItem(
                    value: subcat,
                    child: Text(subcat.capitalize!),
                  ))
                      .toList(),
                  onChanged: (value) {
                    subcategory.value = value as String;
                  },
                  decoration:
                  const InputDecoration(labelText: 'Subcategory'),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Product In Stock"),
                  CupertinoSwitch(
                      value: inStock,
                      onChanged: (value) {
                        setState(() {
                          inStock = value;
                        });
                      }),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {

                  // if ( image.path.isEmpty) {
                  //   Get.snackbar("Error", "Please select product image");
                  //   return;
                  // }
                  updateProfile();
                },
                child: const Text("Save Product"),
              ),
            ],
          ),
        ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}