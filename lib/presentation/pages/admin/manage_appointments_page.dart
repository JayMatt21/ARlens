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
  Map<int, TextEditingController> _dateControllers = {};
  Map<int, DateTime?> _pendingDates = {};
  Map<int, String?> _selectedTechnicians = {};

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _loadTechnicians();
  }

    Future<void> _loadTechnicians() async {
    try {
      final data = await supabase
          .from('technicians')
          .select('id, first_name, last_name');

      setState(() {
        technicians = (data as List<dynamic>? ?? []);
      });
    } catch (error) {
      setState(() {
        technicians = [];
      });
    }
  }

  Future<void> _loadAppointments() async {
    setState(() { loading = true; });
    try {
      final data = await supabase
          .from('appointments')
          .select('*, technician:technicians(id, first_name, last_name)')
          .order('appointment_date', ascending: false);

      setState(() {
        appointments = (data as List<dynamic>? ?? []);
        loading = false;
      });
    } catch (error) {
      setState(() {
        appointments = [];
        loading = false;
      });
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

                      _dateControllers[index] ??= TextEditingController();
                      _selectedTechnicians[index] ??= appointment["assigned_technician_id"];

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
                              // Prevent OVERFLOW! Wrap for all actions (Chip and buttons)
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                alignment: WrapAlignment.start,
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
                                  TextButton.icon(
                                    icon: const Icon(Icons.calendar_today, color: Color(0xFF1976D2), size: 18),
                                    label: const Text("Suggest New Schedule", style: TextStyle(color: Color(0xFF1976D2))),
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
                              // Inline Suggest New Schedule
                              if (expandedIndexes.contains(index))
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextField(
                                        controller: _dateControllers[index],
                                        readOnly: true,
                                        decoration: const InputDecoration(
                                            labelText: "Proposed New Date & Time",
                                            fillColor: Color(0xFFE8F0FE),
                                            filled: true,
                                            border: OutlineInputBorder()
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
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF1976D2)
                                            ),
                                            onPressed: () => _saveReschedule(index, appointment["id"]),
                                            child: const Text("Submit"),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              // Inline Assign Technician
                              if (expandedIndexes.contains(index + 1000))
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          labelText: "Technician",
                                          fillColor: Color(0xFFE8F0FE),
                                          filled: true,
                                          border: OutlineInputBorder(),
                                        ),
                                        value: _selectedTechnicians[index],
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
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.teal
                                            ),
                                            onPressed: () => _saveTechnicianAssign(index, appointment["id"]),
                                            child: const Text("Save"),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
  // ...all helper methods from before (_saveReschedule, _saveTechnicianAssign, _formatDateTime, etc)...

  Future<void> _saveTechnicianAssign(int index, dynamic appointmentId) async {
    final technicianId = _selectedTechnicians[index];
    try {
      await supabase
          .from('appointments')
          .update({'assigned_technician_id': technicianId})
          .eq('id', appointmentId)
          .select();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Technician assigned successfully!'))
      );
      setState(() {
        expandedIndexes.remove(index + 1000);
      });
      await _loadAppointments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign technician: $e'))
      );
    }
  }

  Future<void> _updateStatus(dynamic appointmentId, String status) async {
    try {
      await supabase
          .from('appointments')
          .update({'status': status})
          .eq('id', appointmentId)
          .select();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment status updated to $status!'))
      );
      await _loadAppointments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e'))
      );
    }
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'No Date';
    DateTime dt;
    if (dateTime is String) {
      dt = DateTime.parse(dateTime);
    } else if (dateTime is DateTime) {
      dt = dateTime;
    } else {
      return dateTime.toString();
    }
    return DateFormat('yyyy-MM-dd HH:mm').format(dt);
  }

  Future<void> _saveReschedule(int index, dynamic appointmentId) async {
    final newDate = _pendingDates[index];
    if (newDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a new date and time.'))
      );
      return;
    }
    try {
      await supabase
          .from('appointments')
          .update({'appointment_date': newDate.toIso8601String()})
          .eq('id', appointmentId)
          .select();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment rescheduled successfully!'))
      );
      setState(() {
        expandedIndexes.remove(index);
        _dateControllers[index]?.clear();
        _pendingDates[index] = null;
      });
      await _loadAppointments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reschedule appointment: $e'))
      );
    }
  }
}
