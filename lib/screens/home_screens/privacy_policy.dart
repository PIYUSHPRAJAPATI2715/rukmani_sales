import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Privacy Policy",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Welcome to Royal jewellery. Your privacy is important to us. This privacy policy explains how we collect, use, and protect your information when you use our app.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              _buildSection("1. Information We Collect", "We collect personal information like your name, email, phone number, and address when you register or make a purchase. We also collect non-personal data such as device information and analytics."),
              _buildSection("2. How We Use Your Information", "Your information is used to process orders, improve our services, and provide customer support. We do not sell or share your data with third parties."),
              _buildSection("3. Security Measures", "We use encryption and secure servers to protect your data from unauthorized access."),
              _buildSection("4. Your Choices", "You can update or delete your account information anytime by contacting us."),
              _buildSection("5. Changes to This Policy", "We may update this policy occasionally. Please review it periodically."),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: Text("Back"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          content,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}