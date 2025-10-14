import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageTechniciansPage extends StatefulWidget {
  const ManageTechniciansPage({super.key});

  @override
  State<ManageTechniciansPage> createState() => _ManageTechniciansPageState();
}

class _ManageTechniciansPageState extends State<ManageTechniciansPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> technicians = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadTechnicians();
  }

  Future<void> _loadTechnicians() async {
    setState(() => loading = true);
    try {
      final data = await supabase
          .from('users')
          .select('*')
          .eq('role', 'technician')
          .order('created_at', ascending: true);

      setState(() {
        technicians = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      debugPrint('Error loading technicians: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading technicians: $e')));
    }
  }

  Future<void> _showTechnicianForm({Map<String, dynamic>? tech}) async {
    final firstController = TextEditingController(text: tech?['first_name'] ?? '');
    final middleController = TextEditingController(text: tech?['middle_initial'] ?? '');
    final lastController = TextEditingController(text: tech?['last_name'] ?? '');
    final emailController = TextEditingController(text: tech?['email'] ?? '');

    final isNew = tech == null;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF9FBFC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isNew ? 'Add Technician' : 'Edit Technician',
            style: const TextStyle(color: Color(0xFF1976D2))),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: firstController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: middleController,
                decoration: const InputDecoration(labelText: 'Middle Initial'),
              ),
              TextField(
                controller: lastController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 3,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              final first = firstController.text.trim();
              final middle = middleController.text.trim();
              final last = lastController.text.trim();
              final email = emailController.text.trim();

              if (first.isEmpty || last.isEmpty || email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('First name, last name and email are required')),
                );
                return;
              }

              try {
                if (isNew) {
                  // Add new technician via Supabase Auth
                  final password = "Temp#${DateTime.now().millisecondsSinceEpoch}!";
                  final response = await supabase.auth.admin.createUser(
                    AdminUserAttributes(
                      email: email,
                      password: password,
                      emailConfirm: true, // or false for verification email
                    ),
                  );
                  final user = response.user;
                  if (user == null) throw Exception("Auth creation failed.");
                  final userId = user.id;

                  // Insert into users table
                  await supabase.from('users').insert({
                    'id': userId,
                    'first_name': first,
                    'middle_initial': middle,
                    'last_name': last,
                    'email': email,
                    'role': 'technician',
                    'created_at': DateTime.now().toIso8601String(),
                  });

                } else {
                  // Edit info only in users table
                  await supabase.from('users').update({
                    'first_name': first,
                    'middle_initial': middle,
                    'last_name': last,
                    'email': email,
                  }).eq('id', tech['id']);
                }

                Navigator.pop(context);
                _loadTechnicians();
              } catch (e) {
                debugPrint('Error saving technician: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving technician: $e')));
              }
            },
            child: Text(isNew ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTechnician(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF9FBFC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Technician', style: TextStyle(color: Color(0xFF1976D2))),
        content: const Text('Are you sure you want to delete this technician?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabase.from('users').delete().eq('id', id);
        // Optionally: delete also in Auth (needs api)
        _loadTechnicians();
      } catch (e) {
        debugPrint('Error deleting technician: $e');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting technician: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Technicians',
            style: TextStyle(color: Color(0xFF0D3B66))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showTechnicianForm(),
            icon: const Icon(Icons.add, color: Color(0xFF1976D2)),
            tooltip: 'Add Technician',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD0E8FF),
              Color(0xFF9BBDDF),
              Color(0xFFF9FBFC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF1976D2)))
            : technicians.isEmpty
                ? const Center(child: Text('No technicians found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: technicians.length,
                    itemBuilder: (context, index) {
                      final tech = technicians[index];
                      final fullName =
                          "${tech['first_name']} ${tech['middle_initial'] != null && tech['middle_initial'] != '' ? tech['middle_initial'] + '. ' : ''}${tech['last_name']}";
                      final email = tech['email'] ?? '';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: const Color(0xFFF9FBFC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          title: Text(fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1976D2),
                              )),
                          subtitle: Text(email,
                              style: const TextStyle(color: Color(0xFF566573))),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showTechnicianForm(tech: tech),
                                tooltip: 'Edit Technician',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTechnician(tech['id']),
                                tooltip: 'Delete Technician',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
