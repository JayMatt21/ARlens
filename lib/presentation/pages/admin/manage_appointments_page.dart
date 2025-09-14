import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageAppointmentsPage extends StatefulWidget {
  const ManageAppointmentsPage({super.key});

  @override
  State<ManageAppointmentsPage> createState() => _ManageAppointmentsPageState();
}

class _ManageAppointmentsPageState extends State<ManageAppointmentsPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> appointments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final data = await supabase
          .from('appointments')
          .select('id, status, appointment_date, created_at, user_id, profiles(email, full_name)')
          .order('created_at', ascending: false);

      setState(() {
        appointments = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      debugPrint("Error loading appointments: $e");
      setState(() => loading = false);
    }
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    try {
      await supabase
          .from('appointments')
          .update({'status': newStatus, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id);

      _loadAppointments(); // refresh list
    } catch (e) {
      debugPrint("Error updating status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Appointments"),
        backgroundColor: Colors.blueAccent,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : appointments.isEmpty
              ? const Center(child: Text("No appointments found."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];

                    final profile = appointment["profiles"] ?? {};
                    final customerName = profile["full_name"] ?? "Unknown";
                    final customerEmail = profile["email"] ?? "No Email";

                    final appointmentDate = appointment["appointment_date"] != null
                        ? DateTime.parse(appointment["appointment_date"])
                        : null;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Customer: $customerName",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("Email: $customerEmail"),
                            if (appointmentDate != null)
                              Text(
                                "Appointment: ${appointmentDate.toLocal()}",
                                style: const TextStyle(color: Colors.black87),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(appointment["status"] ?? 'N/A'),
                                  backgroundColor:
                                      appointment["status"] == "Pending"
                                          ? Colors.orange.shade100
                                          : appointment["status"] == "Approved"
                                              ? Colors.green.shade100
                                              : Colors.red.shade100,
                                  labelStyle: TextStyle(
                                    color: appointment["status"] == "Pending"
                                        ? Colors.orange
                                        : appointment["status"] == "Approved"
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                                if (appointment["status"] == "Pending") ...[
                                  TextButton.icon(
                                    onPressed: () => _updateStatus(
                                        appointment["id"], "Approved"),
                                    icon: const Icon(Icons.check,
                                        color: Colors.green),
                                    label: const Text("Approve"),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _updateStatus(
                                        appointment["id"], "Rejected"),
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    label: const Text("Reject"),
                                  ),
                                ]
                              ],
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
