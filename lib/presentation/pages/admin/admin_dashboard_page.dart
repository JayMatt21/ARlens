import 'package:flutter/material.dart';
import 'manage_appointments_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟦 Summary cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryCard("Pending", "5", Colors.orange),
                _buildSummaryCard("Approved", "12", Colors.green),
                _buildSummaryCard("Completed", "8", Colors.blue),
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

            // 🟦 Recent activity (placeholder)
            const Text(
              "Recent Activity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text("Aircon Installation - Juan Dela Cruz"),
                subtitle: const Text("Pending approval"),
                trailing: const Text("Sept 14, 2025"),
                onTap: () {
                  // Navigate to appointment details
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text("Repair Service - Maria Santos"),
                subtitle: const Text("Approved"),
                trailing: const Text("Sept 13, 2025"),
              ),
            ),
          ],
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
