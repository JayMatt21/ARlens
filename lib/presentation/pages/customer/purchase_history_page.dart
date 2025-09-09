import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PurchaseHistoryPage extends StatefulWidget {
  const PurchaseHistoryPage({super.key});

  @override
  State<PurchaseHistoryPage> createState() => _PurchaseHistoryPageState();
}

class _PurchaseHistoryPageState extends State<PurchaseHistoryPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> purchases = [];

  @override
  void initState() {
    super.initState();
    _loadPurchaseHistory();
  }

  Future<void> _loadPurchaseHistory() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('purchases') // Make sure this table exists in your Supabase DB
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        purchases = List<Map<String, dynamic>>.from(response as List<dynamic>);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load purchase history: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Purchase History")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : purchases.isEmpty
              ? const Center(child: Text("No purchases found."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: purchases.length,
                  itemBuilder: (context, index) {
                    final purchase = purchases[index];
                    final date = purchase['created_at'] != null
                        ? DateFormat("yyyy-MM-dd – kk:mm")
                            .format(DateTime.parse(purchase['created_at']))
                        : 'Unknown date';
                    return Card(
                      child: ListTile(
                        title: Text(purchase['item_name'] ?? 'Unnamed Item'),
                        subtitle: Text("Amount: \$${purchase['amount'] ?? 0}\nDate: $date"),
                      ),
                    );
                  },
                ),
    );
  }
}
