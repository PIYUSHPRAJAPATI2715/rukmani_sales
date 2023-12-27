import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myproject/firebase_services/firestore_service.dart';

import '../../model/model_product.dart';

class CheckInStock extends StatefulWidget {
  const CheckInStock({super.key, required this.productID, required this.inStock});
  final String productID;
  final Function(bool gg) inStock;

  @override
  State<CheckInStock> createState() => _CheckInStockState();
}

class _CheckInStockState extends State<CheckInStock> {
  final FirebaseFireStoreService fireStoreService = FirebaseFireStoreService();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fireStoreService.getProductDetails(productId: widget.productID),
      builder: (BuildContext context, AsyncSnapshot<Product?> snapshot) {
        if (snapshot.hasData) {
          final product = snapshot.data;
          if (product == null) {
            return const SizedBox();
          }
          widget.inStock(product.inStock == true);
          return product.inStock == true
              ? Text(
                  "InStock",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.greenAccent.shade700),
                )
              : Text(
                  "Out of Stock",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.redAccent.shade700),
                );
        }
        return const SizedBox();
      },
    );
  }
}
