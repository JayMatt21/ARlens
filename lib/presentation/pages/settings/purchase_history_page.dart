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
        .from('purchase')
        .select('''
          id,
          quantity,
          purchase_date,
          total_price,
          products (
            name
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

              return ListTile(
                title: Text(productName),
                subtitle: Text(
                  "Quantity: ${purchase['quantity']} | "
                  "Total: ${purchase['total_price']}",
                ),
                trailing: Text(
                  (purchase['purchase_date'] as String).split('T').first,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
