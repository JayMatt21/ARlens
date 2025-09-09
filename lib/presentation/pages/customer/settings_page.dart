import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import your pages
import 'change_password_page.dart';
import 'purchase_history_page.dart';
import 'terms_page.dart';
import 'privacy_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final List<Map<String, dynamic>> changeLogs = [];
  bool notificationsEnabled = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      if (!mounted) return;

      setState(() {
        nameController.text = profile['full_name'] ?? '';
        emailController.text = profile['email'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }

  Future<void> _saveChanges() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final updates = {
      'full_name': nameController.text,
      'email': emailController.text,
    };

    try {
      await Supabase.instance.client
          .from('profiles')
          .update(updates)
          .eq('id', user.id)
          .select();

      if (!mounted) return;

      setState(() {
        changeLogs.add({
          'name': nameController.text,
          'email': emailController.text,
          'timestamp': DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully.")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    }
  }

  void _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pop(); 
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logged out successfully.")),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _saveChanges();
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Account & Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Info
          Card(
            child: ListTile(
              title: Text(
                nameController.text,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(emailController.text),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _showEditProfileDialog,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Purchase History
          Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Purchase History"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PurchaseHistoryPage()),
                );
              },
            ),
          ),

          // Change Password
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Change Password"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                );
              },
            ),
          ),

          // Notifications
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications),
              title: const Text("Enable Notifications"),
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() => notificationsEnabled = value);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value ? "Notifications enabled" : "Notifications disabled",
                    ),
                  ),
                );
              },
            ),
          ),

          // Terms & Conditions
          Card(
            child: ListTile(
              leading: const Icon(Icons.description),
              title: const Text("Terms & Conditions"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsPage()),
                );
              },
            ),
          ),

          // Privacy Notice
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text("Privacy Notice"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPage()),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Change Logs
          const Text(
            "Change Logs",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...changeLogs.map((log) {
            return ListTile(
              title: Text("${log['name']} - ${log['email']}"),
              subtitle: Text("Updated on: ${log['timestamp']}"),
            );
          }),

          const SizedBox(height: 16),

          // Logout
          Card(
            color: Colors.red[50],
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ),
        ],
      ),
    );
  }
}
