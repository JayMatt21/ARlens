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
  List<dynamic> technicians = [];
  bool loading = true;
  Set<int> expandedIndexes = {};
  final Map<int, TextEditingController> _dateControllers = {};
  final Map<int, DateTime?> _pendingDates = {};
  final Map<int, String?> _selectedTechnicians = {};

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _loadTechnicians();
  }

  Future<void> _loadAppointments() async {
    setState(() { loading = true; });
    try {
      final data = await supabase
          .from('appointments')
          .select('''
            *,
            users!appointments_user_id_fkey(
              first_name,
              middle_initial,
              last_name
            )
          ''')
          .order('created_at', ascending: false);

      final List<dynamic> appointmentList = data as List<dynamic>;

      for (var appt in appointmentList) {
        final user = appt['users'];
        final firstName = user?['first_name'] ?? '';
        final middleInitial = user?['middle_initial'] ?? '';
        final lastName = user?['last_name'] ?? '';
        final fullName =
            '$firstName ${middleInitial.isNotEmpty ? middleInitial + '. ' : ''}$lastName';
        appt['customer_name'] = fullName.isNotEmpty ? fullName : 'No Name';
      }

      setState(() {
        appointments = appointmentList;
        loading = false;
      });
    } catch (error) {
      setState(() { loading = false; });
      debugPrint("Error loading appointments: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading appointments: $error")),
      );
    }
  }

  Future<void> _loadTechnicians() async {
    try {
      final techs = await supabase
          .from('users')
          .select('id, first_name, last_name')
          .eq('role', 'technician');
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

  Future<void> _saveReschedule(int index, String apptId) async {
    final newDate = _pendingDates[index];
    if (newDate != null) {
      await supabase
          .from('appointments')
          .update({'appointment_date': newDate.toIso8601String(), 'status': 'Rescheduled'})
          .eq('id', apptId);
      setState(() {
        expandedIndexes.remove(index);
        _dateControllers[index]?.clear();
        _pendingDates[index] = null;
      });
      _loadAppointments();
    }
  }

  Future<void> _saveTechnicianAssign(int index, String apptId) async {
    final selectedTech = _selectedTechnicians[index];
    await supabase
        .from('appointments')
        .update({'assigned_technician_id': selectedTech})
        .eq('id', apptId);
    setState(() {
      expandedIndexes.remove(index + 1000);
    });
    _loadAppointments();
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

                    final customerName =
                        appointment['customer_name'] ?? 'No Name';
                    final service = appointment["service"] ?? 'Unknown Service';
                    final details = appointment["details"] ?? '';
                    final date = appointment["appointment_date"] != null
                        ? _formatDateTime(appointment["appointment_date"])
                        : 'No Date';
                    final status = appointment["status"] ?? 'Pending';

                    _dateControllers[index] ??= TextEditingController();
                    _selectedTechnicians[index] ??= appointment["assigned_technician_id"];

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
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
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
                                if (status == "Pending" || status == "Rescheduled") ...[
                                  TextButton.icon(
                                    icon: const Icon(Icons.calendar_today, color: Color(0xFF1976D2), size: 18),
                                    label: const Text("Reschedule", style: TextStyle(color: Color(0xFF1976D2))),
                                    onPressed: () {
                                      setState(() {
                                        if (expandedIndexes.contains(index)) {
                                          expandedIndexes.remove(index);
                                        } else {
                                          expandedIndexes.add(index);
                                        }
                                      });
                                    },
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.handyman, color: Colors.teal, size: 18),
                                    label: const Text("Assign Technician", style: TextStyle(color: Colors.teal)),
                                    onPressed: () {
                                      setState(() {
                                        if (expandedIndexes.contains(index + 1000)) {
                                          expandedIndexes.remove(index + 1000);
                                        } else {
                                          expandedIndexes.add(index + 1000);
                                        }
                                      });
                                    },
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _updateStatus(appointment["id"], "Rejected"),
                                    icon: const Icon(Icons.close, color: Colors.red, size: 18),
                                    label: const Text("Reject", style: TextStyle(color: Colors.red)),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _updateStatus(appointment["id"], "Approved"),
                                    icon: const Icon(Icons.check, color: Colors.green, size: 18),
                                    label: const Text("Approve", style: TextStyle(color: Colors.green)),
                                  ),
                                ],
                              ],
                            ),
                            // Inline Reschedule Form
                            if (expandedIndexes.contains(index))
                              Card(
                                color: const Color(0xFFE8F0FE),
                                margin: const EdgeInsets.only(top: 10),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextField(
                                        controller: _dateControllers[index],
                                        readOnly: true,
                                        decoration: const InputDecoration(
                                          labelText: "Proposed New Date & Time",
                                          filled: true,
                                          border: OutlineInputBorder(),
                                        ),
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
                                              initialTime: const TimeOfDay(hour: 9, minute: 0),
                                            );
                                            if (time != null) {
                                              final full = picked.add(
                                                Duration(hours: time.hour, minutes: time.minute));
                                              _dateControllers[index]!.text = DateFormat("yyyy-MM-dd HH:mm").format(full);
                                              _pendingDates[index] = full;
                                            }
                                          }
                                        },
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                expandedIndexes.remove(index);
                                              });
                                            },
                                            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1976D2)),
                                            onPressed: () => _saveReschedule(index, appointment["id"]),
                                            child: const Text("Submit"),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            // Inline Assign Technician
                            if (expandedIndexes.contains(index + 1000))
                              Card(
                                color: Colors.teal.withOpacity(0.12),
                                margin: const EdgeInsets.only(top: 10),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          labelText: "Technician",
                                          filled: true,
                                          border: OutlineInputBorder(),
                                        ),
                                        initialValue: _selectedTechnicians[index],
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
                                          }),
                                        ],
                                        onChanged: (String? value) {
                                          setState(() {
                                            _selectedTechnicians[index] = value;
                                          });
                                        },
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                expandedIndexes.remove(index + 1000);
                                              });
                                            },
                                            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                                            onPressed: () => _saveTechnicianAssign(index, appointment["id"]),
                                            child: const Text("Save"),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
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
