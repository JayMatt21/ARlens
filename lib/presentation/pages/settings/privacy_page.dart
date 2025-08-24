import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  String _privacyText = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadPrivacyPolicy();
  }

  Future<void> _loadPrivacyPolicy() async {
    final text = await rootBundle.loadString('assets/text/privacy_policy.txt');
    setState(() {
      _privacyText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Notice")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          _privacyText,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
