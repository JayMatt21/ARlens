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
  List<dynamic> appointments = [];
  bool loading = true;
  List<dynamic> technicians = []; // For technician assignment

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _loadTechnicians();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      loading = true;
    });
    try {
      final data = await supabase
          .from('appointments')
          .select('''
            *,
            users!appointments_user_id_fkey(
              first_name,
              middle_initial,
              last_name
            ),
            technician:assigned_technician_id(
              first_name, last_name
            )
          ''')
          .order('created_at', ascending: false);
      final List<dynamic> appointmentList = data as List<dynamic>;
      for (var appt in appointmentList) {
        final user = appt['users'];
        final firstName = user?['first_name'] ?? '';
        final middleInitial = user?['middle_initial'] ?? '';
        final lastName = user?['last_name'] ?? '';
        final fullName = '$firstName ${middleInitial.isNotEmpty ? middleInitial + '. ' : ''}$lastName';
        appt['customer_name'] = fullName.isNotEmpty ? fullName : 'No Name';
        // Technician assigned name (optional)
        if (appt['technician'] != null) {
          final t = appt['technician'];
          appt['technician_name'] = "${t?['first_name'] ?? ''} ${t?['last_name'] ?? ''}";
        }
      }
      setState(() {
        appointments = appointmentList;
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

  Future<void> _loadTechnicians() async {
    // Load all users with technician role
    try {
      final techs = await supabase
          .from('users')
          .select('id, first_name, last_name')
          .eq('role', 'technician'); // adjust if you use role_id
      setState(() {
        technicians = techs as List<dynamic>;
      });
    } catch (e) {
      debugPrint("Error loading technicians: $e");
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
      debugPrint("Error updating status: $e");
    }
  }

  Future<void> _suggestSchedule(String apptId) async {
    DateTime? newDate;
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF9FBFC),
        title: const Text("Suggest New Schedule", style: TextStyle(color: Color(0xFF1976D2))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              readOnly: true,
              decoration: const InputDecoration(labelText: "Select New Date & Time"),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: 9, minute: 0),
                  );
                  if (time != null) {
                    final full = picked.add(Duration(hours: time.hour, minutes: time.minute));
                    controller.text = DateFormat("yyyy-MM-dd HH:mm").format(full);
                    newDate = full;
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (newDate != null) {
                await supabase
                    .from('appointments')
                    .update({'appointment_date': newDate!.toIso8601String(), 'status': 'Rescheduled'})
                    .eq('id', apptId);
                Navigator.pop(ctx);
                _loadAppointments();
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Future<void> _assignTechnician(String apptId, String? currentTechId) async {
    String? selectedTechId = currentTechId;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF9FBFC),
        title: const Text("Assign Technician", style: TextStyle(color: Color(0xFF1976D2))),
        content: DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: "Technician",
          ),
          value: selectedTechId,
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text("Unassigned"),
            ),
            ...technicians.map((t) {
              return DropdownMenuItem<String>(
                value: t['id'] as String,
                child: Text("${t['first_name']} ${t['last_name']}"),
              );
            }).toList(),
          ],
          onChanged: (String? value) => selectedTechId = value,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await supabase
                  .from('appointments')
                  .update({'assigned_technician_id': selectedTechId})
                  .eq('id', apptId);
              Navigator.pop(ctx);
              _loadAppointments();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
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
        title: const Text("Manage Appointments", style: TextStyle(color: Color(0xFF0D3B66))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1976D2)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD0E8FF), Color(0xFF9BBDDF), Color(0xFFF9FBFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF1976D2)))
            : appointments.isEmpty
                ? const Center(child: Text("No appointments found."))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      final customerName = appointment['customer_name'] ?? 'No Name';
                      final service = appointment["service"] ?? 'Unknown Service';
                      final details = appointment["details"] ?? '';
                      final date = appointment["appointment_date"] != null
                          ? _formatDateTime(appointment["appointment_date"])
                          : 'No Date';
                      final status = appointment["status"] ?? 'Pending';
                      final assignedTech = appointment['technician_name'];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                        color: const Color(0xFFF9FBFC),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$service - $customerName",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1976D2),
                                ),
                              ),
                              if (details.isNotEmpty)
                                Text("Details: $details", style: const TextStyle(color: Color(0xFF566573))),
                              const SizedBox(height: 6),
                              Text("Appointment: $date", style: const TextStyle(color: Color(0xFF566573))),
                              if (assignedTech != null)
                                Text("Technician: $assignedTech", style: const TextStyle(color: Color(0xFF566573))),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Chip(
                                    label: Text(status),
                                    backgroundColor: status == "Pending"
                                        ? Colors.orange.shade100
                                        : status == "Approved"
                                            ? Colors.green.shade100
                                            : status == "Rejected"
                                                ? Colors.red.shade100
                                                : Colors.grey.shade200,
                                    labelStyle: TextStyle(
                                      color: status == "Pending"
                                          ? Colors.orange
                                          : status == "Approved"
                                              ? Colors.green
                                              : status == "Rejected"
                                                  ? Colors.red
                                                  : Colors.grey,
                                    ),
                                  ),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      TextButton.icon(
                                        icon: const Icon(Icons.calendar_today, color: Color(0xFF1976D2), size: 18),
                                        label: const Text("Suggest New Schedule", style: TextStyle(color: Color(0xFF1976D2))),
                                        onPressed: () => _suggestSchedule(appointment["id"]),
                                      ),
                                      TextButton.icon(
                                        icon: const Icon(Icons.handyman, color: Colors.teal, size: 18),
                                        label: const Text("Assign Technician", style: TextStyle(color: Colors.teal)),
                                        onPressed: () => _assignTechnician(appointment["id"], appointment["assigned_technician_id"]),
                                      ),
                                      if (status == "Pending") ...[
                                        TextButton.icon(
                                          onPressed: () => _updateStatus(appointment["id"], "Approved"),
                                          icon: const Icon(Icons.check, color: Colors.green, size: 18),
                                          label: const Text("Approve", style: TextStyle(color: Colors.green)),
                                        ),
                                        TextButton.icon(
                                          onPressed: () => _updateStatus(appointment["id"], "Rejected"),
                                          icon: const Icon(Icons.close, color: Colors.red, size: 18),
                                          label: const Text("Reject", style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
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
