import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 170, 165),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Login to Senfrost',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email', filled: true, fillColor: Colors.white),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password', filled: true, fillColor: Colors.white),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => manualLogin(context),
                  child: const Text('Login'),
                ),
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text('Register now'),
                ),
                const SizedBox(height: 40),
                const Text('Or login with', style: TextStyle(color: Colors.white)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Image.asset('assets/icons/google.png'),
                      onPressed: () => signInWithGoogle(context),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Image.asset('assets/icons/facebook.png'),
                      onPressed: () => signInWithFacebook(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

    void manualLogin(BuildContext context) async {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      if (email.isEmpty || password.isEmpty) {
        showError(context, 'Please enter email and password.');
        return;
      }

      try {
        final res = await supabase.auth.signInWithPassword(email: email, password: password);

        if (res.user == null) {
          showError(context, 'Login failed. Please check your credentials.');
          return;
        }

        // Check email is verified
        if (res.user!.emailConfirmedAt == null) {
          showError(context, 'Please verify your email first by clicking the link sent to your inbox.');
          return;
        }

        // Email verified, proceed
        _routeBasedOnRole(context);

      } catch (e) {
        showError(context, 'Login error: $e');
      }
    }

  void signInWithGoogle(BuildContext context) async {
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.google, redirectTo: 'arlens111://callback');
    } catch (e) {
      showError(context, 'Google login failed: $e');
    }
  }

  void signInWithFacebook(BuildContext context) async {
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.facebook, redirectTo: 'yourapp://callback');
    } catch (e) {
      showError(context, 'Facebook login failed: $e');
    }
  }

  void _routeBasedOnRole(BuildContext context) {
    final userRole = 'customer'; 
    if (userRole == 'customer') {
      context.go('/customer-home');
    } else if (userRole == 'admin') {
      context.go('/admin-dashboard');
    } else if (userRole == 'technician') {
      context.go('/technician-dashboard');
    } else {
      context.go('/login');
    }
  }

  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
