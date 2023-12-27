import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/route_manager.dart';
import 'package:myproject/helper/new_helper.dart';
import 'package:myproject/screens/check_out/delivery_address.dart';
import 'package:myproject/model/Category.dart';
import 'package:myproject/model/banner_model.dart';
import 'package:myproject/screens/product/productDetailsScreen.dart';
import 'package:myproject/screens/home_screens/profile.dart';

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
  }


  RxDouble sliderIndex = (0.0).obs;
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
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firestore.collection('banner').snapshots(),
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

              List<BannerModel> banner = snapshot.data!.docs.map((doc) {
                return BannerModel.fromMap(doc.id, doc.data());
              }).toList();

              return Column(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                        viewportFraction: 1,
                        autoPlay: true,
                        onPageChanged: (value, _) {
                          sliderIndex.value = value.toDouble();
                        },
                        autoPlayCurve: Curves.ease,
                        height: height * .20),
                    items: List.generate(
                        banner.length,
                        (index) => Container(
                            width: width,
                            margin: EdgeInsets.symmetric(horizontal: width * .01),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.grey),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(
                                imageUrl: banner[index].imageUrl,
                                errorWidget: (_, __, ___) => const SizedBox(),
                                placeholder: (_, __) => const SizedBox(),
                                fit: BoxFit.cover,
                              ),
                            ))),
                  ),
                  // SizedBox(
                  //   height: height * .01,
                  // ),
                  // Center(
                  //   child: DotsIndicator(
                  //     dotsCount: banner.length,
                  //     position: sliderIndex.value.toInt(),
                  //     decorator: const DotsDecorator(
                  //       color: Colors.black, // Inactive color
                  //       activeColor: Colors.white,
                  //       size: Size.square(12),
                  //       activeSize: Size.square(12),
                  //     ),
                  //   ),
                  // ),
                ],
              );
            },
          ),
          const SizedBox(
            height: 20,
          ),
          // SizedBox(
          //   height: 100,
          //   child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          //     stream: firestore.collection('categories').snapshots(),
          //     builder: (context, snapshot) {
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return const Center(
          //           child: CircularProgressIndicator(),
          //         );
          //       }
          //
          //       if (snapshot.hasError) {
          //         return const Center(
          //           child: Text('Error fetching products'),
          //         );
          //       }
          //
          //       List<Category> category = snapshot.data!.docs.map((doc) {
          //         return Category.fromMap(doc.id, doc.data());
          //       }).toList();
          //       return ListView.builder(
          //           scrollDirection: Axis.horizontal,
          //           shrinkWrap: true,
          //           // padEnds: false,
          //           // controller: PageController(viewportFraction: .2),
          //           itemCount: category.length,
          //           itemBuilder: (context, index) {
          //             return GestureDetector(
          //               onTap: () {
          //                 Get.to(() => CategoryScreen(
          //                       keyId: category[index].name,
          //                     ));
          //               },
          //               child: Container(
          //                 decoration: BoxDecoration(
          //                     borderRadius: BorderRadius.circular(12),
          //                     border: Border.all(color: Colors.transparent, width: 2)),
          //                 margin: const EdgeInsets.symmetric(horizontal: 10),
          //                 padding: const EdgeInsets.symmetric(horizontal: 6),
          //                 constraints: BoxConstraints(maxWidth: context.getSize.width * .16),
          //                 child: Column(
          //                   mainAxisAlignment: MainAxisAlignment.center,
          //                   children: [
          //                     CircleAvatar(
          //                       radius: 30, // Image radius
          //                       backgroundImage: NetworkImage(category[index].imageUrl),
          //                     ),
          //                     const SizedBox(
          //                       height: 7,
          //                     ),
          //                     Center(
          //                       child: Text(
          //                         category[index].name.capitalize!,
          //                         overflow: TextOverflow.ellipsis,
          //                         maxLines: 1,
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //             );
          //           });
          //     },
          //   ),
          // ),
          // const SizedBox(
          //   height: 10,
          // ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firestore.collection('products').snapshots(),
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
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .7,
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
                                    fit: BoxFit.fill,
                                    width: Get.width,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Flexible(
                                    child: Text(
                                      products[index].name,
                                      style: const TextStyle(fontSize: 17, color: Colors.black),
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
                                      '\₹${products[index].price.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 20, color: Colors.black),
                                    ),
                                  )
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
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}
