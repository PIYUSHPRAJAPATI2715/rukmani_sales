import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';
import 'package:myproject/bottom_navigation_bar_screen.dart';
import 'package:myproject/helper/new_helper.dart';
import 'package:myproject/screens/widgets/loading_animation.dart';
import 'package:upi_india/upi_app.dart';
import 'package:upi_india/upi_india.dart';
import '../../firebase_services/firestore_service.dart';
import '../../firebase_services/notification_api.dart';
import '../../helper/helper.dart';
import '../../model/model_address.dart';
import '../../model/model_cart_list.dart';
import '../../model/model_shipping_details.dart';
import '../orders/orders_screen.dart';
import 'check_in_stock.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen(
      {super.key, required this.address, required this.cityUpi});
  final ModelAddress address;
  final String cityUpi;

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  FirebaseFireStoreService fireStoreService = FirebaseFireStoreService();

  ModelShippingAddress? modelShippingAddress;

  bool upiLoaded = false;

  bool updatingValue = false;
  List<UpiApp> apps = [];
  UpiApp? upiApp;
  final UpiIndia _upiIndia = UpiIndia();

  updateValue({
    required String productId,
    required int productQuantity,
  }) {
    if (updatingValue == true) return;
    try {
      updatingValue = true;
      if (productQuantity != 0) {
        fireStoreService
            .updatePriceQuantity(
                productId: productId, productQuantity: productQuantity)
            .then((value) {
          updatingValue = false;
        }).catchError((e) {
          updatingValue = false;
        });
      } else {
        fireStoreService.removeProduct(productId: productId).then((value) {
          updatingValue = false;
        }).catchError((e) {
          updatingValue = false;
        });
      }
    } catch (e) {
      updatingValue = false;
      return;
    } finally {
      updatingValue = false;
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      getAvailableApps();
      // FirebaseFirestore.instance.collection("shipping_collection").get().then((value) {
      // print("Got Model Shipping address....     ${value.docs.first.data()}");
      // print("Got Model Shipping address....     ${value.docs.first.id}");
      // print("Got Model Shipping address....     ${value}");
      // });
      print("Got Model Shipping address....");
      fireStoreService.getShippingDetails().then((value) {
        modelShippingAddress = value;
        setState(() {});
      });
    });
  }

  ///Upi Payment

  getAvailableApps() {
    if (Platform.isAndroid) {
      _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
        apps = value;
        if (kDebugMode) {
          print(apps.map((e) => e.name).toString());
        }
        upiLoaded = true;
        setState(() {});
      }).catchError((e) {
        apps = [];
      });
    } else {
      apps = [];
      upiLoaded = true;
      cashOnDelivery.value = "Cod";
    }
  }

  Future<UpiResponse> initiateTransaction(
      UpiApp app, refId, double total) async {
    print("widget.cityUpi....      ${widget.cityUpi}");
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: widget.cityUpi,
      receiverName: modelShippingAddress!.shopName!,
      transactionRefId: refId,
      transactionNote: 'Add Funds',
      amount: total,
    );
  }

  addPaymentUPI(double total, shipping) {
    if (total > 100000) {
      showToast("Total Amount is greater than 1,00,000\n"
          "Lower the amount to initiate order");
      return;
    }
    if (upiApp == null && cashOnDelivery.isEmpty) {
      showToast("Select Available Payment Methods");
      return;
    }
    if (upiApp != null) {
      final refId = DateTime.now().microsecondsSinceEpoch.toString();
      initiateTransaction(upiApp!, refId, total).then((value) {
        if (value.status.toString() == "success") {
          // value.transactionId ?? refId;
          fireStoreService.checkOutTransaction(
              shipping: shipping,
              total: total.toString(),
              paymentMethod: upiApp != null
                  ? upiApp!.name.toString()
                  : cashOnDelivery.value,
              transactionId: value.transactionId ?? refId,
              address: widget.address.toJson(),
              context: context);
        } else {
          showToast("Payment Canceled");
        }
      });
    }
    if (cashOnDelivery.value == "Cod") {
      final refId = DateTime.now().microsecondsSinceEpoch.toString();
      fireStoreService.checkOutTransaction(
          shipping: shipping,
          total: total.toString(),
          paymentMethod:
              upiApp != null ? upiApp!.name.toString() : cashOnDelivery.value,
          transactionId: refId,
          address: widget.address.toJson(),
          context: context);
    }
  }

  RxString cashOnDelivery = "".obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          'Place Order',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 18),
        ),
      ),
      body: modelShippingAddress != null && upiLoaded
          ? SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              child: Column(
                children: [
                  addressCard(address: widget.address, ordersDetails: false),
                  const SizedBox(
                    height: 20,
                  ),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: fireStoreService.getCartList(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<ModelCartList> cartList = [];
                        if (snapshot.data == null) return const SizedBox();
                        cartList = snapshot.data!.docs
                            .map((e) => ModelCartList.fromJson(e.data()))
                            .toList();

                        double subTotalAmount = cartList
                            .map((e) =>
                                e.productQuantity!.toString().toNum *
                                (double.tryParse(
                                        e.productDetails!.price.toString()) ??
                                    0))
                            .toList()
                            .sum
                            .toDouble();
                        bool freeShipping = subTotalAmount >
                            modelShippingAddress!.minFreeShipping
                                .toString()
                                .toNum;

                        double totalAmount = freeShipping
                            ? subTotalAmount
                            : subTotalAmount +
                                modelShippingAddress!.shippingAmount!;

                        bool canBuy = true;

                        return Column(
                          children: [
                            ListView.builder(
                              itemCount: cartList.length,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final item = cartList[index];
                                return Padding(
                                  padding: const EdgeInsets.all(8.0)
                                      .copyWith(bottom: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 60,
                                        width: 60,
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            boxShadow: const [
                                              BoxShadow(
                                                blurRadius: 4,
                                                color: Color(0x3600000F),
                                                offset: Offset(0, 2),
                                              )
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(21),
                                            color: Colors.white),
                                        child: Image.network(
                                          item.productDetails!.imageUrl
                                              .toString(),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.productDetails!.name
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "${item.productQuantity!.toString()} x ${item.productDetails!.price.toString()}",
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "${item.productQuantity!.toString().toNum * item.productDetails!.price.toString().toNum} Rs",
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          int updateNew =
                                                              item.productQuantity! -
                                                                  1;
                                                          updateValue(
                                                              productId: item
                                                                  .productId!,
                                                              productQuantity:
                                                                  updateNew);
                                                        },
                                                        child: Container(
                                                          width: 28,
                                                          height: 28,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Colors
                                                                .black, // border color
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: const Center(
                                                              child: Text(
                                                            '--',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          )),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Center(
                                                          child: Text(
                                                        item.productQuantity
                                                            .toString(),
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      )),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          int updateNew =
                                                              item.productQuantity! +
                                                                  1;
                                                          updateValue(
                                                              productId: item
                                                                  .productId!,
                                                              productQuantity:
                                                                  updateNew);
                                                        },
                                                        child: Container(
                                                          width: 28,
                                                          height: 28,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Colors
                                                                .black, // border color
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: const Center(
                                                              child: Text(
                                                            '+',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          )),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                CheckInStock(
                                                  productID: item.productId,
                                                  inStock: (bool value) {
                                                    item.inStock = value;
                                                    canBuy = value;
                                                    if (kDebugMode) {
                                                      print(
                                                          "Value updated......    ${cartList.map((e) => e.inStock)}");
                                                    }
                                                    // print("Value updated......    $value");
                                                  },
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            paymentMethods(),
                            const SizedBox(
                              height: 16,
                            ),
                            paymentAmounts(
                                freeShipping, subTotalAmount, totalAmount),
                            const SizedBox(
                              height: 16,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (cartList
                                    .map((e) => e.inStock)
                                    .toList()
                                    .contains(null)) {
                                  showToast("Please wait");
                                  return;
                                }
                                if (canBuy == false) {
                                  showToast("some product is out of stock");
                                  return;
                                }
                                addPaymentUPI(
                                  totalAmount,
                                  freeShipping
                                      ? "0"
                                      : modelShippingAddress!.shippingAmount
                                          .toString(),
                                );
                                FirebaseFirestore.instance
                                    .collection('fcmtoken')
                                    .doc('admin_token')
                                    .get()
                                    .then((value) {
                                  // value.
                                  print(value.data()!["fcmtoken"]);
                                  sendPushNotification(
                                      body: 'Click here to watch this order',
                                      deviceToken: value.data()!["fcmtoken"],
                                      image: 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEi6UspEmsmGwyZV5M8fNpwaqg1nEoRENOjG2Wziyuw5XLA43MmBJOHJFyGEEwoITY4cYCmuAQTfffyBNB2EvLdfTY-j2EKvvQLtOl3yW2Za0ylLVTLdkgy_zsk7ikKCuDyhNhWETYMF8o8Z932_D1LZo3Ongu8m6nGmrtw7zyO7bhiltrIQOC241zRl4q8/s16000/Blue%20and%20Pink%20Professional%20Business%20Strategy%20Presentation%20(1).jpg',
                                      title: 'A new order is placed',
                                      orderID: '1');

                                  showToast("Order is Accepted");
                                });
                                Get.to(const OrdersScreen());
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              child: const Text(
                                'CheckOut',
                                style: TextStyle(
                                    fontSize: 15,
                                    letterSpacing: 2,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ],
              ),
            )
          : const LoadingAnimation(),
    );
  }

  Card paymentAmounts(
      bool freeShipping, double subTotalAmount, double totalAmount) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Text(
              "Purchase above ${modelShippingAddress!.minFreeShipping!} to get free shipping",
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(
              height: 14,
            ),
            Row(
              children: [
                const Expanded(
                    child: Text(
                  "Shipping:",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                )),
                Text(
                  freeShipping
                      ? "Free Shipping!"
                      : "${modelShippingAddress!.shippingAmount} Rs",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: freeShipping
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
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                )),
                Text(
                  "${subTotalAmount.toStringAsFixed(2)} Rs",
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
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                )),
                Text(
                  "${totalAmount.toStringAsFixed(2)} Rs",
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
    );
  }

  Card paymentMethods() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Text(
              "Select Payment Method",
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(
              height: 6,
            ),
            if (Platform.isAndroid)
              if (apps.isNotEmpty)
                ...apps
                    .map((e) => Obx(() {
                          if (refreshInt > 0) {}
                          return ListTile(
                            // dense: true,
                            contentPadding: EdgeInsets.zero,
                            onTap: () {
                              upiApp = e;
                              refreshInt.value =
                                  DateTime.now().millisecondsSinceEpoch;
                              cashOnDelivery.value = "";
                            },
                            visualDensity: VisualDensity.compact,
                            title: Text(e.name.toString()),
                            trailing: IgnorePointer(
                              ignoring: true,
                              child: Radio<UpiApp?>(
                                value: e,
                                visualDensity: VisualDensity.compact,
                                groupValue: upiApp,
                                onChanged: (fa) {},
                              ),
                            ),
                            leading: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.memory(e.icon),
                            ),
                          );
                        }))
                    .toList()
              else
                const Center(
                  child: Text("No UPI installed"),
                ),
            Obx(() => ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    upiApp = null;
                    refreshInt.value = DateTime.now().millisecondsSinceEpoch;
                    cashOnDelivery.value = "Cod";
                  },
                  visualDensity: VisualDensity.compact,
                  title: const Text("Cash On Delivery"),
                  trailing: IgnorePointer(
                    ignoring: true,
                    child: Radio<String?>(
                      value: "Cod",
                      visualDensity: VisualDensity.compact,
                      groupValue: cashOnDelivery.value,
                      onChanged: (fa) {
                        cashOnDelivery.value = "Cod";
                      },
                    ),
                  ),
                  leading: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.delivery_dining_rounded),
                    // child: Image.memory("e.icon"),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  RxInt refreshInt = 0.obs;
}

Card addressCard({
  required ModelAddress address,
  required bool ordersDetails,
}) {
  return Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Column(
            children: address
                .toJson()
                .entries
                .map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 5,
                              child: Text(
                                "${e.key.capitalize!} :",
                                style: GoogleFonts.poppins(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              )),
                          Expanded(
                              flex: 12,
                              child: Text(
                                e.value.toString().capitalize!,
                                style: GoogleFonts.urbanist(
                                  fontSize: 16,
                                  height: 1.2,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                        ],
                      ),
                    ))
                .toList(),
          ),
          if (!ordersDetails)
            ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  surfaceTintColor: Colors.blue,
                ),
                child: const Text(
                  "Edit Address",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ))
        ],
      ),
    ),
  );
}
