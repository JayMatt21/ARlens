import 'package:flutter/material.dart';

class PurchaseHistoryPage extends StatelessWidget {
  const PurchaseHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Purchase History")),
      body: const Center(
        child: Text("Purchase history will be displayed here."),
      ),
    );
  }
}
