import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:myproject/firebase_services/firestore_service.dart';
import 'package:myproject/helper/helper.dart';
import '../../helper/new_helper.dart';
import '../../bottom_navigation_bar_screen.dart';
import '../auth/signup.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.fromLogin, this.home});
  final bool fromLogin;
  final bool? home;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFireStoreService fireStoreService = FirebaseFireStoreService();
  bool isobscurepassword = true;
  File image = File("");

  updateProfile() {
    if (!formKey.currentState!.validate()) return;
    // if (widget.fromLogin == true && image.path.isEmpty) {
    //   showToast("Please select profile image");
    //   return;
    // }
    fireStoreService.updateProfile(
        address: address.text.trim(),
        allowChange: image.path.isEmpty ? false : imagePicked,
        context: context,
        email: email.text.trim(),
        name: nameController.text.trim(),
        profileImage: image,
        updated: (bool value) {
          if (value == false) return;
          if (widget.fromLogin == false) {
            Get.back();
          } else {
            Get.offAll(const BottomNavigationScreen());
          }
        });
  }

  bool imagePicked = false;

  bool dataLoaded = true;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController address = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (!fireStoreService.userLoggedIn) return;
    if (widget.fromLogin == false) {
      dataLoaded = false;
      fireStoreService.getProfileDetails().then((value) {
        if (value == null) {
          dataLoaded = true;
          setState(() {});
          return;
        }
        nameController.text = value.name.toString();
        email.text = value.email.toString();
        address.text = value.address.toString();
        image = File(value.profile.toString());
        dataLoaded = true;
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.home == null
          ? AppBar(
              title: const Text('Profile'),
            )
          : null,
      body: fireStoreService.userLoggedIn
          ? dataLoaded
              ? Container(
                  padding: const EdgeInsets.only(left: 15, top: 20, right: 15),
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
                                      border: Border.all(width: 4, color: Colors.white),
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
                                          errorBuilder: (_, __, ___) => Image.network(
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
                          buildTextField('Full Name', 'Manish prajapat', false, nameController, (value) {
                            if (value!.trim().isEmpty) {
                              return "Please enter name";
                            }
                            return null;
                          }),
                          buildTextField('Email', 'Manishprajapat207@gmail.com', false, email, (value) {
                            if (value!.trim().isEmpty) {
                              return "Please enter email";
                            }
                            if (value.trim().isValidEmail) {
                              return "Please enter valid email address";
                            }
                            return null;
                          }),
                          // buildTextField('password', '***********', true),
                          buildTextField('Address', 'Mansarovar jaipur', false, address, (value) {
                            if (value!.trim().isEmpty) {
                              return "Please enter address";
                            }
                            return null;
                          }),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  FirebaseAuth.instance.signOut().then((value) {
                                    Get.offAll(const SignUpScreen());
                                    showToast("Logged Out Successfully");
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 50),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(fontSize: 15, letterSpacing: 2, color: Colors.black),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  updateProfile();
                                  return;
                                  if (widget.fromLogin == false) {
                                  } else {
                                    Get.offAll(const BottomNavigationScreen());
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.blue,
                                    padding: const EdgeInsets.symmetric(horizontal: 50),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                                child: const Text(
                                  'Update',
                                  style: TextStyle(fontSize: 15, letterSpacing: 2, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),

                          if (FirebaseAuth.instance.currentUser != null)
                            ElevatedButton(
                              onPressed: () async {
                                User? user = FirebaseAuth.instance.currentUser;
                                await user!.delete();
                                showToast("Your account has been deleted");
                                Get.to(const SignUpScreen());
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  padding: const EdgeInsets.symmetric(horizontal: 50),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                              child: const Text(
                                'Delete Account',
                                style: TextStyle(fontSize: 15, letterSpacing: 2, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Account not logged in"),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Get.to(const SignUpScreen());
                      },
                      child: const Text("Login In"))
                ],
              ),
            ),
    );
  }

  Widget buildTextField(String labletext, String placeholder, bool ispasswordTextField,
      TextEditingController controller, FormFieldValidator<String>? validator) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: TextFormField(
        controller: controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        obscureText: ispasswordTextField ? isobscurepassword : false,
        keyboardType: labletext == 'Email' ? TextInputType.emailAddress : null,
        decoration: InputDecoration(
            suffixIcon: ispasswordTextField
                ? IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.remove_red_eye,
                      color: Colors.grey,
                    ))
                : null,
            contentPadding: const EdgeInsets.only(bottom: 5),
            labelText: labletext,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            hintStyle: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
        validator: validator,
      ),
    );
  }
}
