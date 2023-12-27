import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myproject/firebase_services/firestore_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../admin/homepage.dart';
import '../auth/signup.dart';
import '../check_out/delivery_address.dart';
import '../orders/orders_screen.dart';
import 'profile.dart';
import '../orders/address_screen.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  final FirebaseFireStoreService fireStoreService = FirebaseFireStoreService();

  bool get adminAccess => fireStoreService.auth.currentUser?.displayName.toString() == "Admin";

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.red,
            ),
            child: Column(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/rukmani.png',
                    height: 100,
                  ),
                ),
                const Text(
                  'Rukmani Sales',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          if (adminAccess)
            ListTile(
              leading: const Icon(CupertinoIcons.settings_solid),
              title: const Text('Admin Control'),
              onTap: () {
                // Handle the tap on the Home item
                Get.to(() => const AdminHomePage());
              },
            ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              // Handle the tap on the Home item
              Get.back();
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('profile'),
            onTap: () {
              if (fireStoreService.userLoggedIn) {
                Get.to(() => const ProfileScreen(
                      fromLogin: false,
                    ));
              } else {
                Get.to(() => const SignUpScreen());
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_alarm),
            title: const Text('Orders'),
            onTap: () {
              if (fireStoreService.userLoggedIn) {
                Get.to(() => const OrdersScreen());
              } else {
                Get.to(() => const SignUpScreen());
              }
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.map_pin_ellipse),
            title: const Text('Address'),
            onTap: () {
              if (fireStoreService.userLoggedIn) {
                Get.to(() => const AddressScreen());
              } else {
                Get.to(() => const SignUpScreen());
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.call),
            title: const Text('Contact Us'),
            onTap: () {
              launch("tel://9549348495");
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.exit_to_app),
          //   title: const Text('AboutUs'),
          //   onTap: () {
          //     // Handle the tap on the Logout item
          //   },
          // ),
        ],
      ),
    );
  }
}
