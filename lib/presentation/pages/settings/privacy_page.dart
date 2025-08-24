import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Notice")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "This is the Privacy Policy...\n\n(You can load this from API or static text file later.)",
        ),
      ),
    );
  }
}
