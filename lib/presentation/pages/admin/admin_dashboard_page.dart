import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'manage_appointments_page.dart';
import 'manage_technician_page.dart';
import 'manage_products_page.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final supabase = Supabase.instance.client;

  int pendingCount = 0;
  int approvedCount = 0;
  int completedCount = 0;
  List<Map<String, dynamic>> recentAppointments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  
  Future<void> _fetchDashboardData() async {
    setState(() => loading = true);

    try {

        final pendingRes = await supabase
            .from('appointments')
            .select('id')
            .eq('status', 'Pending');

        pendingCount = (pendingRes as List).length;

        // Approved appointments count
        final approvedRes = await supabase
            .from('appointments')
            .select('id')
            .eq('status', 'Approved');

        approvedCount = (approvedRes as List).length;

        
        final completedRes = await supabase
            .from('appointments')
            .select('id')
            .eq('status', 'Completed');

        completedCount = (completedRes as List).length;


      final recentRes = await supabase
          .from('appointments')
          .select(
            '*, users!appointments_user_id_fkey(first_name, middle_initial, last_name)',
          )
          .order('created_at', ascending: false)
          .limit(5);

      final List<Map<String, dynamic>> recents = [];
      for (var appt in recentRes) {
        final user = appt['users'];
        final fullName = user != null
            ? "${user['first_name']} ${user['middle_initial'] != null && user['middle_initial'] != '' ? user['middle_initial'] + '. ' : ''}${user['last_name']}"
            : 'No Name';
        appt['customer_name'] = fullName;
        recents.add(Map<String, dynamic>.from(appt));
      }

      setState(() {

        pendingCount = (pendingRes as List).length;
        approvedCount = (approvedRes as List).length;
        completedCount = (completedRes as List).length;
        recentAppointments = recents;
        loading = false;
      });
    } catch (error, st) {
      debugPrint('Error fetching dashboard data: $error\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard: $error')),
        );
        setState(() => loading = false);
      }
    }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildSummaryCard('Pending', pendingCount, Colors.orange),
                        const SizedBox(width: 8),
                        _buildSummaryCard('Approved', approvedCount, Colors.green),
                        const SizedBox(width: 8),
                        _buildSummaryCard('Completed', completedCount, Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Quick Actions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildActionButton(
                          context,
                          'Manage Appointments',
                          Icons.event_note,
                          Colors.deepPurple,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ManageAppointmentsPage()),
                            ).then((_) => _fetchDashboardData());
                          },
                        ),
                        _buildActionButton(
                          context,
                          'Manage Technicians',
                          Icons.engineering,
                          Colors.teal,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ManageTechniciansPage()),
                            ).then((_) => _fetchDashboardData());
                          },
                        ),
                        _buildActionButton(
                          context,
                          'Manage Products',
                          Icons.inventory,
                          Colors.indigo,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ManageProductsPage()),
                            ).then((_) => _fetchDashboardData());
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text('Recent Activity',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    if (recentAppointments.isEmpty)
                      const Center(child: Text('No recent appointments'))
                    else
                      Column(
                        children: recentAppointments.map((appointment) {
                          final customerName = appointment['customer_name'] ?? 'No Name';
                          final service = appointment['service'] ?? 'Unknown Service';
                          final status = appointment['status'] ?? '';
                          final date = appointment['appointment_date'] ?? '';
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: const Icon(Icons.schedule),
                              title: Text('$service - $customerName',
                                  style: const TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: Text(status),
                              trailing: Text(date),
                              onTap: () {
                                // TODO: navigate to appointment details
                              },
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(String title, int count, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('$count',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 10),
            Text(label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
