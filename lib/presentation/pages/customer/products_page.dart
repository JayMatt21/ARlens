import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final products = [
    {
      "name": "Window Type Aircon",
      "price": 15000,
      "image": "assets/images/window_ac.png",
      "brands": ["LG", "Samsung", "Carrier"],
      "sizes": ["0.5 HP", "1.0 HP", "1.5 HP"]
    },
    {
      "name": "Split Type Aircon",
      "price": 25000,
      "image": "assets/images/split_ac.png",
      "brands": ["Daikin", "Panasonic", "Midea"],
      "sizes": ["1.0 HP", "1.5 HP", "2.0 HP"]
    },
    {
      "name": "Portable Aircon",
      "price": 18000,
      "image": "assets/images/portable_ac.png",
      "brands": ["Kolin", "Sharp", "Midea"],
      "sizes": ["1.0 HP", "1.5 HP"]
    },
  ];

  void _openProductDetails(Map<String, dynamic> product) {
    String? selectedBrand;
    String? selectedSize;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product header
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            product["image"] as String,
                            height: 120,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            product["name"] as String,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "₱${product["price"]}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Brand selection
                    const Text("Select Brand",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: (product["brands"] as List<String>)
                          .map(
                            (brand) => ChoiceChip(
                              label: Text(brand),
                              selected: selectedBrand == brand,
                              onSelected: (value) {
                                setModalState(() {
                                  selectedBrand = brand;
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),

                    // Size selection
                    const Text("Select Size",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: (product["sizes"] as List<String>)
                          .map(
                            (size) => ChoiceChip(
                              label: Text(size),
                              selected: selectedSize == size,
                              onSelected: (value) {
                                setModalState(() {
                                  selectedSize = size;
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 30),

                    // Proceed button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (selectedBrand != null && selectedSize != null)
                            ? () {
                                Navigator.pop(context); // close modal
                                context.push(
                                  '/scheduling',
                                  extra: {
                                    "brand": selectedBrand,
                                    "size": selectedSize,
                                    "title": product["name"],
                                  },
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Proceed to Schedule",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () => _openProductDetails(product),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.asset(
                    product["image"] as String,
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        product["name"] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₱${product["price"]}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
