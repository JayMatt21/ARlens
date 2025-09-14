import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageTechniciansPage extends StatefulWidget {
  const ManageTechniciansPage({super.key});

  @override
  State<ManageTechniciansPage> createState() => _ManageTechniciansPageState();
}

class _ManageTechniciansPageState extends State<ManageTechniciansPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> technicians = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadTechnicians();
  }

  // ------------------ Fetch Technicians ------------------
  Future<void> _loadTechnicians() async {
    setState(() {
      loading = true;
    });

    try {
      final data = await supabase
          .from('users')
          .select('*')
          .eq('role', 'technician')
          .order('created_at', ascending: true);

      setState(() {
        technicians = data as List<dynamic>;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      debugPrint("Error loading technicians: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading technicians: $e")),
      );
    }
  }

  // ------------------ Delete Technician (optional) ------------------
  Future<void> _deleteTechnician(String id) async {
    try {
      await supabase.from('users').delete().eq('id', id);
      _loadTechnicians(); // refresh list
    } catch (e) {
      debugPrint("Error deleting technician: $e");
    }
  }

  // ------------------ Build UI ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Technicians"),
        backgroundColor: Colors.blueAccent,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : technicians.isEmpty
              ? const Center(child: Text("No technicians found."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: technicians.length,
                  itemBuilder: (context, index) {
                    final tech = technicians[index];
                    final fullName =
                        "${tech['first_name']} ${tech['middle_initial'] ?? ''} ${tech['last_name']}";
                    final email = tech['email'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(email),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTechnician(tech['id']),
                              tooltip: "Delete Technician",
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
