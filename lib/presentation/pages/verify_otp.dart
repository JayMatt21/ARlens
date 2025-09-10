import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyOtpPage extends StatefulWidget {
  final String email;

  const VerifyOtpPage({super.key, required this.email});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final otpController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;

  Future<void> verifyOtp() async {
    setState(() => _isVerifying = true);

    try {
      final res = await Supabase.instance.client.functions.invoke(
        'verify-otp', // Edge Function name
        body: {
          'email': widget.email,
          'otp': otpController.text.trim(),
        },
      );

      if (res.status == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account verified successfully!')),
        );
        Navigator.pushReplacementNamed(context, '/splash');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${res.data}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  Future<void> resendOtp() async {
    setState(() => _isResending = true);

    try {
      final res = await Supabase.instance.client.functions.invoke(
        'send-otp',
        body: {'email': widget.email},
      );

      if (res.status == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A new OTP has been sent to your email.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resend OTP: ${res.data}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'We sent a 6-digit code to ${widget.email}. Enter it below to verify your account:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              decoration: const InputDecoration(
                labelText: 'Enter verification code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isVerifying ? null : verifyOtp,
              child: _isVerifying
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verify'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _isResending ? null : resendOtp,
              child: _isResending
                  ? const CircularProgressIndicator()
                  : const Text('Resend Code'),
            ),
          ],
        ),
      ),
    );
  }
}
