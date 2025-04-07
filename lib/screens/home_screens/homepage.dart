import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/route_manager.dart';
import 'package:myproject/helper/new_helper.dart';
import 'package:myproject/screens/check_out/delivery_address.dart';
import 'package:myproject/model/Category.dart';
import 'package:myproject/model/banner_model.dart';
import 'package:myproject/screens/product/productDetailsScreen.dart';
import 'package:myproject/screens/home_screens/profile.dart';
import 'package:myproject/screens/widgets/helper.dart';

import '../../bottom_navigation_bar_screen.dart';
import '../../model/model_product.dart';
import '../category_screen/category_screen.dart';
import '../widgets/cart_button.dart';
import 'drawer_screen.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageState();
}

class _HomePageState extends State<HomePageScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  void gettoken(){
    if(FirebaseAuth.instance.currentUser != null){
      firebaseMessaging.getToken().then((token) {
        FirebaseFirestore.instance.collection('fcmtoken').doc(FirebaseAuth.instance.currentUser!.uid).set(
            {
              'fcmtoken' : token
            });
        print("FCM Token: $token");
      });
    }

  }
@override
  void initState() {
    super.initState();
    gettoken();
    // getCurrentLocation();
  }
  String _currentAddress = "Fetching location...";
  // Future<void> getCurrentLocation() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //
  //   // Check if location services are enabled
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     setState(() {
  //       _currentAddress = "Location services are disabled.";
  //     });
  //     return;
  //   }
  //
  //   // Request permissions
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       setState(() {
  //         _currentAddress = "Location permission denied";
  //       });
  //       return;
  //     }
  //   }
  //
  //   if (permission == LocationPermission.deniedForever) {
  //     setState(() {
  //       _currentAddress = "Location permission permanently denied";
  //     });
  //     return;
  //   }
  //
  //   // Get the current position
  //   Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //
  //   setState(() {
  //     _currentAddress = "Lat: ${position.latitude}, Lng: ${position.longitude}";
  //   });
  // }
  RxDouble sliderIndex = (0.0).obs;
  RxDouble sliderIndex1 = (0.0).obs;
  int visit = 0;
  double height = 30;
  Color colorSelect = const Color(0XFF0686F8);
  Color color = const Color(0XFF7AC0FF);
  Color color2 = const Color(0XFF96B1FD);
  Color bgColor = const Color(0XFF1752FE);
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Container(
          //   width: double.infinity,
          //   padding: const EdgeInsets.all(12),
          //   margin: const EdgeInsets.all(10),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.grey.shade300,
          //         blurRadius: 5,
          //         spreadRadius: 2,
          //       ),
          //     ],
          //     borderRadius: BorderRadius.circular(10),
          //   ),
          //   child: Row(
          //     children: [
          //       Icon(Icons.location_on, color: Colors.red),
          //       const SizedBox(width: 10),
          //       Expanded(
          //         child: Text(
          //           _currentAddress,
          //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('banner').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text('Error fetching banners'),
                );
              }

              // 🔹 Check if snapshot has data
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No banners available'),
                );
              }

              // 🔹 Convert documents into BannerModel list
              List<BannerModel> banner = snapshot.data!.docs.map((doc) {
                return BannerModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
              }).toList();

              return  Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.30, // Set height explicitly
                    child: CarouselSlider(
                      options: CarouselOptions(
                        viewportFraction: 1,
                        autoPlay: true,
                        onPageChanged: (value, _) {
                          sliderIndex.value = value.toDouble();
                        },
                        autoPlayCurve: Curves.ease,
                      ),
                      items: banner.map((bannerItem) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * .01),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: bannerItem.imageUrl,
                              errorWidget: (_, __, ___) => const Icon(Icons.error),
                              placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );

            },
          ),

          Container(
            margin: const EdgeInsets.all(16),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Main Ribbon Container
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.black, Colors.amber], // Black to Golden Gradient
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Free 2 Days Delivery on Orders of ₹2199+",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Left Triangle Ribbon Tail
                Positioned(
                  left: -10,
                  top: 0,
                  bottom: 0,
                  child: Transform.rotate(
                    angle: -0.3, // Slightly tilt the triangle
                    child: Container(
                      width: 20,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.amber, // Same as ribbon color
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                // Right Triangle Ribbon Tail
                Positioned(
                  right: -10,
                  top: 0,
                  bottom: 0,
                  child: Transform.rotate(
                    angle: 0.3, // Slightly tilt the triangle
                    child: Container(
                      width: 20,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.amber, // Same as ribbon color
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 290,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('categories').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching categories'));
                }

                List<Category> allCategories = snapshot.data!.docs
                    .map((doc) => Category.fromMap(doc.id, doc.data()))
                    .toList();

                List<Category> menCategories = allCategories.where((c) => c.type == "men").toList();
                List<Category> womenCategories = allCategories.where((c) => c.type == "women").toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (womenCategories.isNotEmpty) ...[
                      Center(
                        child: Text(
                          "Women Categories",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildCategoryList(womenCategories),
                    ],
                    if (menCategories.isNotEmpty) ...[
                      Center(
                        child: Text(
                          "Men Categories",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                        ),
                      ),
                      _buildCategoryList(menCategories),

                    ],
                  ],
                );
              },
            ),
          ),

          const SizedBox(
            height: 20,
          ),
          // StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          //   stream: firestore.collection('products').snapshots(),
          //   builder: (context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return const Center(
          //         child: CircularProgressIndicator(),
          //       );
          //     }
          //
          //     if (snapshot.hasError) {
          //       return const Center(
          //         child: Text('Error fetching products'),
          //       );
          //     }
          //
          //     List<Product> products = snapshot.data!.docs.map((doc) {
          //       return Product.fromMap(doc.id, doc.data());
          //     }).toList();
          //
          //     return GridView.builder(
          //       itemCount: products.length,
          //       scrollDirection: Axis.vertical,
          //       shrinkWrap: true,
          //       physics: const NeverScrollableScrollPhysics(),
          //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //         crossAxisCount: 2,
          //         childAspectRatio: .7,
          //       ),
          //       itemBuilder: (context, index) {
          //         Product product = products[index];
          //         String? userId = FirebaseAuth.instance.currentUser?.uid;
          //
          //         return StreamBuilder<DocumentSnapshot>(
          //           stream: userId != null
          //               ? firestore.collection('users').doc(userId).collection('favorites').doc(product.id).snapshots()
          //               : null, // Return null when user is not logged in
          //           builder: (context, favoriteSnapshot) {
          //             bool isFavorite = favoriteSnapshot.data?.exists ?? false;
          //
          //             return GestureDetector(
          //               onTap: () {
          //                 Get.to(() => ProductDetailsScreen(productId: product.id));
          //               },
          //               child: Padding(
          //                 padding: const EdgeInsets.all(8.0),
          //                 child: Container(
          //                   decoration: BoxDecoration(
          //                     color: Colors.white,
          //                     boxShadow: const [
          //                       BoxShadow(
          //                         blurRadius: 4,
          //                         color: Color(0x3600000F),
          //                         offset: Offset(0, 2),
          //                       )
          //                     ],
          //                     borderRadius: BorderRadius.circular(8),
          //                   ),
          //                   child: Stack(
          //                     children: [
          //                       Column(
          //                         mainAxisSize: MainAxisSize.max,
          //                         children: [
          //                           Expanded(
          //                             child: ClipRRect(
          //                               borderRadius: const BorderRadius.only(
          //                                 bottomLeft: Radius.circular(0),
          //                                 bottomRight: Radius.circular(0),
          //                                 topLeft: Radius.circular(8),
          //                                 topRight: Radius.circular(8),
          //                               ),
          //                               child: Padding(
          //                                 padding: const EdgeInsets.all(5.0),
          //                                 child: CachedNetworkImage(
          //                                   imageUrl: product.imageUrl,
          //                                   fit: BoxFit.fill,
          //                                   width: double.infinity,
          //                                   placeholder: (context, url) => Center(child: CircularProgressIndicator()), // Placeholder while loading
          //                                   errorWidget: (context, url, error) => Icon(Icons.error), // Fallback for errors
          //                                 )
          //                               ),
          //                             ),
          //                           ),
          //                           Padding(
          //                             padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
          //                             child: Row(
          //                               mainAxisSize: MainAxisSize.max,
          //                               children: [
          //                                 Flexible(
          //                                   child: Text(
          //                                     product.name,
          //                                     style: const TextStyle(fontSize: 17, color: Colors.black),
          //                                   ),
          //                                 ),
          //                               ],
          //                             ),
          //                           ),
          //                           Padding(
          //                             padding: const EdgeInsets.only(left: 8, right: 8),
          //                             child: Row(
          //                               mainAxisSize: MainAxisSize.max,
          //                               children: [
          //                                 Flexible(
          //                                   child: Text(
          //                                     '\₹${product.price.toStringAsFixed(2)}',
          //                                     style: const TextStyle(fontSize: 20, color: Colors.black),
          //                                   ),
          //                                 )
          //                               ],
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                       if (userId != null)
          //                       Positioned(
          //                         top: 10,
          //                         right: 10,
          //                         child: GestureDetector(
          //                           onTap: () {
          //                             if (isFavorite) {
          //                               firestore
          //                                   .collection('users')
          //                                   .doc(userId)
          //                                   .collection('favorites')
          //                                   .doc(product.id)
          //                                   .delete();
          //                               showToast("Product removed from wishlist");
          //                             } else {
          //                               firestore
          //                                   .collection('users')
          //                                   .doc(userId)
          //                                   .collection('favorites')
          //                                   .doc(product.id)
          //                                   .set(product.toMap());
          //                               showToast("Product added to wishlist");
          //                             }
          //                           },
          //                           child: Icon(
          //                             isFavorite ? Icons.favorite : Icons.favorite_border,
          //                             color: isFavorite ? Colors.red : Colors.grey,
          //                             size: 28,
          //                           ),
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //             );
          //           },
          //         );
          //       },
          //     );
          //   },
          // ),
Padding(
  padding: const EdgeInsets.only(left: 78.0,right: 78),
  child: InkWell(
      onTap: (){

      },
      child: Image.asset("assets/images/p1.png",width: MediaQuery.sizeOf(context).width,fit: BoxFit.fill,height: 600,)),
),
SizedBox(height: 30,),
          Center(
            child: Text(
              "Our Popular Products ",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),
            ),
          ),
          SizedBox(height: 20,),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('popular').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text('Error fetching banners'),
                );
              }

              // 🔹 Check if snapshot has data
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No banners available'),
                );
              }

              // 🔹 Convert documents into BannerModel list
              List<BannerModel> banner = snapshot.data!.docs.map((doc) {
                return BannerModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
              }).toList();

              return  Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.40, // Set height explicitly
                    child: CarouselSlider(
                      options: CarouselOptions(
                        viewportFraction: 1,
                        autoPlay: true,
                        onPageChanged: (value, _) {
                          sliderIndex1.value = value.toDouble();
                        },
                        autoPlayCurve: Curves.ease,
                      ),
                      items: banner.map((bannerItem) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 48.0,right: 48),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * .02),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(
                                imageUrl: bannerItem.imageUrl,
                                errorWidget: (_, __, ___) => const Icon(Icons.error),
                                placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );

            },
          ),
          SizedBox(height: 30,),
          Padding(
            padding: const EdgeInsets.only(left: 78.0,right: 78),
            child: InkWell(
                onTap: (){

                },
                child: Image.asset("assets/images/p2.png",width: MediaQuery.sizeOf(context).width,fit: BoxFit.fill,height: 600,)),
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}
Widget _buildCategoryList(List<Category> categories) {
  return SizedBox(
    height: 100,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () {
            Get.to(() => CategoryScreen(keyId: category.name));
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.transparent, width: 2),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            constraints: BoxConstraints(maxWidth: context.getSize.width * .19),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(category.imageUrl),
                ),
                const SizedBox(height: 7),
                Center(
                  child: Text(
                    category.name.capitalize!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

