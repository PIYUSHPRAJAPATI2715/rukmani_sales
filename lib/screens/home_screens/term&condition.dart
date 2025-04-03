import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome to Royal Jewellery!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "By using our services, you agree to the following terms and conditions:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              _buildTermsPoint(
                  "1. Product Authenticity",
                  "All our jewellery is crafted with high-quality materials. However, slight variations may occur due to handcrafted designs."),
              _buildTermsPoint(
                  "2. Pricing & Payments",
                  "Prices are subject to change without notice. We accept multiple payment methods for your convenience."),
              _buildTermsPoint(
                  "3. Shipping & Delivery",
                  "We aim to deliver products on time, but delays due to unforeseen circumstances may occur."),
              _buildTermsPoint(
                  "4. Returns & Refunds",
                  "Returns are accepted within 7 days of purchase if the product remains unused and in original packaging."),
              _buildTermsPoint(
                  "5. User Conduct",
                  "Users must provide accurate information while purchasing and not misuse our services in any way."),
              _buildTermsPoint(
                  "6. Privacy Policy",
                  "We respect your privacy and ensure that your data is securely stored and not shared without consent."),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                  ),
                  child: const Text(
                    "Accept & Continue",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsPoint(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}