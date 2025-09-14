import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'manage_appointments_page.dart';
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
      // optimized counts using the current API
      final pendingRes = await supabase
          .from('appointments')
          .select('id')
          .eq('status', 'Pending')
          .count(CountOption.exact);

      final approvedRes = await supabase
          .from('appointments')
          .select('id')
          .eq('status', 'Approved')
          .count(CountOption.exact);

      final completedRes = await supabase
          .from('appointments')
          .select('id')
          .eq('status', 'Completed')
          .count(CountOption.exact);

      // top 5 recent appointments
      final recentRes = await supabase
          .from('appointments')
          .select()
          .order('created_at', ascending: false)
          .limit(5);

      setState(() {
        pendingCount = pendingRes.count;
        approvedCount = approvedRes.count;
        completedCount = completedRes.count;
        recentAppointments = List<Map<String, dynamic>>.from(recentRes);
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
    context.go('/'); // go back to splash (works with GoRouter)
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
                    const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                              MaterialPageRoute(builder: (_) => const ManageAppointmentsPage()),
                            ).then((_) => _fetchDashboardData());
                          },
                        ),
                        _buildActionButton(
                          context,
                          'Technicians',
                          Icons.engineering,
                          Colors.teal,
                          () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon: Manage Technicians'))),
                        ),
                        _buildActionButton(
                          context,
                          'Products',
                          Icons.inventory,
                          Colors.indigo,
                          () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon: Manage Products'))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    if (recentAppointments.isEmpty)
                      const Center(child: Text('No recent appointments'))
                    else
                      Column(
                        children: recentAppointments.map((appointment) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: const Icon(Icons.schedule),
                              title: Text(appointment['service'] ?? 'Unknown Service', style: const TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: Text(appointment['status'] ?? ''),
                              trailing: Text(appointment['date'] ?? ''),
                              onTap: () {
                                // TODO: navigate to details
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
              Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 10),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
