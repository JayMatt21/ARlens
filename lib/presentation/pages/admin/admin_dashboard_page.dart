import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'manage_appointments_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int pendingCount = 0;
  int approvedCount = 0;
  int completedCount = 0;
  List<Map<String, dynamic>> recentAppointments = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    final supabase = Supabase.instance.client;

    try {
      // Get all appointments
      final response = await supabase
          .from('appointments')
          .select()
          .order('created_at', ascending: false);

      final data = List<Map<String, dynamic>>.from(response);

      // Count statuses
      setState(() {
        pendingCount =
            data.where((item) => item['status'] == 'Pending').length;
        approvedCount =
            data.where((item) => item['status'] == 'Approved').length;
        completedCount =
            data.where((item) => item['status'] == 'Completed').length;

        // Get top 5 recent
        recentAppointments = data.take(5).toList();
      });
    } catch (error) {
      debugPrint("Error fetching dashboard data: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading dashboard: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.blueAccent,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🟦 Summary cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryCard("Pending", "$pendingCount", Colors.orange),
                  _buildSummaryCard("Approved", "$approvedCount", Colors.green),
                  _buildSummaryCard("Completed", "$completedCount", Colors.blue),
                ],
              ),
              const SizedBox(height: 20),

              // 🟦 Quick Actions
              const Text(
                "Quick Actions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildActionButton(
                    context,
                    "Manage Appointments",
                    Icons.event_note,
                    Colors.deepPurple,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageAppointmentsPage(),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    context,
                    "Technicians",
                    Icons.engineering,
                    Colors.teal,
                    () {
                      // TODO: Navigate to technician management
                    },
                  ),
                  _buildActionButton(
                    context,
                    "Products",
                    Icons.inventory,
                    Colors.indigo,
                    () {
                      // TODO: Navigate to products page
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // 🟦 Recent activity
              const Text(
                "Recent Activity",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              if (recentAppointments.isEmpty)
                const Center(
                  child: Text("No recent appointments"),
                )
              else
                Column(
                  children: recentAppointments.map((appointment) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.schedule),
                        title: Text(
                          "${appointment['service'] ?? 'Unknown Service'}",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text("${appointment['status']}"),
                        trailing: Text(
                          appointment['date'] ?? '',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        onTap: () {
                          // TODO: Navigate to appointment details
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

  // Widget helper para sa summary card
  Widget _buildSummaryCard(String title, String count, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(color: color)),
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
