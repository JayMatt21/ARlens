import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

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
  final firstNameController = TextEditingController();
  final middleInitialController = TextEditingController();
  final lastNameController = TextEditingController();
  final addressController = TextEditingController();
  final mobileController = TextEditingController();
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

    setState(() => isLoading = true);

    try {
      final profile = await Supabase.instance.client
          .from('users')  // Use 'users' to match registration
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      if (profile == null) {
        setState(() {
          firstNameController.text = '';
          middleInitialController.text = '';
          lastNameController.text = '';
          addressController.text = '';
          mobileController.text = '';
          emailController.text = user.email ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          firstNameController.text = profile['first_name'] ?? '';
          middleInitialController.text = profile['middle_initial'] ?? '';
          lastNameController.text = profile['last_name'] ?? '';
          addressController.text = profile['address'] ?? '';
          mobileController.text = profile['mobile_number'] ?? '';
          emailController.text = user.email ?? '';
          isLoading = false;
        });
      }
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
      'first_name': firstNameController.text.trim(),
      'middle_initial': middleInitialController.text.trim(),
      'last_name': lastNameController.text.trim(),
      'address': addressController.text.trim(),
      'mobile_number': mobileController.text.trim(),
    };

    try {
      await Supabase.instance.client
          .from('users')
          .update(updates)
          .eq('id', user.id);

      if (!mounted) return;

      setState(() {
        changeLogs.add({
          'first_name': firstNameController.text,
          'middle_initial': middleInitialController.text,
          'last_name': lastNameController.text,
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      GoRouter.of(context).go('/'); // Adjust as your login route
    });

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
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: "First Name"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: middleInitialController,
                  decoration: const InputDecoration(labelText: "Middle Initial"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: "Last Name"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Address"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: mobileController,
                  decoration: const InputDecoration(labelText: "Mobile Number"),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  enabled: false,
                ),
              ],
            ),
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
          Card(
            child: ListTile(
              title: Text(
                '${firstNameController.text} '
                '${middleInitialController.text} '
                '${lastNameController.text}',
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
          const Text(
            "Change Logs",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...changeLogs.map((log) {
            return ListTile(
              title: Text(
                  "${log['first_name']} ${log['middle_initial']} ${log['last_name']}"),
              subtitle: Text("Updated on: ${log['timestamp']}"),
            );
          }),
          const SizedBox(height: 16),
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
