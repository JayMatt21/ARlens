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
      // ✅ Correct join: appointments -> users -> profiles
      final response = await supabase
          .from('appointments')
          .select(
            '''
            *,
            users!inner(
              id,
              profiles!inner(
                id,
                full_name
              )
            )
            '''
          )
          .order('created_at', ascending: false);

      setState(() {
        appointments = List<Map<String, dynamic>>.from(response);
        loading = false;
      });
    } catch (error) {
      setState(() {
        loading = false;
      });
      debugPrint("Error loading appointments: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading appointments: $error")),
      );
    }
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    try {
      await supabase
          .from('appointments')
          .update({'status': newStatus})
          .eq('id', id);

      _loadAppointments(); // refresh list
    } catch (e) {
      debugPrint("Error updating status: $e");
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

                    // ✅ Properly get customer name from profiles
                    final customerName = appointment['users']?['profiles']?['full_name'] ?? 'No Name';

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
                              "${appointment["service"] ?? 'Unknown Service'} - $customerName",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            if (appointment["details"] != null)
                              Text("Details: ${appointment["details"]}"),

                            const SizedBox(height: 6),

                            if (appointment["appointment_date"] != null)
                              Text(
                                "Appointment: ${_formatDateTime(appointment["appointment_date"])}",
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
