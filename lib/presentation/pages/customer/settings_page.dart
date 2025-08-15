import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final List<Map<String, dynamic>> changeLogs = [];

  void _saveChanges() {
    final now = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    setState(() {
      changeLogs.add({
        "name": nameController.text,
        "email": emailController.text,
        "timestamp": now,
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          "Edit Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Full Name"),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: "Email"),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _saveChanges,
          child: const Text("Save Changes"),
        ),
        const SizedBox(height: 20),
        const Text(
          "Change Logs",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ...changeLogs.map((log) {
          return ListTile(
            title: Text("${log['name']} - ${log['email']}"),
            subtitle: Text("Updated on: ${log['timestamp']}"),
          );
        })
      ],
    );
  }
}
