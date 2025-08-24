import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Notice")),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          """
          # Privacy Policy
          Effective Date: January 1, 2025

          Senfrost Aircon Dealer and Installer values your privacy...
          
          1. Information We Collect
          - Personal details (name, email, phone)
          - Purchase history
          - Camera access for area calculator

          2. How We Use Your Data
          - To process purchases and installation
          - To provide customer support
          - To send updates and offers

          3. Data Sharing
          - With service providers (delivery, payments)
          - With authorities as required by law

          4. Your Rights
          - Access, update, or request deletion of your data
          - Opt-out of marketing

          Contact us at: 0917 148 4128 | https://www.facebook.com/SenfrostAirconditioningSystemsServices/
          """,
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
