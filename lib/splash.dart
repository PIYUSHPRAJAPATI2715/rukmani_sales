import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myproject/screens/home_screens/homepage.dart';

import 'firebase_services/firestore_service.dart';
import 'screens/auth/signup.dart';
import 'screens/home_screens/profile.dart';
import 'bottom_navigation_bar_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  next() {
    Timer(const Duration(seconds: 4), () async {
      checkLogin();
    });
  }

  checkLogin() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      bool userExists = await FirebaseFireStoreService().checkUserProfile();
      if (userExists == true) {
        Get.offAll(() => const BottomNavigationScreen());
      } else {
        Get.offAll(const ProfileScreen(
          fromLogin: true,
        ));
      }
    } else {
      Get.offAll(() => const BottomNavigationScreen());
    }
  }

  @override
  void initState() {
    super.initState();
    next();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/images/R.gif',

            ),
          ),
          const SizedBox(
            height: 18,
          ),
          // const Center(
          //   child: Text(
          //     "Let's get started",
          //     style: TextStyle(
          //       fontSize: 26,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          // ),
          // const SizedBox(
          //   height: 10,
          // ),
          // const Center(
          //   child: Text(
          //     "Never a better time than now to start.",
          //     style: TextStyle(
          //       fontSize: 20,
          //       fontWeight: FontWeight.bold,
          //       color: Colors.black38,
          //     ),
          //     textAlign: TextAlign.center,
          //   ),
          // ),
          // const SizedBox(
          //   height: 38,
          // ),
        ],
      ),
    );
  }
}
