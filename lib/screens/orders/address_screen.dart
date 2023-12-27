import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:myproject/helper/helper.dart';

import '../../firebase_services/firestore_service.dart';
import '../widgets/loading_animation.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController addressName = TextEditingController();
  final TextEditingController number = TextEditingController();
  // final TextEditingController city = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController landMark = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String city = "";

  final FirebaseFireStoreService fireStoreService = FirebaseFireStoreService();

  bool apiLoaded = false;
  List<String> cities = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      fireStoreService.getAddress().then((value) {
        if (value != null) {
          addressName.text = value.title.toString();
          number.text = value.phone.toString();
          city = value.city.toString();
          address.text = value.address.toString();
          // landMark.text = value.landmark.toString();
        }
        fireStoreService.getCityList().then((value) {
          if (value == null) return;
          cities = value.cityList ?? [];
          if (!cities.map((e) => e.toString().toLowerCase()).toList().contains(city.toLowerCase())) {
            city = "";
          }
          cityLoaded = true;
          setState(() {});
        });
        apiLoaded = true;
        setState(() {});
      });
    });
  }

  bool cityLoaded = false;

  bool updating = false;

  updateAddress() {
    if (formKey.currentState!.validate()) {
      if (city.isEmpty) {
        showToast("Please wait loading city");
        return;
      }
      if (updating == true) return;
      updating = true;
      fireStoreService
          .updateAddress(
              title: addressName.text.trim(),
              phone: number.text.trim(),
              city: city.trim(),
              address: address.text.trim(),
              landmark: landMark.text.trim())
          .then((value) {
        updating = false;
      }).catchError((e) {
        updating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Delivery Address',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 18),
        ),
      ),
      body: apiLoaded
          ? SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Add your address,\n where your orders will be delivered.'.capitalize!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Lottie.asset(
                      "assets/images/location.json",
                      height: 150.0,
                      repeat: true,
                      reverse: true,
                      animate: true,
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    buildTextField(
                        hintetxt: 'Enter Location Name',
                        icon: const Icon(
                          Icons.near_me,
                          color: Colors.blue,
                        ),
                        controller: addressName,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return "Please enter address name";
                          }
                          return null;
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                    buildTextField(
                        hintetxt: 'Enter Your Phone Number',
                        controller: number,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return "Please enter phone no.".capitalize;
                          }
                          if (value.trim().length < 10) {
                            return "Please enter valid phone no.".capitalize;
                          }
                          return null;
                        },
                        icon: const Icon(
                          Icons.phone,
                          color: Colors.blue,
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    if (cityLoaded)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "City",
                              style: GoogleFonts.urbanist(fontWeight: FontWeight.w600, fontSize: 13.2),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            DropdownButtonFormField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(1000), borderSide: BorderSide.none),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(1000), borderSide: BorderSide.none),
                                  counterText: "",
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  enabled: true,
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.2),
                                  hintText: "City",
                                ),
                                validator: (vds) {
                                  if (city.isEmpty) {
                                    return "Please select city";
                                  }
                                  return null;
                                },
                                value: city.isEmpty ? null : city,
                                items: cities
                                    .map((e) => DropdownMenuItem(value: e.toLowerCase(), child: Text(e)))
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  city = value;
                                }),
                          ],
                        ),
                      ),
                    // buildTextField(
                    //     hintetxt: 'City',
                    //     controller: city,
                    //     keyboardType: TextInputType.number,
                    //     validator: (value){
                    //       if(value!.trim().isEmpty){
                    //         return "Please your city".capitalize;
                    //       }
                    //       return null;
                    //     },
                    //     icon: const Icon(
                    //       Icons.location_city_rounded,
                    //       color: Colors.blue,
                    //     )),
                    const SizedBox(
                      height: 20,
                    ),
                    buildTextField(
                        hintetxt: 'Address(Area and Street)',
                        keyboardType: TextInputType.streetAddress,
                        controller: address,
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return "Please Enter Address";
                          }
                          return null;
                        },
                        icon: const Icon(
                          Icons.home,
                          color: Colors.blue,
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    buildTextField(
                        hintetxt: 'Nearby Landmark',
                        keyboardType: TextInputType.streetAddress,
                        controller: landMark,
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return "Please Enter Nearby Landmark";
                          }
                          return null;
                        },
                        icon: const Icon(
                          Icons.landscape_rounded,
                          color: Colors.blue,
                        )),
                    const SizedBox(
                      height: 50,
                    ),
                    GestureDetector(
                      onTap: () {
                        updateAddress();
                      },
                      child: Container(
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.blue),
                        child: const Center(
                            child: Text(
                          'Update Address',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        )),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              ),
            )
          : const LoadingAnimation(),
    );
  }
}

Widget buildTextField(
    {required String hintetxt,
    Widget? icon,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required FormFieldValidator<String> validator,
    bool? allowMultiLine}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          hintetxt.replaceAll("Enter ", ""),
          style: GoogleFonts.urbanist(fontWeight: FontWeight.w600, fontSize: 13.2),
        ),
        const SizedBox(
          height: 4,
        ),
        TextFormField(
          cursorColor: Colors.orange,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: controller,
          validator: validator,
          // textInputAction: TextInputAction.next,
          minLines: allowMultiLine == true ? 4 : 1,
          maxLines: allowMultiLine == true ? null : 1,
          maxLength: 300,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(allowMultiLine == true ? 14 : 1000), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(allowMultiLine == true ? 14 : 1000), borderSide: BorderSide.none),
            counterText: "",
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabled: true,
            filled: true,
            fillColor: Colors.grey.withOpacity(0.2),
            prefixIcon: icon,
            hintText: hintetxt,
          ),
        ),
      ],
    ),
  );
}
