import 'package:flutter/material.dart';

class BookAppointmentPage extends StatelessWidget {
  final String productName;
  const BookAppointmentPage({super.key, required this.productName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book Installation")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Schedule installation for: $productName"),
            const SizedBox(height: 20),
            const Text("This request will be sent for admin approval."),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Request sent to admin.")),
                );
                Navigator.pop(context);
              },
              child: const Text("Confirm"),
            ),
          ],
        ),
      ),
    );
  }
}
