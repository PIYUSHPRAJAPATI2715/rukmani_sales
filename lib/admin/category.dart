import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'package:file_picker/file_picker.dart';

import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
class AdminCategoryPage extends StatefulWidget {
  @override
  _AdminCategoryPageState createState() => _AdminCategoryPageState();
}

class _AdminCategoryPageState extends State<AdminCategoryPage> {
  final TextEditingController _nameController = TextEditingController();
  String? _imageUrl;
  String? _selectedCategory;
  bool _isSubcategory = false;



  Future<void> _pickImage() async {
  if (kIsWeb) {
  // Web: Use FilePicker instead of ImagePicker
  FilePickerResult? result = await FilePicker.platform.pickFiles(
  type: FileType.image,
  );

  if (result != null && result.files.single.bytes != null) {
  Uint8List fileBytes = result.files.single.bytes!;
  String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';

  // Upload image to Firebase Storage
  UploadTask uploadTask = FirebaseStorage.instance
      .ref('category_images/$fileName')
      .putData(fileBytes);

  TaskSnapshot snapshot = await uploadTask;
  String downloadUrl = await snapshot.ref.getDownloadURL();

  setState(() {
  _imageUrl = downloadUrl;
  });
  }
  } else {
  // Mobile: Use ImagePicker
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
  File file = File(pickedFile.path);
  String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';

  UploadTask uploadTask = FirebaseStorage.instance
      .ref('category_images/$fileName')
      .putFile(file);

  TaskSnapshot snapshot = await uploadTask;
  String downloadUrl = await snapshot.ref.getDownloadURL();

  setState(() {
  _imageUrl = downloadUrl;
  });
  }
  }
  }


  Future<void> _addCategory() async {
    if (_nameController.text.isEmpty || _imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter name and select an image"))
      );
      return;
    }

    final categoryData = {
      "name": _nameController.text,
      "imageUrl": _imageUrl,
    };

    if (_isSubcategory && _selectedCategory != null) {
      await FirebaseFirestore.instance
          .collection("categories")
          .doc(_selectedCategory)
          .collection("subcategories")
          .add(categoryData);
    } else {
      await FirebaseFirestore.instance.collection("categories").add(categoryData);
    }

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Category added successfully"))
    );

    _nameController.clear();
    setState(() {
      _imageUrl = null;
      _selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Categories"),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: Text("Is this a subcategory?"),
                    value: _isSubcategory,
                    onChanged: (val) {
                      setState(() {
                        _isSubcategory = val;
                      });
                    },
                  ),
                  if (_isSubcategory) FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance.collection("categories").get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                      List<DropdownMenuItem<String>> categoryItems = snapshot.data!.docs.map((doc) {
                        return DropdownMenuItem(
                          value: doc.id,
                          child: Text(doc["name"]),
                        );
                      }).toList();

                      return DropdownButtonFormField(
                        decoration: InputDecoration(
                          labelText: "Select Parent Category",
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedCategory,
                        items: categoryItems,
                        onChanged: (val) {
                          setState(() {
                            _selectedCategory = val as String?;
                          });
                        },
                      );
                    },
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Category Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),
                  _imageUrl == null
                      ? Center(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.image),
                      label: Text("Pick Image"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  )
                      : Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(_imageUrl!, height: 120, width: 120, fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _addCategory,
                      child: Text("Add Category"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("categories").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                var categories = snapshot.data!.docs;
                return GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    var category = categories[index];
                    return GestureDetector(
                      onTap: () {},
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                child: Image.network(category["imageUrl"], fit: BoxFit.cover, width: double.infinity),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(category["name"], style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}