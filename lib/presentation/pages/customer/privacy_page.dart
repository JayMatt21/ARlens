import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Notice"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              "Privacy Notice",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "Your privacy is important to us. By using this application, you agree to the collection "
              "and use of information in accordance with this notice.\n\n"
              "1. Information Collection: We may collect personal information such as your name, email, "
              "and usage data to improve our services.\n\n"
              "2. Use of Information: The information collected is used to provide, maintain, and enhance our services.\n\n"
              "3. Data Sharing: We do not sell your personal information. Data may be shared with trusted third parties "
              "for service improvement or legal requirements.\n\n"
              "4. Data Security: We implement measures to protect your personal data from unauthorized access.\n\n"
              "5. Changes to Privacy Notice: This notice may be updated periodically. Continued use of the app constitutes acceptance of the changes.\n\n"
              "For more details, please contact our support team.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
