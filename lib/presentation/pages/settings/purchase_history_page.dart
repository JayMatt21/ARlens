import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PurchaseHistoryPage extends StatefulWidget {
  const PurchaseHistoryPage({super.key});

  @override
  State<PurchaseHistoryPage> createState() => _PurchaseHistoryPageState();
}

class _PurchaseHistoryPageState extends State<PurchaseHistoryPage> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _futurePurchases;

  @override
  void initState() {
    super.initState();
    _futurePurchases = _loadPurchaseHistory();
  }

  Future<List<Map<String, dynamic>>> _loadPurchaseHistory() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception("No logged-in user");
    }

    final response = await supabase
        .from('purchase') // ✅ correct table
        .select('''
          id,
          quantity,
          purchase_date,
          total_price,
          products (
            name,
            price
          )
        ''')
        .eq('user_id', user.id)
        .order('purchase_date', ascending: false);

    return (response as List).map((e) => e as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Purchase History")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futurePurchases,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Failed to load Purchase History: ${snapshot.error}"),
            );
          }
          final purchases = snapshot.data ?? [];
          if (purchases.isEmpty) {
            return const Center(child: Text("No purchase history found."));
          }

          return ListView.builder(
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              final purchase = purchases[index];
              final product = purchase['products'] as Map<String, dynamic>?;
              final productName = product?['name'] ?? "Unknown Product";
              final unitPrice = product?['price'] ?? 0;
              final quantity = purchase['quantity'] ?? 0;
              final totalPrice = purchase['total_price'] ?? (unitPrice * quantity);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                child: ListTile(
                  title: Text(
                    productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Unit Price: ₱${unitPrice.toString()}"),
                      Text("Quantity: $quantity"),
                      Text("Total: ₱${totalPrice.toString()}"),
                    ],
                  ),
                  trailing: Text(
                    (purchase['purchase_date'] as String).split('T').first,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
