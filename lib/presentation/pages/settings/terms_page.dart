import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms & Conditions")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Here are the Terms and Conditions...\n\n(You can load this from API or static text file later.)",
        ),
      ),
    );
  }
}
