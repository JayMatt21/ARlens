import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    setState(() {
      loading = true;
    });

    try {
      final data = await supabase
          .from('appointments')
          .select('*, profiles: user_id (full_name)')
          .order('created_at', ascending: false);

      setState(() {
        appointments = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      debugPrint("Error loading appointments: $e");
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading appointments: $e")),
      );
    }
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    try {
      await supabase
          .from('appointments')
          .update({'status': newStatus})
          .eq('id', id);

      _loadAppointments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating status: $e")),
      );
    }
  }

  String _formatDateTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat("MMM d, yyyy – hh:mm a").format(dt);
    } catch (e) {
      return isoString;
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
                    final customerName = appointment['profiles']?['full_name'] ?? 'No Name';

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
                              "${appointment['service'] ?? 'Unknown'} - $customerName",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (appointment['details'] != null)
                              Text("Details: ${appointment['details']}"),
                            const SizedBox(height: 6),
                            if (appointment['appointment_date'] != null)
                              Text(
                                "Appointment: ${_formatDateTime(appointment['appointment_date'])}",
                              ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  label: Text(appointment['status'] ?? 'N/A'),
                                  backgroundColor:
                                      appointment['status'] == "Pending"
                                          ? Colors.orange.shade100
                                          : appointment['status'] == "Approved"
                                              ? Colors.green.shade100
                                              : Colors.red.shade100,
                                  labelStyle: TextStyle(
                                    color: appointment['status'] == "Pending"
                                        ? Colors.orange
                                        : appointment['status'] == "Approved"
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                                if (appointment['status'] == "Pending") ...[
                                  TextButton.icon(
                                    onPressed: () =>
                                        _updateStatus(appointment['id'], "Approved"),
                                    icon: const Icon(Icons.check, color: Colors.green),
                                    label: const Text("Approve"),
                                  ),
                                  TextButton.icon(
                                    onPressed: () =>
                                        _updateStatus(appointment['id'], "Rejected"),
                                    icon: const Icon(Icons.close, color: Colors.red),
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
