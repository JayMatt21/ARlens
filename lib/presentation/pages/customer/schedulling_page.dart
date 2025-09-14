import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SchedulingPage extends StatefulWidget {
  final Map<String, dynamic>? service;
  final String? brand;
  final String? size;

  const SchedulingPage({
    super.key,
    this.service,
    this.brand,
    this.size,
  });

  @override
  State<SchedulingPage> createState() => _SchedulingPageState();
}

class _SchedulingPageState extends State<SchedulingPage> {
  final TextEditingController dateController = TextEditingController();
  String? selectedPeriod; // AM or PM

  @override
  Widget build(BuildContext context) {
    final service = widget.service ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text("Schedule - ${service['title'] ?? widget.brand ?? 'Aircon'}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟦 Product / Service Info
            if (service.isNotEmpty) ...[
              Text(
                service['title'] ?? '',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                service['desc'] ?? '',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ] else ...[
              Text(
                "${widget.brand} - ${widget.size}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Selected Aircon: ${widget.brand} (${widget.size})",
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],

            const SizedBox(height: 20),

            // 🟦 Date Picker
            TextField(
              controller: dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Preferred Date",
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  dateController.text =
                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                }
              },
            ),
            const SizedBox(height: 16),

            // 🟦 AM/PM Dropdown
            DropdownButtonFormField<String>(
              value: selectedPeriod,
              items: const [
                DropdownMenuItem(value: "AM", child: Text("AM")),
                DropdownMenuItem(value: "PM", child: Text("PM")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedPeriod = value;
                });
              },
              decoration: const InputDecoration(
                labelText: "Preferred Time",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // 🟦 Disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Disclaimer: Your selected schedule is not final and may be rescheduled. "
                "Please wait for a confirmation call from our admin team.",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 30),

            // 🟦 Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (dateController.text.isEmpty || selectedPeriod == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select a date and AM/PM."),
                      ),
                    );
                    return;
                  }

                  final supabase = Supabase.instance.client;
                  final user = supabase.auth.currentUser;

                  try {
                    // Save appointment_date (date only) + period (AM/PM)
                    final appointmentDate = DateTime.parse(dateController.text);

                    await supabase.from('appointments').insert({
                      'user_id': user!.id,
                      'service': widget.service != null
                          ? widget.service!['title']
                          : widget.brand,
                      'details': widget.size,
                      'appointment_date': appointmentDate.toIso8601String(),
                      'period': selectedPeriod,
                      'status': 'Pending',
                    });

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Your request on ${dateController.text} ($selectedPeriod) "
                          "has been submitted. Waiting for Admin confirmation.",
                        ),
                        duration: const Duration(seconds: 5),
                      ),
                    );

                    Navigator.pop(context);
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error submitting request: $error"),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Submit Request",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
