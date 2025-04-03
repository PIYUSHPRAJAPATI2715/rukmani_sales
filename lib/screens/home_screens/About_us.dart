import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About Us"),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "About Royal Jewellery",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text("Royal Jewellery is a luxury brand offering exquisite jewelry pieces."),
              SizedBox(height: 10),
              Text("Our Mission"),
              Text("To provide the finest jewelry with exceptional craftsmanship."),
              SizedBox(height: 10),
              Text("Our Vision"),
              Text("To be a globally recognized luxury jewelry brand."),
              SizedBox(height: 10),
              Text("Contact Us"),
              Text("Email: support@royaljewellery.com"),
              Text("Phone: +123 456 7890"),
            ],
          ),
        ),
      ),
    );
  }
}
