//import 'package:arlens/presentation/pages/customer/area_calculator_ar_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
//import 'package:arlens/presentation/pages/customer/area_calculator_page.dart';
import 'package:arlens/presentation/pages/customer/video_auto_area_page.dart';

class TechnicianDashboardPage extends StatefulWidget {
  const TechnicianDashboardPage({super.key});

  @override
  State<TechnicianDashboardPage> createState() => _TechnicianDashboardPageState();
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

  Future<void> _logReport(String appointmentId) async {
    final reportController = TextEditingController();
    final recommendationController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF9FBFC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Log Report",
          style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reportController,
              decoration: const InputDecoration(
                labelText: "Report",
                filled: true,
                fillColor: Color(0xFFD0E8FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: Color(0xFF9BBDDF)),
                ),
                labelStyle: TextStyle(color: Color(0xFF154360)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: recommendationController,
              decoration: const InputDecoration(
                labelText: "Recommended Unit",
                filled: true,
                fillColor: Color(0xFFD0E8FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: Color(0xFF9BBDDF)),
                ),
                labelStyle: TextStyle(color: Color(0xFF154360)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF566573))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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

  void _openARCalculator() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AutoCornerRoomCalculatorPage()),
    );
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    context.go('/'); // Navigate back to splash/login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Technician Dashboard",
          style: TextStyle(color: Color(0xFF0D3B66), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Color(0xFF1976D2)),
            tooltip: "Open AR Calculator",
            onPressed: _openARCalculator,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1976D2)),
            tooltip: "Logout",
            onPressed: _logout,
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
            : appointments.isEmpty
                ? const Center(
                    child: Text(
                      "No assigned appointments.",
                      style: TextStyle(color: Color(0xFF566573), fontSize: 18),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadAppointments,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 90, 16, 16),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
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
                                const SizedBox(height: 6),
                                Text("Date: $date", style: const TextStyle(color: Color(0xFF566573))),
                                if (details.isNotEmpty)
                                  Text("Details: $details", style: const TextStyle(color: Color(0xFF566573))),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1976D2),
                                      elevation: 3,
                                      shadowColor: Colors.blueAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () => _logReport(appt['id']),
                                    icon: const Icon(Icons.note_add, color: Colors.white),
                                    label: const Text("Log Report", style: TextStyle(color: Colors.white)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
