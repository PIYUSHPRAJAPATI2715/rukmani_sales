import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myproject/firebase_services/firestore_service.dart';
import 'package:myproject/firebase_services/notification_api.dart';
import 'package:myproject/helper/helper.dart';
import 'package:myproject/helper/new_helper.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/order_details.dart';
import '../check_out/check_out_screen.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key, required this.modelOrderDetails, this.admin});
  final ModelOrderDetails modelOrderDetails;
  final bool? admin;

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final FirebaseFireStoreService fireStoreService = FirebaseFireStoreService();

  bool dispatch = false;
  bool delivered = false;
  bool isOrderCancelable = false;
  TextEditingController cancelController = TextEditingController();

  void cancelOrder() async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.modelOrderDetails.orderId)
        .update({'isCancelled': true});

    setState(() {
      isOrderCancelable = true;
    });
    showToast('Your order has been cancelled');
  }

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    dispatch = widget.modelOrderDetails.dispatch!;
    delivered = widget.modelOrderDetails.delivered!;
    // gettoken();
  }

  @override
  Widget build(BuildContext context) {
    log(widget.modelOrderDetails.userId.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Orders Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomScrollView(
          slivers: [
            SliverList.builder(
                itemCount: widget.modelOrderDetails.productsList!.length,
                itemBuilder: (context, index) {
                  final productDetails =
                      widget.modelOrderDetails.productsList![index];
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
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
                              decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      blurRadius: 4,
                                      color: Color(0x3600000F),
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(21),
                                  color: Colors.white),
                              child: Image.network(
                                productDetails.productDetails!.imageUrl!,
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
                                    productDetails.productDetails!.name
                                        .toString(),
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.teal,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${productDetails.productQuantity}x${productDetails.productDetails!.price}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "${(productDetails.productDetails!.price.toString().toNum * productDetails.productQuantity.toString().toNum).toStringAsFixed(2)} Rs",
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: addressCard(
                    address: widget.modelOrderDetails.address!,
                    ordersDetails: true),
              ),
            ),
            SliverToBoxAdapter(
              child: Card(
                margin: const EdgeInsets.only(top: 20),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    children: [
                      if (widget.modelOrderDetails.paymentMethod != null) ...[
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const Expanded(
                                child: Text(
                              "Payment Method:",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 16),
                            )),
                            Text(
                              widget.modelOrderDetails.paymentMethod,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Text(
                            "Transaction ID:",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Text(
                              widget.modelOrderDetails.transactionId,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Expanded(
                              child: Text(
                            "Shipping:",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          )),
                          Text(
                            widget.modelOrderDetails.shipping.toString() == "0"
                                ? "Free Shipping!"
                                : "${widget.modelOrderDetails.shipping.toString()} Rs",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: widget.modelOrderDetails.shipping
                                            .toString() ==
                                        "0"
                                    ? Colors.greenAccent.shade700
                                    : Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Expanded(
                              child: Text(
                            "Subtotal:",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          )),
                          Text(
                            "${(widget.modelOrderDetails.totalAmount.toString().toNum - widget.modelOrderDetails.shipping.toString().toNum).toStringAsFixed(2)} Rs",
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Expanded(
                              child: Text(
                            "Total:",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          )),
                          Text(
                            "${widget.modelOrderDetails.totalAmount.toString()} Rs",
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Card(
                    margin: const EdgeInsets.only(top: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: StreamBuilder<Object>(
                          stream: null,
                          builder: (context, snapshot) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      "Dispatch",
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16),
                                    )),
                                    widget.admin == true
                                        ? CupertinoSwitch(
                                            value: dispatch,
                                            onChanged: (value) {
                                              fireStoreService
                                                  .updateOrdersDetails(
                                                      delivered: value == false
                                                          ? false
                                                          : delivered,
                                                      dispatch: value,
                                                      orderID: widget
                                                          .modelOrderDetails
                                                          .orderId,
                                                      updated: (bool gg) {
                                                        dispatch = value;
                                                        if (value == false) {
                                                          delivered = false;
                                                        }
                                                        if (value == true) {
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'fcmtoken')
                                                              .doc(widget
                                                                  .modelOrderDetails
                                                                  .userId)
                                                              .get()
                                                              .then((value) {
                                                            if (value.exists) {
                                                              sendPushNotification(
                                                                  body: 'Contact us for any query : - 13prajapatipiyush15@gmail.com',
                                                                  deviceToken: value.data()!["fcmtoken"],
                                                                  image:
                                                                      "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiYcetW9NF6LmnrfB5wHc9r5cGsdkbseUNUqnqrFf6yYpGw25PaCM7fWmtQZXoLW1zGgHqmd-t3es-3BinZ-i6a5ja5Kl0Gyw4XL2VaIkm76GLbr5J2PrLziNzFqPm8LULyfthqRgxMNuC3Kf0Zty8MBCnCmhtt6QpyLDvDwFhYVtQ8RwMRfTkAMAVLlI0/s16000/Your%20Order%20will%20be%20deliver.png",
                                                                  title:
                                                                      'Your Order is dispatch from our side',
                                                                  orderID: '3');
                                                            }
                                                          });
                                                          showToast(
                                                              "Order is dispatch");
                                                        }
                                                        setState(() {});
                                                      });
                                            })
                                        : dispatch
                                            ? Text(
                                                "Done",
                                                style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors
                                                        .greenAccent.shade700),
                                              )
                                            : Text(
                                                "Pending",
                                                style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors
                                                        .orangeAccent.shade700),
                                              ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      "Delivered",
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16),
                                    )),
                                    widget.admin == true
                                        ? CupertinoSwitch(
                                            value: delivered,
                                            onChanged: (value) {
                                              fireStoreService
                                                  .updateOrdersDetails(
                                                      delivered: value,
                                                      dispatch: true,
                                                      orderID: widget
                                                          .modelOrderDetails
                                                          .orderId,
                                                      updated: (bool gg) {
                                                        delivered = value;
                                                        dispatch = true;
                                                        if (value == true) {

                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                              'fcmtoken')
                                                              .doc(widget
                                                              .modelOrderDetails
                                                              .userId)
                                                              .get()
                                                              .then((value) {
                                                            if (value.exists) {
                                                              sendPushNotification(
                                                                  body: 'Thanks for taking Borwar oil',
                                                                  deviceToken: value.data()!["fcmtoken"],
                                                                  image:
                                                                  "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiQ7G30050tUKY85hHzPZbRn6h5pAI73XO-hkXQmjcaM4YeHISX_sVOOY7uoLKmMtH69407vKotjOrny51PErCAYu3qiVzq5bccATSVHYwYclFTLrBlr6U_jixKl3ow1xV2o7f18Ln65GmMWRtI02DsMj9FLodBwzI18S0DMmseoJAbyXw5snSC-hKZ_vc/s16000/Blue%20and%20Pink%20Professional%20Business%20Strategy%20Presentation.jpg",
                                                                  title: 'Your Order is delivered',
                                                                  orderID: '3');
                                                            }
                                                          });
                                                          showToast(
                                                              "Order is delivered");
                                                        }
                                                        setState(() {});
                                                      });
                                            })
                                        : delivered
                                            ? Text(
                                                "Done",
                                                style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors
                                                        .greenAccent.shade700),
                                              )
                                            : Text(
                                                "Pending",
                                                style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors
                                                        .orangeAccent.shade700),
                                              ),
                                  ],
                                ),
                              ],
                            );
                          }),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('orders')
                        .doc(widget.modelOrderDetails.orderId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(); // Show a loading indicator
                      }

                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Text('Document does not exist');
                      }

                      var isOrderCancelable = snapshot.data!.get('isCancelled');
                      var isOrderDelivered = snapshot.data!.get('delivered');

                      return isOrderCancelable || isOrderDelivered
                          ? isOrderCancelable
                              ? const Text(
                                  'This order is cancelled',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 20),
                                )
                              : const Text(
                                  'This order is Delivered',
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 20),
                                )
                          : InkWell(
                              onTap: isOrderCancelable
                                  ? null
                                  : () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Enter Cancelation Reason'),
                                            content: TextFormField(
                                              controller: cancelController,
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('No'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: const Text('Yes'),
                                                onPressed: () {
                                                  if (cancelController
                                                      .text.isEmpty) {
                                                    showToast(
                                                        'Please Enter Reason');
                                                  } else {
                                                    cancelOrder();
                                                    Navigator.of(context).pop();
                                                  }
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                              child: Container(
                                height: 50,
                                width: Get.width,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Cancel Order',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton.icon(
                      onPressed: () async {
                        var url =
                            'https://wa.me/9549348495?text=Borawar Help Support';
                        await launch(url);
                      },
                      icon: Image.asset(
                        'assets/images/whatsapp.png',
                        height: 30,
                      ),
                      label: const Text('Contact Us')),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
