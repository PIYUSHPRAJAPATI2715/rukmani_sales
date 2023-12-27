import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myproject/firebase_services/firestore_service.dart';
import 'package:myproject/screens/widgets/loading_animation.dart';
import '../../model/order_details.dart';
import 'order_details.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, this.admin});
  final bool? admin;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final FirebaseFireStoreService fireStoreService = FirebaseFireStoreService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Orders',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 18),
        ),
      ),
      body: StreamBuilder(
        stream: widget.admin == true ? fireStoreService.getAdminOrdersList() : fireStoreService.getOrdersList(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == null) return const SizedBox();
            log(snapshot.data!.docs.map((e) => jsonEncode(e.data())).toList().toString());
            List<ModelOrderDetails> ordersList =
                snapshot.data!.docs.map((e) => ModelOrderDetails.fromJson(e.data(), e.id)).toList();
            return ListView.builder(
                itemCount: ordersList.length,
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final order = ordersList[index];
                  final productDetails = ordersList[index].productsList!.first.productDetails;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: InkWell(
                      onTap: () {
                        Get.to(
                            () => OrderDetails(
                                  modelOrderDetails: order,
                                  admin: widget.admin,
                                ),
                            transition: Transition.rightToLeft);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 80,
                                width: 80,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 4,
                                    color: Color(0x3600000F),
                                    offset: Offset(0, 2),
                                  )
                                ], borderRadius: BorderRadius.circular(21), color: Colors.white),
                                child: Image.network(
                                  productDetails!.imageUrl!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.productsList!
                                          .map((e) => e.productDetails!.name.toString())
                                          .toList()
                                          .join("+"),
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.teal, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      "${order.totalAmount} Rs",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    order.isCancelled == true ?
                                    Text(
                                      "Order cancelled",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red,
                                      ),
                                    ) : const SizedBox(),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    order.dispatch == false && order.delivered == false && order.isCancelled == false ?
                                    Text(
                                      "Order Pending",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red,
                                      ),
                                    ) : const SizedBox(),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    order.dispatch == true && order.isCancelled == false ? Text(
                                      "Order Dispatch",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.orange,
                                      ),
                                    ) : const SizedBox(),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    order.delivered == true && order.isCancelled == false ? Text(
                                      "Order delivered",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.green,
                                      ),
                                    ) : const SizedBox(),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      DateFormat("dd MMM, yyyy  hh:mm a")
                                          .format(DateTime.fromMillisecondsSinceEpoch(order.orderTimeInMilliSec!)),
                                      style: GoogleFonts.urbanist(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_forward_ios_rounded),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                });
          }
          return const LoadingAnimation();
        },
      ),
    );
  }
}
