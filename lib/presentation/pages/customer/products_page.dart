import 'package:flutter/material.dart';
import 'book_appointment_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<String> cart = [];

  final products = [
    {"name": "Window Type Aircon", "price": 15000},
    {"name": "Split Type Aircon", "price": 25000},
    {"name": "Portable Aircon", "price": 18000},
  ];

  void _scheduleInstallation(String productName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookAppointmentPage(productName: productName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(products[index]['name'] as String),
            subtitle: Text("₱${products[index]['price']}"),
            trailing: IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () {
                setState(() {
                  cart.add(products[index]['name'] as String);
                });
              },
            ),
            onTap: () {
              _scheduleInstallation(products[index]['name'] as String);
            },
          ),
        );
      },
    );
  }
}
