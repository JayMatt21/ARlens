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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Color(0xFF0D3B66), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1976D2)),
            onPressed: _logout,
            tooltip: 'Logout',
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
            : RefreshIndicator(
                onRefresh: _fetchDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards
                      Row(
                        children: [
                          _buildSummaryCard('Pending', pendingCount, Colors.orange),
                          const SizedBox(width: 8),
                          _buildSummaryCard('Approved', approvedCount, Colors.green),
                          const SizedBox(width: 8),
                          _buildSummaryCard('Completed', completedCount, const Color(0xFF1976D2)),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF154360),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 14,
                        runSpacing: 14,
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
                            'Manage Technicians',
                            Icons.engineering,
                            Colors.teal,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ManageTechniciansPage()),
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
                                MaterialPageRoute(builder: (_) => const ManageProductsPage()),
                              ).then((_) => _fetchDashboardData());
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF154360),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (recentAppointments.isEmpty)
                        const Center(child: Text(
                          'No recent appointments',
                          style: TextStyle(color: Color(0xFF566573)),
                        ))
                      else
                        Column(
                          children: recentAppointments.map((appointment) {
                            final customerName = appointment['customer_name'] ?? 'No Name';
                            final service = appointment['service'] ?? 'Unknown Service';
                            final status = appointment['status'] ?? '';
                            final date = appointment['appointment_date'] ?? '';
                            return Card(
                              elevation: 2,
                              color: const Color(0xFFF9FBFC),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.schedule, color: Color(0xFF1976D2)),
                                title: Text(
                                  '$service - $customerName',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF0D3B66),
                                  ),
                                ),
                                subtitle: Text(
                                  status,
                                  style: const TextStyle(color: Color(0xFF566573)),
                                ),
                                trailing: Text(
                                  date,
                                  style: const TextStyle(color: Color(0xFF566573)),
                                ),
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
      ),
    );
  }

  Widget _buildSummaryCard(String title, int count, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.08),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.11),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.09),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
