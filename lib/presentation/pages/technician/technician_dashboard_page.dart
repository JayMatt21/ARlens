import 'package:arlens/presentation/pages/technician/area_calculator_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

//import 'package:arlens/presentation/pages/customer/area_calculator_ar_page.dart';

class TechnicianDashboardPage extends StatefulWidget {
  const TechnicianDashboardPage({super.key});

  @override
  State<TechnicianDashboardPage> createState() =>
      _TechnicianDashboardPageState();
}

class _TechnicianDashboardPageState extends State<TechnicianDashboardPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> appointments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }


  Future<void> _loadAppointments() async {
    setState(() => loading = true);
    try {
      final userId = supabase.auth.currentUser!.id;

      final data = await supabase
          .from('appointments')
          .select(
            '*, users!appointments_user_id_fkey(first_name, middle_initial, last_name)',
          )
          .eq('status', 'Approved')
          .eq('assigned_technician_id', userId)
          .order('appointment_date', ascending: true);

      final List<dynamic> appointmentList = data as List<dynamic>;

      for (var appt in appointmentList) {
        final user = appt['users'];
        final fullName = user != null
            ? "${user['first_name']} ${user['middle_initial'] != null && user['middle_initial'] != '' ? user['middle_initial'] + '. ' : ''}${user['last_name']}"
            : 'No Name';
        appt['customer_name'] = fullName;
      }

      setState(() {
        appointments = appointmentList;
        loading = false;
      });
    } catch (e) {
      debugPrint("Error loading technician appointments: $e");
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading appointments: $e")),
        );
      }
    }
  }

  /// Log report and recommendation for a specific appointment
  Future<void> _logReport(String appointmentId) async {
    final reportController = TextEditingController();
    final recommendationController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log Report"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reportController,
              decoration: const InputDecoration(labelText: "Report"),
            ),
            TextField(
              controller: recommendationController,
              decoration:
                  const InputDecoration(labelText: "Recommended Unit"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final reportText = reportController.text.trim();
              final recommendation = recommendationController.text.trim();
              if (reportText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Report cannot be empty")),
                );
                return;
              }

              try {
                await supabase.from('reports').insert({
                  'appointment_id': appointmentId,
                  'technician_id': supabase.auth.currentUser!.id,
                  'report_text': reportText,
                  'recommended_unit': recommendation,
                  'created_at': DateTime.now().toIso8601String(),
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Report logged!")),
                );
                Navigator.pop(context);
              } catch (e) {
                debugPrint("Error logging report: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error logging report: $e")),
                );
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  /// Open AR Calculator
  void _openARCalculator() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AreaCalculatorPhotoPage()),
    );
  }

  /// Logout the technician
  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    context.go('/'); // Navigate back to splash/login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Technician Dashboard"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            tooltip: "Open AR Calculator",
            onPressed: _openARCalculator,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: _logout,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : appointments.isEmpty
              ? const Center(child: Text("No assigned appointments."))
              : RefreshIndicator(
                  onRefresh: _loadAppointments,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appt = appointments[index];
                      final customerName = appt['customer_name'] ?? 'No Name';
                      final service = appt['service'] ?? '';
                      final date = appt['appointment_date'] ?? '';
                      final details = appt['details'] ?? '';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$service - $customerName",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text("Date: $date"),
                              if (details.isNotEmpty) Text("Details: $details"),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () => _logReport(appt['id']),
                                  icon: const Icon(Icons.note_add),
                                  label: const Text("Log Report"),
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
}
