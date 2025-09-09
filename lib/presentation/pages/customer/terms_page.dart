import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              "Terms & Conditions",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "Welcome to our application. By using this app, you agree to the following terms and conditions. "
              "Please read them carefully:\n\n"
              "1. Acceptance of Terms: By accessing or using our app, you agree to comply with these terms.\n\n"
              "2. User Conduct: Users must not engage in illegal activities or violate other users' rights.\n\n"
              "3. Privacy: We respect your privacy. Please review our Privacy Policy to understand how your data is handled.\n\n"
              "4. Changes to Terms: We may update these terms at any time. Continued use of the app constitutes acceptance of changes.\n\n"
              "5. Limitation of Liability: We are not liable for any damages arising from your use of the app.\n\n"
              "For the full terms, please visit our website or contact support.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
