import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PurchaseHistoryPage extends StatelessWidget {
  const PurchaseHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Purchase History")),
      body: const Center(child: Text("User purchase history goes here.")),
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();

  void _updatePassword() {
    if (newPassController.text == confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully.")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: oldPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Current Password"),
            ),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
            TextField(
              controller: confirmPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updatePassword,
              child: const Text("Update Password"),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SupabaseClient supabase = Supabase.instance.client;
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
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        setState(() {
          nameController.text = response['full_name'] ?? '';
          emailController.text = response['email'] ?? '';
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }

  Future<void> _saveChanges() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final updates = {
      'full_name': nameController.text,
      'email': emailController.text,
    };

    try {
      await supabase
          .from('profiles')
          .update(updates)
          .eq('id', user.id)
          .select();

      setState(() {
        changeLogs.add({
          'name': nameController.text,
          'email': emailController.text,
          'timestamp': DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
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
          // Profile Header
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage("assets/images/profile_placeholder.png"),
              ),
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
                setState(() {
                  notificationsEnabled = value;
                });
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

          const SizedBox(height: 16),

          // Change Logs Section
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
