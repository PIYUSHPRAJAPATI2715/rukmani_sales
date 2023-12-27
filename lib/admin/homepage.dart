import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myproject/admin/addproduct.dart';
import 'package:myproject/screens/widgets/common_app_bar.dart';

import '../screens/orders/orders_screen.dart';
import 'view_products_list.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: "Admin Panel",
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                Get.to(const ViewProductsLList());
              },
              child: Container(
                height: 50,
                width: Get.width,
                decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(21)),
                child: const Center(
                    child: Text(
                  'View Product',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            InkWell(
              onTap: () {
                Get.to(() => const OrdersScreen(
                      admin: true,
                    ));
              },
              child: Container(
                height: 50,
                width: Get.width,
                decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(21)),
                child: const Center(
                    child: Text(
                  'Show Order',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
